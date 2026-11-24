import { getServerSession } from "next-auth";
import { authOptions } from "@/lib/auth";
import { prisma } from "@/lib/prisma";
import { verifyJwt } from "@/lib/jwt";

export interface AuthenticatedUser {
  id: string;
  email?: string | null;
  name?: string | null;
  role?: string;
}

/**
 * Standard CORS headers for mobile and external API consumers.
 */
export const CORS_HEADERS = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Methods": "GET, POST, PUT, PATCH, DELETE, OPTIONS",
  "Access-Control-Allow-Headers": "Content-Type, Authorization",
};

/**
 * Resolves the authenticated user's ID across Bearer JWT (mobile),
 * API token (extension/integrations), and NextAuth cookie sessions (web).
 */
export async function getAuthenticatedUserId(request?: Request): Promise<string | null> {
  // 1. Check Authorization Header (Bearer JWT or API token)
  if (request) {
    const authHeader = request.headers.get("authorization");
    if (authHeader?.startsWith("Bearer ")) {
      const token = authHeader.replace("Bearer ", "").trim();

      // A. Try JWT (Mobile client)
      const jwtPayload = verifyJwt(token);
      if (jwtPayload?.userId) {
        return jwtPayload.userId;
      }

      // B. Try API Token (pnd_... / Extension / CLI)
      const user = await prisma.user.findUnique({
        where: { apiToken: token },
        select: { id: true },
      });
      if (user) {
        return user.id;
      }
    }
  }

  // 2. Fallback to NextAuth Cookie Session (Web)
  try {
    const session = await getServerSession(authOptions);
    if (session?.user && (session.user as { id: string }).id) {
      return (session.user as { id: string }).id;
    }
  } catch {
    // If getServerSession fails (e.g. outside request context or malformed cookies)
    return null;
  }

  return null;
}

/**
 * Resolves the full AuthenticatedUser record across Bearer JWT,
 * API token, and NextAuth cookie sessions.
 */
export async function getAuthenticatedUser(request?: Request): Promise<AuthenticatedUser | null> {
  // 1. Check Authorization Header
  if (request) {
    const authHeader = request.headers.get("authorization");
    if (authHeader?.startsWith("Bearer ")) {
      const token = authHeader.replace("Bearer ", "").trim();

      // A. Try JWT
      const jwtPayload = verifyJwt(token);
      if (jwtPayload?.userId) {
        return {
          id: jwtPayload.userId,
          email: jwtPayload.email,
          role: jwtPayload.role,
        };
      }

      // B. Try API Token
      const user = await prisma.user.findUnique({
        where: { apiToken: token },
        select: { id: true, email: true, name: true, role: true },
      });
      if (user) {
        return {
          id: user.id,
          email: user.email,
          name: user.name,
          role: user.role,
        };
      }
    }
  }

  // 2. Fallback to NextAuth Cookie Session
  try {
    const session = await getServerSession(authOptions);
    if (session?.user && (session.user as { id: string }).id) {
      const u = session.user as { id: string; email?: string | null; name?: string | null; role?: string };
      return {
        id: u.id,
        email: u.email,
        name: u.name,
        role: u.role || "user",
      };
    }
  } catch {
    return null;
  }

  return null;
}
