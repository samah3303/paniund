"use client";

import React, { useState } from "react";
import Link from "next/link";
import { useSession, signOut } from "next-auth/react";

export default function AccountSection() {
  const { data: session, status } = useSession();
  const [signingOut, setSigningOut] = useState(false);

  const user = session?.user;
  const role = (user as { role?: string })?.role;
  const isAdmin = role === "admin" || user?.email === "demo@paniund.com";

  const handleSignOut = async () => {
    setSigningOut(true);
    await signOut({ callbackUrl: "/" });
  };

  if (status === "loading") {
    return (
      <div className="nordic-card rounded-2xl sm:rounded-[4px] p-4.5 sm:p-6 bg-white border border-nordic-border shadow-xs animate-pulse">
        <div className="flex items-center justify-between gap-4">
          <div className="flex items-center gap-3">
            <div className="w-11 h-11 rounded-full bg-nordic-neutral/10" />
            <div className="space-y-1.5">
              <div className="h-4 w-28 bg-nordic-neutral/10 rounded-[2px]" />
              <div className="h-3 w-40 bg-nordic-neutral/10 rounded-[2px]" />
            </div>
          </div>
          <div className="h-9 w-24 bg-nordic-neutral/10 rounded-[4px]" />
        </div>
      </div>
    );
  }

  return (
    <section
      aria-label="Account and session management"
      className="nordic-card rounded-2xl sm:rounded-[4px] p-4.5 sm:p-6 bg-white border border-nordic-border shadow-xs"
    >
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        {/* User Account Info */}
        <div className="flex items-center gap-3.5">
          <div className="w-11 h-11 rounded-full bg-nordic-primary/10 border border-nordic-primary/20 text-nordic-primary font-bold text-sm flex items-center justify-center shrink-0">
            {(user?.name || user?.email || "U").charAt(0).toUpperCase()}
          </div>
          <div className="min-w-0">
            <div className="flex items-center gap-2 flex-wrap">
              <span className="text-sm font-bold text-nordic-text leading-tight truncate">
                {user?.name || user?.email?.split("@")[0] || "Account"}
              </span>
              <span
                className={`text-[10px] font-bold px-2 py-0.5 rounded-[2px] uppercase tracking-wider inline-flex items-center gap-1 ${
                  isAdmin
                    ? "bg-amber-100 text-amber-900 border border-amber-300"
                    : "bg-nordic-bg text-nordic-text-secondary border border-nordic-border"
                }`}
              >
                {isAdmin ? (
                  <>
                    <span aria-hidden="true">⚡</span> Administrator
                  </>
                ) : (
                  "Candidate"
                )}
              </span>
            </div>
            <p className="text-xs text-nordic-text-secondary mt-0.5 font-mono truncate">
              {user?.email}
            </p>
          </div>
        </div>

        {/* Action Controls */}
        <div
          className={`grid ${
            isAdmin ? "grid-cols-2" : "grid-cols-1"
          } sm:flex sm:items-center gap-2.5 pt-3 sm:pt-0 border-t sm:border-t-0 border-nordic-border`}
        >
          {isAdmin && (
            <Link
              href="/admin"
              className="nordic-btn-secondary text-xs h-11 sm:h-10 px-4 flex items-center justify-center gap-1.5 font-bold tap-active touch-target shadow-2xs"
              title="Open Admin Control Center"
              aria-label="Open Admin Control Center"
            >
              <span aria-hidden="true">⚡</span>
              <span>Admin Panel</span>
            </Link>
          )}

          <button
            type="button"
            onClick={handleSignOut}
            disabled={signingOut}
            className="h-11 sm:h-10 px-4 rounded-[4px] bg-red-50 hover:bg-red-100 active:bg-red-200 text-red-700 border border-red-200 text-xs font-bold transition-colors cursor-pointer tap-active flex items-center justify-center gap-1.5 touch-target shadow-2xs disabled:opacity-50"
            aria-label="Sign out of account"
          >
            <svg
              className="w-4 h-4 shrink-0"
              fill="none"
              stroke="currentColor"
              viewBox="0 0 24 24"
              aria-hidden="true"
            >
              <path
                strokeLinecap="round"
                strokeLinejoin="round"
                strokeWidth={2}
                d="M17 16l4-4m0 0l-4-4m4 4H7m6 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h4a3 3 0 013 3v1"
              />
            </svg>
            <span>{signingOut ? "Signing out..." : "Sign Out"}</span>
          </button>
        </div>
      </div>
    </section>
  );
}
