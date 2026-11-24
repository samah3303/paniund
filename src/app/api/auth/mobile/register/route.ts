import { NextResponse } from "next/server";
import bcrypt from "bcryptjs";
import { prisma } from "@/lib/prisma";
import { signJwt } from "@/lib/jwt";
import { registerSchema } from "@/lib/validations";
import { apiSuccess, apiError, handleApiError } from "@/lib/api-response";
import { CORS_HEADERS } from "@/lib/api-auth";

export async function OPTIONS() {
  return new NextResponse(null, {
    status: 204,
    headers: CORS_HEADERS,
  });
}

export async function POST(request: Request) {
  try {
    const rawBody = await request.json().catch(() => null);
    if (!rawBody) {
      return apiError("Invalid JSON body", 400);
    }

    const { email, password, name } = registerSchema.parse(rawBody);

    const existing = await prisma.user.findUnique({
      where: { email },
    });

    if (existing) {
      return apiError("An account with this email already exists", 409);
    }

    const passwordHash = await bcrypt.hash(password, 12);

    const user = await prisma.user.create({
      data: {
        email,
        passwordHash,
        name: name || null,
        role: "user",
        profile: {
          create: {},
        },
      },
      select: {
        id: true,
        email: true,
        name: true,
        role: true,
      },
    });

    try {
      await prisma.activityLog.create({
        data: {
          userId: user.id,
          action: "account_created",
          details: "Account registered via mobile app",
        },
      });
    } catch (logErr) {
      console.warn("Failed to create activity log for mobile register:", logErr);
    }

    const token = signJwt({
      userId: user.id,
      email: user.email,
      role: user.role || "user",
    });

    return apiSuccess(
      {
        token,
        user: {
          id: user.id,
          email: user.email,
          name: user.name,
          role: user.role || "user",
        },
      },
      201,
      { headers: CORS_HEADERS }
    );
  } catch (error) {
    return handleApiError(error, "Failed to create account");
  }
}
