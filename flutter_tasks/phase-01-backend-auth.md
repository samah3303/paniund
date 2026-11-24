# 📋 Task Prompt — Phase 1: Backend Auth & API Readiness

> **Phase:** 1 of 6  
> **Target:** Next.js Backend (`src/`)  
> **Goal:** Provide a dedicated JWT-based authentication endpoint for the Flutter mobile app and implement a unified authentication helper (`getAuthenticatedUser`) that validates Bearer JWT tokens, API tokens, and NextAuth session cookies across all API routes.

---

## 🎯 Objectives

1. Create a secure JWT generator and verifier using Node's native `crypto` or lightweight library.
2. Build `POST /api/auth/mobile/login` to authenticate email/password credentials and return a signed JWT + user profile.
3. Build `POST /api/auth/mobile/register` for new mobile user registrations.
4. Create `src/lib/api-auth.ts` to provide `getAuthenticatedUserId(request)` and `getAuthenticatedUser(request)`.
5. Update core API routes (`/api/profile`, `/api/applications`, `/api/jobs`, `/api/resume/upload`, `/api/resume/analyze`, `/api/generate/*`) to use `getAuthenticatedUserId` instead of only `getServerSession(authOptions)`.

---

## 📂 Files to Create / Modify

| Action | Path | Description |
| :--- | :--- | :--- |
| **CREATE** | `src/lib/jwt.ts` | JWT sign & verify utility using `NEXTAUTH_SECRET` |
| **CREATE** | `src/lib/api-auth.ts` | Unified authentication resolver (Bearer JWT, API Token, Session Cookie) |
| **CREATE** | `src/app/api/auth/mobile/login/route.ts` | Mobile authentication endpoint |
| **CREATE** | `src/app/api/auth/mobile/register/route.ts` | Mobile registration endpoint |
| **MODIFY** | `src/app/api/profile/route.ts` | Support Bearer token via `getAuthenticatedUserId` |
| **MODIFY** | `src/app/api/applications/route.ts` | Support Bearer token via `getAuthenticatedUserId` |
| **MODIFY** | `src/app/api/jobs/route.ts` | Support Bearer token via `getAuthenticatedUserId` |
| **MODIFY** | `src/app/api/resume/upload/route.ts` | Support Bearer token via `getAuthenticatedUserId` |
| **MODIFY** | `src/app/api/generate/cover-letter/route.ts` | Support Bearer token via `getAuthenticatedUserId` |

---

## 📝 Detailed Implementation Steps

### 1. `src/lib/jwt.ts`
Implement standard HMAC-SHA256 JWT signing and verification using `crypto` and `process.env.NEXTAUTH_SECRET`:
```typescript
import crypto from "crypto";

interface JwtPayload {
  userId: string;
  email: string;
  role: string;
  exp: number;
}

export function signJwt(payload: Omit<JwtPayload, "exp">, expiresInSeconds = 30 * 24 * 60 * 60): string {
  const secret = process.env.NEXTAUTH_SECRET || "default-fallback-secret-change-in-env";
  const header = Buffer.from(JSON.stringify({ alg: "HS256", typ: "JWT" })).toString("base64url");
  const exp = Math.floor(Date.now() / 1000) + expiresInSeconds;
  const fullPayload = Buffer.from(JSON.stringify({ ...payload, exp })).toString("base64url");
  const signature = crypto
    .createHmac("sha256", secret)
    .update(`${header}.${fullPayload}`)
    .digest("base64url");
  return `${header}.${fullPayload}.${signature}`;
}

export function verifyJwt(token: string): JwtPayload | null {
  try {
    const secret = process.env.NEXTAUTH_SECRET || "default-fallback-secret-change-in-env";
    const [header, payload, signature] = token.split(".");
    if (!header || !payload || !signature) return null;
    const expectedSignature = crypto
      .createHmac("sha256", secret)
      .update(`${header}.${payload}`)
      .digest("base64url");
    if (!crypto.timingSafeEqual(Buffer.from(signature), Buffer.from(expectedSignature))) {
      return null;
    }
    const decoded: JwtPayload = JSON.parse(Buffer.from(payload, "base64url").toString("utf-8"));
    if (decoded.exp && decoded.exp < Math.floor(Date.now() / 1000)) {
      return null; // Expired
    }
    return decoded;
  } catch {
    return null;
  }
}
```

### 2. `src/lib/api-auth.ts`
Create a helper function to authenticate requests from Web (Cookies), Mobile (JWT), and Extension (API Token):
```typescript
import { getServerSession } from "next-auth";
import { authOptions } from "@/lib/auth";
import { prisma } from "@/lib/prisma";
import { verifyJwt } from "@/lib/jwt";

export async function getAuthenticatedUserId(request?: Request): Promise<string | null> {
  // 1. Check Authorization Header (Bearer JWT or API token)
  if (request) {
    const authHeader = request.headers.get("authorization");
    if (authHeader?.startsWith("Bearer ")) {
      const token = authHeader.replace("Bearer ", "").trim();
      // A. Try JWT
      const jwtPayload = verifyJwt(token);
      if (jwtPayload?.userId) return jwtPayload.userId;

      // B. Try API Token (pnd_...)
      const user = await prisma.user.findUnique({
        where: { apiToken: token },
        select: { id: true },
      });
      if (user) return user.id;
    }
  }

  // 2. Fallback to NextAuth Cookie Session
  const session = await getServerSession(authOptions);
  if (session?.user && (session.user as { id: string }).id) {
    return (session.user as { id: string }).id;
  }

  return null;
}
```

### 3. `src/app/api/auth/mobile/login/route.ts`
- Expects `{ email, password }`.
- Verifies credentials against `prisma.user` with `bcrypt.compare`.
- Issues signed JWT with 30-day expiration.
- Returns `{ token, user: { id, email, name, role } }`.
- Includes CORS headers allowing mobile requests.

### 4. `src/app/api/auth/mobile/register/route.ts`
- Validates `{ email, password, name }`.
- Hashes password using `bcrypt.hash(password, 12)`.
- Generates initial `User` and blank `Profile` record.
- Issues JWT and returns `{ token, user }`.

### 5. Update Existing Routes
Replace `const session = await getServerSession(authOptions); if (!session?.user)...` with:
```typescript
const userId = await getAuthenticatedUserId(request);
if (!userId) {
  return apiError("Unauthorized", 401);
}
```

---

## ✅ Acceptance Criteria

1. `POST /api/auth/mobile/login` returns status 200 with `{ token, user }` on valid credentials, and 401 on invalid credentials.
2. An authorized request passing `Authorization: Bearer <TOKEN>` to `GET /api/profile` returns the profile data without needing NextAuth cookies.
3. Web application continues to function normally with NextAuth cookie sessions (backward compatible).
4. No regression on existing unit tests or linting (`npm run lint`).
