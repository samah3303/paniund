import { NextResponse } from "next/server";
import { getAuthenticatedUserId, CORS_HEADERS } from "@/lib/api-auth";
import { prisma } from "@/lib/prisma";
import { n8nWebhookPayloadSchema } from "@/lib/validations/webhook";
import { apiSuccess, apiError, handleApiError } from "@/lib/api-response";

export async function OPTIONS() {
  return new NextResponse(null, { status: 204, headers: CORS_HEADERS });
}

export async function POST(request: Request) {
  try {
    let userId = await getAuthenticatedUserId(request);

    // Support fallback system webhook secret (e.g. for multi-user shared n8n runners)
    if (!userId) {
      const webhookSecret = request.headers.get("x-webhook-secret");
      const configuredSecret = process.env.N8N_WEBHOOK_SECRET;

      if (configuredSecret && webhookSecret === configuredSecret) {
        const { searchParams } = new URL(request.url);
        userId = searchParams.get("userId");
      }
    }

    if (!userId) {
      return apiError(
        "Unauthorized: Provide 'Authorization: Bearer <pnd_token>' or valid 'x-webhook-secret'",
        401
      );
    }

    // Verify user exists in database
    const user = await prisma.user.findUnique({
      where: { id: userId },
      select: { id: true, email: true },
    });

    if (!user) {
      return apiError("User not found", 404);
    }

    const rawBody = await request.json();
    const payload = n8nWebhookPayloadSchema.parse(rawBody);

    // ==========================================
    // 1. Application Status Update Event
    // ==========================================
    if (payload.event === "application.status_update") {
      // Find candidate's application matching the company name (case-insensitive)
      const matchingApps = await prisma.application.findMany({
        where: {
          userId,
          job: {
            company: {
              contains: payload.company,
              mode: "insensitive",
            },
          },
        },
        include: { job: true },
        orderBy: { updatedAt: "desc" },
      });

      if (matchingApps.length === 0) {
        return apiSuccess({
          matched: false,
          company: payload.company,
          message: `No active application found matching company "${payload.company}"`,
        });
      }

      // If jobTitle provided, refine to the best matching job, else take most recent
      let targetApp = matchingApps[0];
      if (payload.jobTitle && matchingApps.length > 1) {
        const titleMatch = matchingApps.find((app) =>
          app.job.title.toLowerCase().includes(payload.jobTitle!.toLowerCase())
        );
        if (titleMatch) targetApp = titleMatch;
      }

      // Build updated status history
      let history: Array<{ from: string; to: string; date: string; note?: string }> = [];
      try {
        if (targetApp.statusHistory) {
          history = JSON.parse(targetApp.statusHistory);
        }
      } catch {
        history = [];
      }

      history.push({
        from: targetApp.status,
        to: payload.status,
        date: new Date().toISOString(),
        note: payload.notes || "Status updated via n8n automation",
      });

      const updateData: {
        status: string;
        statusHistory: string;
        appliedAt?: Date;
        interviewDate?: Date | null;
        notes?: string;
      } = {
        status: payload.status,
        statusHistory: JSON.stringify(history),
      };

      if (payload.status === "applied" && !targetApp.appliedAt) {
        updateData.appliedAt = new Date();
      }

      if (payload.interviewDate) {
        updateData.interviewDate = new Date(payload.interviewDate);
      }

      if (payload.notes) {
        updateData.notes = targetApp.notes
          ? `${targetApp.notes}\n\n[n8n Note]: ${payload.notes}`
          : payload.notes;
      }

      const updatedApp = await prisma.application.update({
        where: { id: targetApp.id },
        data: updateData,
        include: { job: true },
      });

      return apiSuccess({
        matched: true,
        applicationId: updatedApp.id,
        company: updatedApp.job.company,
        jobTitle: updatedApp.job.title,
        previousStatus: targetApp.status,
        newStatus: updatedApp.status,
        interviewDate: updatedApp.interviewDate,
      });
    }

    // ==========================================
    // 2. Job Ingest Event (from Daily Radar / Feeds)
    // ==========================================
    if (payload.event === "job.ingest") {
      // Check for existing duplicate job for this user
      const existingJob = await prisma.job.findFirst({
        where: {
          userId,
          title: { equals: payload.title, mode: "insensitive" },
          ...(payload.company
            ? { company: { equals: payload.company, mode: "insensitive" } }
            : {}),
        },
      });

      const job =
        existingJob ||
        (await prisma.job.create({
          data: {
            userId,
            title: payload.title,
            company: payload.company,
            location: payload.location,
            salary: payload.salary,
            jobType: payload.jobType,
            description: payload.description,
            requirements: payload.requirements,
            sourceUrl: payload.sourceUrl,
            source: payload.source || "n8n_radar",
            matchScore: payload.matchScore,
          },
        }));

      let createdApplication = null;
      if (payload.createApplication) {
        const existingApp = await prisma.application.findFirst({
          where: { userId, jobId: job.id },
        });

        if (!existingApp) {
          createdApplication = await prisma.application.create({
            data: {
              userId,
              jobId: job.id,
              status: "wishlist",
              statusHistory: JSON.stringify([
                {
                  from: "created",
                  to: "wishlist",
                  date: new Date().toISOString(),
                  note: "Ingested via n8n daily radar",
                },
              ]),
            },
          });
        } else {
          createdApplication = existingApp;
        }
      }

      return apiSuccess({
        ingested: true,
        isNew: !existingJob,
        job,
        application: createdApplication,
      });
    }

    return apiError("Unsupported event type", 400);
  } catch (error) {
    return handleApiError(error, "Failed to process n8n webhook");
  }
}
