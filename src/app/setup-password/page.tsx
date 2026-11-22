import { Suspense } from "react";
import Logo from "@/components/Logo";
import SetupPasswordForm from "@/components/auth/SetupPasswordForm";

export const metadata = {
  title: "Create Password — paniund",
  description: "Set your password to complete your account setup.",
};

export default function SetupPasswordPage() {
  return (
    <div className="h-[100dvh] max-h-[100dvh] overflow-y-auto overflow-x-hidden [-webkit-overflow-scrolling:touch] bg-white md:bg-nordic-bg md:min-h-screen md:h-auto flex flex-col items-center justify-between md:justify-center px-5 sm:px-8 md:px-4 py-4 md:py-12 selection:bg-nordic-secondary selection:text-nordic-text font-sans pt-[max(20px,env(safe-area-inset-top,20px))] pb-[max(20px,env(safe-area-inset-bottom,20px))]">
      <div className="w-full max-w-md flex items-center justify-between mb-4 md:mb-8">
        <Logo size="md" theme="on-light" subtitle="Account Onboarding" />
      </div>
      <Suspense
        fallback={
          <div className="min-h-[300px] flex items-center justify-center bg-white border border-nordic-border rounded-[4px] p-8 text-sm font-semibold text-nordic-text-secondary">
            Loading...
          </div>
        }
      >
        <SetupPasswordForm />
      </Suspense>
    </div>
  );
}
