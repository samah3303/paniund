import { Suspense } from "react";
import { getServerSession } from "next-auth";
import { authOptions } from "@/lib/auth";
import { redirect } from "next/navigation";
import Link from "next/link";
import Logo from "@/components/Logo";
import RegisterForm from "@/components/auth/RegisterForm";

export const metadata = {
  title: "Create Profile — paniund",
  description: "Create your free candidate profile, track applications, and optimize your resume.",
};

function RegisterFormSkeleton() {
  return (
    <div className="space-y-4 animate-pulse">
      <div>
        <div className="h-4 w-20 bg-nordic-border/60 rounded mb-1.5" />
        <div className="h-11 w-full bg-nordic-border/40 rounded" />
      </div>
      <div>
        <div className="h-4 w-24 bg-nordic-border/60 rounded mb-1.5" />
        <div className="h-11 w-full bg-nordic-border/40 rounded" />
      </div>
      <div>
        <div className="h-4 w-20 bg-nordic-border/60 rounded mb-1.5" />
        <div className="h-11 w-full bg-nordic-border/40 rounded" />
      </div>
      <div className="h-11 w-full bg-nordic-primary/30 rounded mt-2" />
    </div>
  );
}

export default async function RegisterPage() {
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
          href="/"
          className="md:hidden text-xs font-semibold text-nordic-text-secondary hover:text-nordic-primary p-2 tap-active"
        >
          Cancel
        </Link>
      </div>

      {/* Register Card on Desktop / Edge-to-Edge Container on Mobile */}
      <div className="w-full max-w-md flex-1 flex flex-col justify-between md:flex-initial md:bg-white md:border md:border-nordic-border md:rounded-[4px] md:shadow-sm overflow-hidden">
        {/* Top Brand Accent Bar (Desktop only) */}
        <div className="hidden md:block h-1.5 bg-nordic-secondary w-full" />

        <div className="py-2 md:p-8 flex-1 flex flex-col justify-between">
          <div className="mb-5 md:mb-6">
            <h1 className="text-2xl sm:text-2xl md:text-2xl font-bold text-nordic-text tracking-tight">
              Create Candidate Profile
            </h1>
            <p className="text-xs sm:text-sm text-nordic-text-secondary mt-1">
              Start free. Track jobs, scan ATS keywords, and tailor application materials.
            </p>
          </div>

          <Suspense fallback={<RegisterFormSkeleton />}>
            <RegisterForm />
          </Suspense>
        </div>
      </div>

      {/* Back to Home Link (Desktop only) */}
      <div className="hidden md:block mt-6 text-center">
        <Link
          href="/"
          className="text-xs font-semibold text-nordic-text-secondary hover:text-nordic-primary transition-colors"
        >
          &larr; Back to Home
        </Link>
      </div>
    </div>
  );
}
