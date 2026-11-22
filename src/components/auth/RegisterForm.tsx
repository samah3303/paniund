"use client";

import { useState } from "react";
import { signIn } from "next-auth/react";
import { useRouter } from "next/navigation";
import Link from "next/link";

export default function RegisterForm() {
  const router = useRouter();

  const [name, setName] = useState("");
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [showPassword, setShowPassword] = useState(false);
  const [error, setError] = useState("");
  const [loading, setLoading] = useState(false);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError("");

    if (password.length < 6) {
      setError("Password must be at least 6 characters long.");
      return;
    }

    setLoading(true);

    try {
      const res = await fetch("/api/auth/register", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          name: name.trim() || undefined,
          email: email.trim().toLowerCase(),
          password,
        }),
      });

      const data = await res.json().catch(() => ({}));

      if (!res.ok) {
        throw new Error(data.error || "Failed to create account. Please try again.");
      }

      // Automatically sign in the candidate
      const signInRes = await signIn("credentials", {
        redirect: false,
        email: email.trim().toLowerCase(),
        password,
      });

      if (signInRes?.error) {
        router.push(`/login?email=${encodeURIComponent(email.trim().toLowerCase())}`);
      } else {
        router.push("/dashboard");
        router.refresh();
      }
    } catch (err) {
      setError(err instanceof Error ? err.message : "Registration failed.");
      setLoading(false);
    }
  };

  return (
    <div>
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
              Full Name
            </label>
            <input
              type="text"
              value={name}
              onChange={(e) => setName(e.target.value)}
              placeholder="Sarah Jenkins"
              className="w-full h-12 md:h-11 px-4 bg-white border border-nordic-border rounded-xl md:rounded-[4px] text-base md:text-sm text-nordic-text placeholder-nordic-neutral focus:outline-none focus:border-nordic-primary focus:ring-2 focus:ring-nordic-primary/15 transition-all"
            />
          </div>

          <div>
            <label className="block text-xs font-bold text-nordic-text uppercase tracking-wide mb-1.5">
              Email Address
            </label>
            <input
              type="email"
              required
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              placeholder="sarah@example.com"
              className="w-full h-12 md:h-11 px-4 bg-white border border-nordic-border rounded-xl md:rounded-[4px] text-base md:text-sm text-nordic-text placeholder-nordic-neutral focus:outline-none focus:border-nordic-primary focus:ring-2 focus:ring-nordic-primary/15 transition-all"
            />
          </div>

          <div>
            <label className="block text-xs font-bold text-nordic-text uppercase tracking-wide mb-1.5">
              Password (min. 6 characters)
            </label>
            <div className="relative">
              <input
                type={showPassword ? "text" : "password"}
                required
                minLength={6}
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
            disabled={loading}
            className="nordic-btn-yellow w-full h-12 md:h-11 rounded-xl md:rounded-[4px] text-sm font-bold tracking-wide cursor-pointer disabled:opacity-50 uppercase tap-active shadow-xs"
          >
            {loading ? "Creating Profile..." : "Create Free Profile →"}
          </button>

          <p className="text-[11px] text-nordic-neutral text-center mt-3">
            By signing up, you agree to our{" "}
            <Link href="/terms" className="underline hover:text-nordic-text">
              Terms of Service
            </Link>{" "}
            and{" "}
            <Link href="/privacy" className="underline hover:text-nordic-text">
              Privacy Policy
            </Link>
            .
          </p>

          <div className="pt-3 border-t border-nordic-border text-center">
            <p className="text-xs text-nordic-text-secondary">
              Already have an account?{" "}
              <Link
                href="/login"
                className="text-nordic-primary font-bold hover:underline"
              >
                Sign In
              </Link>
            </p>
          </div>
        </div>
      </form>
    </div>
  );
}
