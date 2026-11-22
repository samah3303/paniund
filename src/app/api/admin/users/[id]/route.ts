import { NextRequest } from "next/server";
import { prisma } from "@/lib/prisma";
import { getAdminSession } from "@/lib/admin";
import { adminUserUpdateSchema } from "@/lib/validations";
import { apiSuccess, apiError, handleApiError } from "@/lib/api-response";

export async function PATCH(
  req: NextRequest,
  { params }: { params: Promise<{ id: string }> }
) {
  const admin = await getAdminSession();
  if (!admin) {
    return apiError("Unauthorized. Admin privileges required.", 403);
  }

  const { id } = await params;

  try {
    const body = await req.json();
    const { role } = adminUserUpdateSchema.parse(body);

    // Prevent admin self-lockout: Admin cannot demote their own account to "user"
    if (admin.user.id === id && role && role !== "admin") {
      return apiError("Security policy: You cannot demote your own admin account.", 400);
    }

    const updated = await prisma.user.update({
      where: { id },
      data: {
        role: role || undefined,
      },
      select: {
        id: true,
        name: true,
        email: true,
        role: true,
        updatedAt: true,
      },
    });

    return apiSuccess(updated);
  } catch (error) {
    return handleApiError(error, "Failed to update user");
  }
}

export async function DELETE(
  _req: NextRequest,
  { params }: { params: Promise<{ id: string }> }
) {
  const admin = await getAdminSession();
  if (!admin) {
    return apiError("Unauthorized. Admin privileges required.", 403);
  }

  const { id } = await params;

  try {
    // Prevent admin from deleting their own account
    if (admin.user.id === id) {
      return apiError("Security policy: You cannot delete your own admin account.", 400);
    }

    const candidate = await prisma.user.findUnique({
      where: { id },
      select: { id: true, name: true, email: true, role: true },
    });

    if (!candidate) {
      return apiError("Candidate profile not found.", 404);
    }

    // Cascade delete user and all associated records (profile, jobs, applications, logs)
    await prisma.user.delete({
      where: { id },
    });

    // Log admin activity
    await prisma.activityLog.create({
      data: {
        userId: admin.user.id,
        action: "admin_candidate_deleted",
        details: `Deleted candidate profile: ${candidate.name || candidate.email} (${candidate.email})`,
      },
    });

    return apiSuccess({
      success: true,
      deletedId: id,
      deletedEmail: candidate.email,
    });
  } catch (error) {
    return handleApiError(error, "Failed to delete candidate profile");
  }
}
