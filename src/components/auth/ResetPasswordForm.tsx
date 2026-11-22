"use client";

import { useState } from "react";
import { useRouter, useSearchParams } from "next/navigation";
import Link from "next/link";

export default function ResetPasswordForm() {
  const router = useRouter();
  const searchParams = useSearchParams();
  const token = searchParams.get("token") || "";

  const [password, setPassword] = useState("");
  const [confirmPassword, setConfirmPassword] = useState("");
  const [showPassword, setShowPassword] = useState(false);
  const [error, setError] = useState("");
  const [loading, setLoading] = useState(false);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError("");

    if (!token) {
      setError("Reset token is missing. Please request a new password reset link.");
      return;
    }

    if (password.length < 8) {
      setError("Password must contain at least 8 characters.");
      return;
    }

    if (password !== confirmPassword) {
      setError("Passwords do not match. Please ensure both fields are identical.");
      return;
    }

    setLoading(true);

    try {
      const res = await fetch("/api/auth/reset-password", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ token, password }),
      });

      const data = await res.json().catch(() => ({}));

      if (!res.ok) {
        throw new Error(data.error || "Failed to reset password.");
      }

      // Redirect to login with reset=success query param
      router.push("/login?reset=success");
    } catch (err) {
      setError(err instanceof Error ? err.message : "Failed to reset password.");
      setLoading(false);
    }
  };

  if (!token) {
    return (
      <div className="w-full max-w-md bg-white border border-nordic-border rounded-[4px] shadow-sm overflow-hidden p-8 text-center space-y-4">
        <div className="w-12 h-12 rounded-full bg-nordic-error/10 text-nordic-error mx-auto flex items-center justify-center font-bold text-xl">
          ✕
        </div>
        <h1 className="text-xl font-bold text-nordic-text">Invalid Reset Link</h1>
        <p className="text-xs text-nordic-text-secondary leading-relaxed">
          This password reset link is invalid or has expired. Please request a new recovery link.
        </p>
        <Link
          href="/forgot-password"
          className="nordic-btn-primary w-full h-10 text-xs font-bold uppercase tracking-wider flex items-center justify-center mt-2"
        >
          Request New Link
        </Link>
      </div>
    );
  }

  return (
    <div className="w-full max-w-md bg-transparent md:bg-white border-0 md:border md:border-nordic-border rounded-none md:rounded-[4px] shadow-none md:shadow-sm overflow-hidden flex-1 md:flex-initial flex flex-col justify-between">
      {/* Top Accent Bar (Desktop only) */}
      <div className="hidden md:block h-1.5 bg-nordic-secondary w-full" />

      <div className="py-2 md:p-8 flex-1 flex flex-col justify-between">
        <div className="mb-5 md:mb-6">
          <h1 className="text-2xl font-bold text-nordic-text tracking-tight">
            Create New Password
          </h1>
          <p className="text-xs sm:text-sm text-nordic-text-secondary mt-1">
            Choose a strong password with at least 8 characters.
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
                New Password
              </label>
              <div className="relative">
                <input
                  type={showPassword ? "text" : "password"}
                  required
                  minLength={8}
                  value={password}
                  onChange={(e) => setPassword(e.target.value)}
                  placeholder="At least 8 characters"
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
                Confirm New Password
              </label>
              <input
                type={showPassword ? "text" : "password"}
                required
                minLength={8}
                value={confirmPassword}
                onChange={(e) => setConfirmPassword(e.target.value)}
                placeholder="Re-type new password"
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
              {loading ? "Updating Password..." : "Set New Password"}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}
