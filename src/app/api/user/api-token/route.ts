import { NextResponse } from "next/server";
import { getAuthenticatedUserId } from "@/lib/api-auth";
import { prisma } from "@/lib/prisma";
import crypto from "crypto";

export async function GET(request: Request) {
  try {
    const userId = await getAuthenticatedUserId(request);
    if (!userId) {
      return NextResponse.json({ error: "Unauthorized" }, { status: 401 });
    }
    let user = await prisma.user.findUnique({
      where: { id: userId },
      select: { apiToken: true },
    });

    // Auto-generate token if user doesn't have one yet
    if (!user?.apiToken) {
      const newToken = `pnd_${crypto.randomBytes(24).toString("hex")}`;
      user = await prisma.user.update({
        where: { id: userId },
        data: { apiToken: newToken },
        select: { apiToken: true },
      });
    }

    return NextResponse.json({ apiToken: user?.apiToken });
  } catch (error) {
    console.error("API token fetch error:", error);
    return NextResponse.json({ error: "Failed to fetch token" }, { status: 500 });
  }
}

export async function POST(request: Request) {
  try {
    const userId = await getAuthenticatedUserId(request);
    if (!userId) {
      return NextResponse.json({ error: "Unauthorized" }, { status: 401 });
    }
    const newToken = `pnd_${crypto.randomBytes(24).toString("hex")}`;

    await prisma.user.update({
      where: { id: userId },
      data: { apiToken: newToken },
    });

    return NextResponse.json({
      apiToken: newToken,
      message: "New API token generated successfully.",
    });
  } catch (error) {
    console.error("API token generation error:", error);
    return NextResponse.json({ error: "Failed to generate token" }, { status: 500 });
  }
}

export async function DELETE(request: Request) {
  try {
    const userId = await getAuthenticatedUserId(request);
    if (!userId) {
      return NextResponse.json({ error: "Unauthorized" }, { status: 401 });
    }

    await prisma.user.update({
      where: { id: userId },
      data: { apiToken: null },
    });

    return NextResponse.json({
      message: "API token revoked successfully.",
    });
  } catch (error) {
    console.error("API token revocation error:", error);
    return NextResponse.json({ error: "Failed to revoke token" }, { status: 500 });
  }
}
