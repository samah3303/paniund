import { NextResponse } from "next/server";
import bcrypt from "bcryptjs";
import { prisma } from "@/lib/prisma";
import { signJwt } from "@/lib/jwt";
import { loginSchema } from "@/lib/validations";
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

    const { email, password } = loginSchema.parse(rawBody);

    const user = await prisma.user.findUnique({
      where: { email },
      select: {
        id: true,
        email: true,
        name: true,
        role: true,
        passwordHash: true,
      },
    });

    if (!user || !user.passwordHash) {
      return apiError("Invalid email or password", 401);
    }

    const isValid = await bcrypt.compare(password, user.passwordHash);
    if (!isValid) {
      return apiError("Invalid email or password", 401);
    }

    const token = signJwt({
      userId: user.id,
      email: user.email,
      role: user.role || "user",
    });

    try {
      await prisma.activityLog.create({
        data: {
          userId: user.id,
          action: "mobile_login",
          details: "Candidate logged in via mobile app",
        },
      });
    } catch (logErr) {
      console.warn("Failed to create activity log for mobile login:", logErr);
    }

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
      200,
      { headers: CORS_HEADERS }
    );
  } catch (error) {
    return handleApiError(error, "Failed to authenticate");
  }
}
