import crypto from "crypto";

export interface JwtPayload {
  userId: string;
  email: string;
  role: string;
  exp: number;
}

/**
 * Signs a payload using HMAC-SHA256 and NEXTAUTH_SECRET.
 * Defaults to 30-day expiration.
 */
export function signJwt(
  payload: Omit<JwtPayload, "exp">,
  expiresInSeconds = 30 * 24 * 60 * 60
): string {
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

/**
 * Verifies a JWT token signature and expiration date.
 * Returns the decoded payload or null if invalid or expired.
 */
export function verifyJwt(token: string): JwtPayload | null {
  try {
    const secret = process.env.NEXTAUTH_SECRET || "default-fallback-secret-change-in-env";
    const parts = token.split(".");
    if (parts.length !== 3) return null;

    const [header, payload, signature] = parts;
    if (!header || !payload || !signature) return null;

    const expectedSignature = crypto
      .createHmac("sha256", secret)
      .update(`${header}.${payload}`)
      .digest("base64url");

    const sigBuf = Buffer.from(signature);
    const expectedBuf = Buffer.from(expectedSignature);

    if (sigBuf.length !== expectedBuf.length || !crypto.timingSafeEqual(sigBuf, expectedBuf)) {
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
