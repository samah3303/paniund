import { signJwt, verifyJwt } from "../src/lib/jwt";
import { getAuthenticatedUserId } from "../src/lib/api-auth";
import { POST as registerHandler } from "../src/app/api/auth/mobile/register/route";
import { POST as loginHandler } from "../src/app/api/auth/mobile/login/route";
import { GET as profileHandler } from "../src/app/api/profile/route";
import { prisma } from "../src/lib/prisma";

async function runTests() {
  console.log("🚀 Starting Phase 1 Authentication Verification Suite...\n");
  let passed = 0;
  let failed = 0;

  function assert(condition: boolean, testName: string) {
    if (condition) {
      console.log(`  ✅ PASS: ${testName}`);
      passed++;
    } else {
      console.error(`  ❌ FAIL: ${testName}`);
      failed++;
    }
  }

  // --- 1. JWT Unit Tests ---
  console.log("--- 1. Testing JWT Utilities (signJwt / verifyJwt) ---");
  const testPayload = {
    userId: "test-user-123",
    email: "test@example.com",
    role: "user",
  };

  const validToken = signJwt(testPayload, 3600);
  assert(typeof validToken === "string" && validToken.split(".").length === 3, "signJwt creates a valid 3-part JWT");

  const verified = verifyJwt(validToken);
  assert(
    verified !== null &&
      verified.userId === testPayload.userId &&
      verified.email === testPayload.email &&
      verified.role === testPayload.role,
    "verifyJwt correctly decodes a valid token"
  );

  // Expired token test
  const expiredToken = signJwt(testPayload, -10);
  const expiredVerified = verifyJwt(expiredToken);
  assert(expiredVerified === null, "verifyJwt rejects an expired token");

  // Tampered signature test
  const tamperedToken = validToken.substring(0, validToken.length - 2) + "xx";
  const tamperedVerified = verifyJwt(tamperedToken);
  assert(tamperedVerified === null, "verifyJwt rejects a tampered token signature");

  // Malformed token test
  assert(verifyJwt("not.a.valid.jwt") === null, "verifyJwt safely rejects malformed strings");

  // --- 2. Mobile Register & Login Route Handlers ---
  console.log("\n--- 2. Testing Mobile Auth Endpoints ---");
  const randomSuffix = Math.floor(Math.random() * 100000);
  const testEmail = `flutter_test_${randomSuffix}@testdomain.com`;
  const testPassword = "Password123!";
  const testName = "Nordic Flutter Tester";

  // Clean up beforehand just in case
  await prisma.user.deleteMany({ where: { email: testEmail } });

  // Test Mobile Registration
  const regRequest = new Request("http://localhost:3000/api/auth/mobile/register", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      email: testEmail,
      password: testPassword,
      name: testName,
    }),
  });

  const regResponse = await registerHandler(regRequest);
  const regData = await regResponse.json();
  assert(regResponse.status === 201, `POST /api/auth/mobile/register returns 201 Created (got ${regResponse.status})`);
  assert(Boolean(regData.token && regData.user?.id), "Registration returns JWT token and user info");

  // Test Duplicate Registration Conflict
  const dupRegRequest = new Request("http://localhost:3000/api/auth/mobile/register", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      email: testEmail,
      password: testPassword,
      name: testName,
    }),
  });
  const dupResponse = await registerHandler(dupRegRequest);
  assert(dupResponse.status === 409, `Duplicate registration returns 409 Conflict (got ${dupResponse.status})`);

  // Test Mobile Login
  const loginRequest = new Request("http://localhost:3000/api/auth/mobile/login", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      email: testEmail,
      password: testPassword,
    }),
  });

  const loginResponse = await loginHandler(loginRequest);
  const loginData = await loginResponse.json();
  assert(loginResponse.status === 200, `POST /api/auth/mobile/login returns 200 OK (got ${loginResponse.status})`);
  assert(Boolean(loginData.token && loginData.user?.id === regData.user?.id), "Login returns valid JWT token and matching user");

  // Test Mobile Login with wrong password
  const badLoginRequest = new Request("http://localhost:3000/api/auth/mobile/login", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      email: testEmail,
      password: "WrongPassword456!",
    }),
  });
  const badLoginResponse = await loginHandler(badLoginRequest);
  assert(badLoginResponse.status === 401, `Login with wrong password returns 401 Unauthorized (got ${badLoginResponse.status})`);

  // --- 3. Unified API Auth & Bearer Token Authorization ---
  console.log("\n--- 3. Testing Unified Auth & Protected Routes ---");
  const authHeaderRequest = new Request("http://localhost:3000/api/test", {
    headers: {
      Authorization: `Bearer ${loginData.token}`,
    },
  });

  const resolvedUserId = await getAuthenticatedUserId(authHeaderRequest);
  assert(resolvedUserId === regData.user?.id, "getAuthenticatedUserId correctly resolves userId from Bearer JWT");

  const unauthenticatedRequest = new Request("http://localhost:3000/api/test");
  const unauthUserId = await getAuthenticatedUserId(unauthenticatedRequest);
  assert(unauthUserId === null, "getAuthenticatedUserId returns null when unauthenticated");

  // Test GET /api/profile with Bearer Token
  const profileBearerRequest = new Request("http://localhost:3000/api/profile", {
    headers: {
      Authorization: `Bearer ${loginData.token}`,
    },
  });
  const profileResponse = await profileHandler(profileBearerRequest);
  const profileData = await profileResponse.json();
  assert(profileResponse.status === 200, `GET /api/profile with Bearer Token returns 200 OK (got ${profileResponse.status})`);
  assert(profileData.id === regData.user?.id, "GET /api/profile returns the correct candidate profile data");

  // Test GET /api/profile without token
  const unauthProfileReq = new Request("http://localhost:3000/api/profile");
  const unauthProfileRes = await profileHandler(unauthProfileReq);
  assert(unauthProfileRes.status === 401, `GET /api/profile without Bearer returns 401 Unauthorized (got ${unauthProfileRes.status})`);

  // --- Clean up ---
  console.log("\n--- Cleaning up test records ---");
  await prisma.activityLog.deleteMany({ where: { userId: regData.user?.id } });
  await prisma.profile.deleteMany({ where: { userId: regData.user?.id } });
  await prisma.user.deleteMany({ where: { id: regData.user?.id } });
  console.log("  🧹 Test user and logs cleaned up.");

  console.log(`\n========================================`);
  console.log(`Summary: ${passed} Passed, ${failed} Failed`);
  console.log(`========================================\n`);

  if (failed > 0) {
    process.exit(1);
  }
}

runTests().catch((err) => {
  console.error("Test runner encountered error:", err);
  process.exit(1);
});
