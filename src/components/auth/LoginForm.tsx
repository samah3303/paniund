"use client";

import { useState } from "react";
import { signIn } from "next-auth/react";
import { useRouter, useSearchParams } from "next/navigation";
import Link from "next/link";

export default function LoginForm() {
  const router = useRouter();
  const searchParams = useSearchParams();
  const isResetSuccess = searchParams.get("reset") === "success";
  const isResumeUploaded = searchParams.get("resumeUploaded") === "true";
  const initialEmail = searchParams.get("email") || "";

  const [email, setEmail] = useState(initialEmail);
  const [password, setPassword] = useState("");
  const [showPassword, setShowPassword] = useState(false);
  const [error, setError] = useState("");
  const [loading, setLoading] = useState(false);
  const [demoLoading, setDemoLoading] = useState(false);

  const handleDemoLogin = async () => {
    setEmail("demo@paniund.com");
    setPassword("demo123");
    setError("");
    setDemoLoading(true);

    try {
      const res = await signIn("credentials", {
        redirect: false,
        email: "demo@paniund.com",
        password: "demo123",
      });

      if (res?.error) {
        setError("Demo sign-in failed. Please verify database seeding.");
        setDemoLoading(false);
      } else {
        router.push("/dashboard");
        router.refresh();
      }
    } catch {
      setError("An unexpected system exception occurred during demo login.");
      setDemoLoading(false);
    }
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError("");
    setLoading(true);

    try {
      const res = await signIn("credentials", {
        redirect: false,
        email: email.trim().toLowerCase(),
        password,
      });

      if (res?.error) {
        setError("Invalid email or password. Please verify your credentials.");
        setLoading(false);
      } else {
        router.push("/dashboard");
        router.refresh();
      }
    } catch {
      setError("An unexpected system exception occurred. Please try again.");
      setLoading(false);
    }
  };

  return (
    <div>
      {isResumeUploaded && (
        <div className="mb-6 border border-nordic-success bg-nordic-success/10 text-nordic-success p-3.5 rounded-[4px] text-xs font-semibold flex items-start gap-2.5">
          <span className="font-bold text-base shrink-0 leading-none">✓</span>
          <div>
            <p className="font-bold text-nordic-text">Resume uploaded successfully!</p>
            <p className="text-[11px] text-nordic-text-secondary mt-0.5 font-normal">
              An account already exists for <strong className="text-nordic-text font-semibold">{initialEmail}</strong>. Please sign in with your password to view your updated ATS score and dashboard.
            </p>
          </div>
        </div>
      )}

      {isResetSuccess && (
        <div className="mb-6 border border-nordic-success bg-nordic-success/10 text-nordic-success p-3 rounded-[4px] text-xs font-semibold flex items-center gap-2">
          <span className="font-bold">✓</span>
          <span>
            Your password has been successfully updated! Please sign in with your new credentials.
          </span>
        </div>
      )}

      {error && (
        <div className="mb-6 border border-nordic-error bg-nordic-error/10 text-nordic-error p-3 rounded-[4px] text-xs font-semibold flex items-center gap-2">
          <svg
            className="w-4 h-4 shrink-0"
            viewBox="0 0 24 24"
            fill="none"
            stroke="currentColor"
            strokeWidth="2"
          >
            <circle cx="12" cy="12" r="10" />
            <line x1="12" y1="8" x2="12" />
            <line x1="12" y1="16" x2="12.01" y2="16" />
          </svg>
          <span>{error}</span>
        </div>
      )}

      <form onSubmit={handleSubmit} className="flex-1 flex flex-col justify-between space-y-4">
        <div className="space-y-4">
          <div>
            <label className="block text-xs font-bold text-nordic-text uppercase tracking-wide mb-1.5">
              Email Address
            </label>
            <input
              type="email"
              required
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              placeholder="candidate@example.com"
              className="w-full h-12 md:h-11 px-4 bg-white border border-nordic-border rounded-xl md:rounded-[4px] text-base md:text-sm text-nordic-text placeholder-nordic-neutral focus:outline-none focus:border-nordic-primary focus:ring-2 focus:ring-nordic-primary/15 transition-all"
            />
          </div>

          <div>
            <div className="flex items-center justify-between mb-1.5">
              <label className="block text-xs font-bold text-nordic-text uppercase tracking-wide">
                Password
              </label>
              <Link
                href="/forgot-password"
                className="text-xs text-nordic-primary hover:underline font-semibold"
              >
                Forgot?
              </Link>
            </div>
            <div className="relative">
              <input
                type={showPassword ? "text" : "password"}
                required
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                placeholder="••••••••••••"
                className="w-full h-12 md:h-11 pl-4 pr-12 bg-white border border-nordic-border rounded-xl md:rounded-[4px] text-base md:text-sm text-nordic-text placeholder-nordic-neutral focus:outline-none focus:border-nordic-primary focus:ring-2 focus:ring-nordic-primary/15 transition-all"
              />
              <button
                type="button"
                onClick={() => setShowPassword(!showPassword)}
                aria-label={showPassword ? "Hide password" : "Show password"}
                className="absolute right-1 top-1 bottom-1 w-10 flex items-center justify-center text-nordic-neutral hover:text-nordic-text tap-active cursor-pointer"
              >
                {showPassword ? (
                  <svg className="w-5 h-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M13.875 18.825A10.05 10.05 0 0112 19c-4.478 0-8.268-2.943-9.543-7a9.97 9.97 0 011.563-3.029m5.858.908a3 3 0 114.243 4.243M9.878 9.878l4.242 4.242M9.88 9.88l-3.29-3.29m7.532 7.532l3.29 3.29M3 3l18 18" />
                  </svg>
                ) : (
                  <svg className="w-5 h-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" />
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z" />
                  </svg>
                )}
              </button>
            </div>
          </div>
        </div>

        <div className="pt-2 space-y-3 mt-auto">
          <button
            type="submit"
            disabled={loading || demoLoading}
            className="nordic-btn-primary w-full h-12 md:h-11 rounded-xl md:rounded-[4px] text-sm font-bold tracking-wide cursor-pointer disabled:opacity-50 tap-active shadow-sm"
          >
            {loading ? "Signing in..." : "Sign In to Workspace"}
          </button>

          <div className="relative my-4">
            <div className="absolute inset-0 flex items-center">
              <div className="w-full border-t border-nordic-border" />
            </div>
            <div className="relative flex justify-center text-xs uppercase">
              <span className="bg-white px-2 text-nordic-text-secondary font-semibold">
                Instant Access
              </span>
            </div>
          </div>

          <button
            type="button"
            onClick={handleDemoLogin}
            disabled={loading || demoLoading}
            className="nordic-btn-yellow w-full h-12 md:h-11 rounded-xl md:rounded-[4px] text-sm font-bold uppercase tracking-wider cursor-pointer disabled:opacity-50 flex items-center justify-center gap-2 tap-active shadow-xs"
          >
            {demoLoading ? (
              "Authenticating..."
            ) : (
              <>
                <span>⚡</span>
                <span>Explore Demo Workspace</span>
              </>
            )}
          </button>

          <div className="pt-3 border-t border-nordic-border text-center">
            <p className="text-xs text-nordic-text-secondary">
              Don&apos;t have an account yet?{" "}
              <Link
                href="/register"
                className="text-nordic-primary font-bold hover:underline"
              >
                Create free profile &rarr;
              </Link>
            </p>
          </div>
        </div>
      </form>
    </div>
  );
}
