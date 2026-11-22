import { Suspense } from "react";
import Logo from "@/components/Logo";
import ResetPasswordForm from "@/components/auth/ResetPasswordForm";

export const metadata = {
  title: "Create New Password — paniund",
  description: "Set a new secure password for your paniund account.",
};

export default function ResetPasswordPage() {
  return (
    <div className="h-[100dvh] max-h-[100dvh] overflow-y-auto overflow-x-hidden [-webkit-overflow-scrolling:touch] bg-white md:bg-nordic-bg md:min-h-screen md:h-auto flex flex-col items-center justify-between md:justify-center px-5 sm:px-8 md:px-4 py-4 md:py-12 selection:bg-nordic-secondary selection:text-nordic-text font-sans pt-[max(20px,env(safe-area-inset-top,20px))] pb-[max(20px,env(safe-area-inset-bottom,20px))]">
      {/* Top Mobile Bar / Desktop Logo */}
      <div className="w-full max-w-md flex items-center justify-between mb-4 md:mb-8">
        <Logo size="md" theme="on-light" />
      </div>

      <Suspense
        fallback={
          <div className="w-full max-w-md bg-white p-8 rounded-[4px] border border-nordic-border text-center text-xs text-nordic-neutral">
            Loading reset verification...
          </div>
        }
      >
        <ResetPasswordForm />
      </Suspense>
    </div>
  );
}
