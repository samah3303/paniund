import { NextResponse } from "next/server";
import { getAuthenticatedUserId } from "@/lib/api-auth";
import { prisma } from "@/lib/prisma";
import { getJobSearchRecommendations } from "@/lib/ai-tools";

export async function GET(request: Request) {
  try {
    const userId = await getAuthenticatedUserId(request);
    if (!userId) {
      return NextResponse.json({ error: "Unauthorized" }, { status: 401 });
    }

    const profile = await prisma.profile.findUnique({
      where: { userId },
    });

    if (!profile?.resumeText) {
      return NextResponse.json(
        { error: "No resume found. Please upload your resume first." },
        { status: 404 },
      );
    }

    const targetRoles = profile.targetRoles
      ? (JSON.parse(profile.targetRoles) as string[])
      : [];
    const skills = profile.skills
      ? (JSON.parse(profile.skills) as string[])
      : [];

    const recommendations = await getJobSearchRecommendations(
      profile.resumeText,
      targetRoles,
      skills,
    );

    // Log activity
    await prisma.activityLog.create({
      data: {
        userId,
        action: "job_match_requested",
        details: "Generated job search recommendations",
      },
    });

    return NextResponse.json(recommendations);
  } catch (error) {
    console.error("Job match error:", error);
    return NextResponse.json(
      { error: "Failed to get job recommendations" },
      { status: 500 },
    );
  }
}
