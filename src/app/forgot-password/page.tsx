import { getServerSession } from "next-auth";
import { authOptions } from "@/lib/auth";
import { redirect } from "next/navigation";
import Link from "next/link";
import Logo from "@/components/Logo";
import ForgotPasswordForm from "@/components/auth/ForgotPasswordForm";

export const metadata = {
  title: "Reset Password — paniund",
  description: "Request a password reset link for your paniund account.",
};

export default async function ForgotPasswordPage() {
  const session = await getServerSession(authOptions);

  if (session?.user) {
    redirect("/dashboard");
  }

  return (
    <div className="h-[100dvh] max-h-[100dvh] overflow-y-auto overflow-x-hidden [-webkit-overflow-scrolling:touch] bg-white md:bg-nordic-bg md:min-h-screen md:h-auto flex flex-col items-center justify-between md:justify-center px-5 sm:px-8 md:px-4 py-4 md:py-12 selection:bg-nordic-secondary selection:text-nordic-text font-sans pt-[max(20px,env(safe-area-inset-top,20px))] pb-[max(20px,env(safe-area-inset-bottom,20px))]">
      {/* Top Mobile Bar / Desktop Logo */}
      <div className="w-full max-w-md flex items-center justify-between mb-4 md:mb-8">
        <Link href="/" className="tap-active">
          <Logo size="md" theme="on-light" />
        </Link>
        <Link
          href="/login"
          className="md:hidden text-xs font-semibold text-nordic-text-secondary hover:text-nordic-primary p-2 tap-active"
        >
          Cancel
        </Link>
      </div>

      {/* Card on Desktop / Edge-to-Edge Container on Mobile */}
      <div className="w-full max-w-md flex-1 flex flex-col justify-between md:flex-initial md:bg-white md:border md:border-nordic-border md:rounded-[4px] md:shadow-sm overflow-hidden">
        {/* Top Accent Bar (Desktop only) */}
        <div className="hidden md:block h-1.5 bg-nordic-primary w-full" />

        <div className="py-2 md:p-8 flex-1 flex flex-col justify-between">
          <div className="mb-5 md:mb-6">
            <h1 className="text-2xl sm:text-2xl md:text-2xl font-bold text-nordic-text tracking-tight">
              Reset Password
            </h1>
            <p className="text-xs sm:text-sm text-nordic-text-secondary mt-1">
              Enter your account email address and we will dispatch password recovery instructions.
            </p>
          </div>

          <ForgotPasswordForm />
        </div>
      </div>

      {/* Back to Home Link (Desktop only) */}
      <div className="hidden md:block mt-8 text-xs text-nordic-neutral font-medium">
        <Link href="/" className="hover:text-nordic-primary transition-colors">
          ← Back to Overview
        </Link>
      </div>
    </div>
  );
}
