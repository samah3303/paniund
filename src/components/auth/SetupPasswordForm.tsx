"use client";

import { useState } from "react";
import { useRouter, useSearchParams } from "next/navigation";
import { signIn } from "next-auth/react";

export default function SetupPasswordForm() {
  const router = useRouter();
  const searchParams = useSearchParams();
  const email = searchParams.get("email") || "";
  const userId = searchParams.get("userId") || "";

  const [password, setPassword] = useState("");
  const [confirmPassword, setConfirmPassword] = useState("");
  const [showPassword, setShowPassword] = useState(false);
  const [error, setError] = useState("");
  const [loading, setLoading] = useState(false);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError("");

    if (password.length < 6) {
      setError("Password requirement: Must contain at least 6 characters.");
      return;
    }

    if (password !== confirmPassword) {
      setError("Password mismatch: Please ensure both password fields match.");
      return;
    }

    setLoading(true);

    try {
      const res = await fetch("/api/auth/register", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ userId, password }),
      });

      if (!res.ok) {
        const data = await res.json().catch(() => ({}));
        throw new Error(data.error || "Password setup failed.");
      }

      const signInRes = await signIn("credentials", {
        redirect: false,
        email,
        password,
      });

      if (signInRes?.error) {
        router.push("/login");
      } else {
        router.push("/complete-profile");
      }
    } catch (err) {
      setError(err instanceof Error ? err.message : "Password setup failed.");
      setLoading(false);
    }
  };

  return (
    <div className="w-full max-w-md bg-transparent md:bg-white border-0 md:border md:border-nordic-border rounded-none md:rounded-[4px] shadow-none md:shadow-sm overflow-hidden flex-1 md:flex-initial flex flex-col justify-between">
      {/* Accent Bar (Desktop only) */}
      <div className="hidden md:block h-1.5 bg-nordic-secondary w-full" />

      <div className="py-2 md:p-8 flex-1 flex flex-col justify-between">
        <div className="mb-5 md:mb-6">
          <h1 className="text-2xl font-bold text-nordic-text tracking-tight">
            Create Password
          </h1>
          <p className="text-xs sm:text-sm text-nordic-text-secondary mt-1">
            Resume parsed successfully for{" "}
            <span className="font-semibold text-nordic-text">{email || "candidate"}</span>. Set your account password to continue.
          </p>
        </div>

        {error && (
          <div className="mb-6 border border-nordic-error bg-nordic-error/10 text-nordic-error p-3 rounded-xl md:rounded-[4px] text-xs font-semibold flex items-center gap-2">
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
                Account Email
              </label>
              <input
                type="email"
                disabled
                value={email}
                className="w-full h-12 md:h-11 px-4 bg-nordic-bg border border-nordic-border rounded-xl md:rounded-[4px] text-base md:text-sm text-nordic-text font-medium opacity-90 cursor-not-allowed select-none"
              />
            </div>

            <div>
              <label className="block text-xs font-bold text-nordic-text uppercase tracking-wide mb-1.5">
                Set Password (min. 6 characters)
              </label>
              <div className="relative">
                <input
                  type={showPassword ? "text" : "password"}
                  required
                  value={password}
                  onChange={(e) => setPassword(e.target.value)}
                  placeholder="At least 6 characters"
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

            <div>
              <label className="block text-xs font-bold text-nordic-text uppercase tracking-wide mb-1.5">
                Confirm Password
              </label>
              <input
                type={showPassword ? "text" : "password"}
                required
                value={confirmPassword}
                onChange={(e) => setConfirmPassword(e.target.value)}
                placeholder="Repeat password"
                className="w-full h-12 md:h-11 px-4 bg-white border border-nordic-border rounded-xl md:rounded-[4px] text-base md:text-sm text-nordic-text placeholder-nordic-neutral focus:outline-none focus:border-nordic-primary focus:ring-2 focus:ring-nordic-primary/15 transition-all"
              />
            </div>
          </div>

          <div className="pt-2 mt-auto">
            <button
              type="submit"
              disabled={loading}
              className="nordic-btn-primary w-full h-12 md:h-11 rounded-xl md:rounded-[4px] text-sm font-bold tracking-wide cursor-pointer disabled:opacity-50 tap-active shadow-sm"
            >
              {loading ? "Setting up account..." : "Continue to Profile"}
            </button>
          </div>
        </form>
      </div>

      <div className="border-t border-nordic-border bg-nordic-bg px-6 py-2.5 flex items-center justify-between text-xs text-nordic-neutral">
        <span>Step 1 of 2</span>
        <span className="font-semibold text-nordic-primary">Account Security</span>
      </div>
    </div>
  );
}
