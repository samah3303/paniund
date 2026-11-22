"use client";

import { usePathname, useRouter } from "next/navigation";
import Link from "next/link";
import Logo from "@/components/Logo";

interface MobileTopBarProps {
  user?: {
    name?: string | null;
    email?: string | null;
    role?: string | null;
  };
}

export default function MobileTopBar({ user }: MobileTopBarProps) {
  const pathname = usePathname();
  const router = useRouter();

  const isAdmin = user?.role === "admin" || user?.email === "demo@paniund.com";
  const userInitial = (user?.name || user?.email || "U").charAt(0).toUpperCase();

  // Determine if this is a sub-page that should show a back button
  const isSubPage =
    pathname.startsWith("/dashboard/jobs/") && pathname !== "/dashboard/jobs";

  // Derive concise page title
  let pageTitle = "Dashboard";
  if (pathname === "/dashboard") pageTitle = "Dashboard";
  else if (pathname === "/dashboard/jobs") pageTitle = "Jobs";
  else if (pathname.startsWith("/dashboard/jobs/")) pageTitle = "Job Details";
  else if (pathname === "/dashboard/tracker") pageTitle = "Tracker";
  else if (pathname === "/dashboard/profile") pageTitle = "Profile";
  else if (pathname === "/admin") pageTitle = "Admin Overview";
  else if (pathname === "/admin/users") pageTitle = "Candidates";
  else if (pathname === "/admin/logs") pageTitle = "Telemetry Logs";
  else if (pathname === "/admin/analytics") pageTitle = "Web Analytics";

  return (
    <header className="md:hidden sticky top-0 z-40 bg-nordic-primary text-white border-b border-white/10 shrink-0 pt-[env(safe-area-inset-top,0px)] shadow-xs">
      <div className="h-14 px-3 flex items-center justify-between">
        {/* Left Side: Back Button on subpages, or Brand Logo */}
        <div className="flex items-center min-w-[70px]">
          {isSubPage ? (
            <button
              type="button"
              onClick={() => router.back()}
              aria-label="Go back"
              className="w-11 h-11 -ml-1 rounded-[6px] flex items-center justify-center text-white active:bg-white/15 tap-active"
            >
              <svg className="w-5 h-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2.5" d="M15 19l-7-7 7-7" />
              </svg>
            </button>
          ) : (
            <Link href="/dashboard" className="tap-active flex items-center">
              <Logo theme="on-blue" size="sm" />
            </Link>
          )}
        </div>

        {/* Center: Concise Page Title */}
        <div className="text-center font-bold text-sm tracking-tight text-white truncate px-2 max-w-[180px]">
          {pageTitle}
        </div>

        {/* Right Side: Quick Action or Profile Avatar */}
        <div className="flex items-center justify-end gap-1.5 min-w-[70px]">
          {isAdmin && (
            <Link
              href={pathname.startsWith("/admin") ? "/dashboard" : "/admin"}
              className="px-2 py-1 bg-nordic-secondary text-nordic-text font-bold text-[10px] rounded-[4px] uppercase tracking-wider tap-active flex items-center gap-1 shadow-2xs"
              title={pathname.startsWith("/admin") ? "Switch to Candidate View" : "Admin Panel"}
            >
              <span>⚡</span>
              <span>{pathname.startsWith("/admin") ? "App" : "Admin"}</span>
            </Link>
          )}

          <Link
            href="/dashboard/profile"
            aria-label="Account profile settings"
            className="w-8 h-8 rounded-full bg-nordic-secondary text-nordic-text font-bold text-xs flex items-center justify-center shadow-xs border border-white/30 tap-active"
          >
            {userInitial}
          </Link>
        </div>
      </div>
    </header>
  );
}
