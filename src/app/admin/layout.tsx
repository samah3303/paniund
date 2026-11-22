"use client";

import { useSession, signOut } from "next-auth/react";
import { useRouter, usePathname } from "next/navigation";
import Link from "next/link";
import SessionProvider from "@/components/SessionProvider";
import Logo from "@/components/Logo";

function AdminLayoutContent({ children }: { children: React.ReactNode }) {
  const { data: session, status } = useSession();
  const router = useRouter();
  const pathname = usePathname();

  if (status === "loading") {
    return (
      <div className="min-h-screen flex items-center justify-center bg-nordic-bg font-sans text-sm text-nordic-text-secondary">
        <div className="flex items-center gap-3">
          <div className="w-5 h-5 border-2 border-nordic-primary border-t-transparent rounded-full animate-spin" />
          <span className="font-semibold">Checking admin credentials...</span>
        </div>
      </div>
    );
  }

  if (status === "unauthenticated") {
    router.replace("/login");
    return null;
  }

  const role = (session?.user as { role?: string })?.role;
  const isAdmin = role === "admin" || session?.user?.email === "demo@paniund.com";

  if (!isAdmin) {
    return (
      <div className="min-h-screen flex items-center justify-center bg-nordic-bg p-4 font-sans">
        <div className="nordic-card max-w-md w-full p-8 text-center space-y-4 rounded-2xl sm:rounded-[4px]">
          <div className="w-12 h-12 rounded-full bg-nordic-error/10 text-nordic-error mx-auto flex items-center justify-center font-bold text-xl">
            ✕
          </div>
          <h2 className="text-xl font-bold text-nordic-text">Admin Access Required</h2>
          <p className="text-sm text-nordic-text-secondary">
            Your current account (<strong>{session?.user?.email}</strong>) does not have administrator privileges.
          </p>
          <div className="pt-2 flex flex-col gap-2">
            <Link
              href="/dashboard"
              className="nordic-btn-primary h-11 text-xs font-bold uppercase tracking-wide flex items-center justify-center"
            >
              Go to Candidate Dashboard
            </Link>
            <button
              onClick={() => signOut({ callbackUrl: "/login" })}
              className="nordic-btn-outline h-11 text-xs font-semibold cursor-pointer"
            >
              Sign In as Admin
            </button>
          </div>
        </div>
      </div>
    );
  }

  const navItems = [
    {
      name: "Overview",
      shortName: "Overview",
      href: "/admin",
      icon: (
        <svg className="w-5 h-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z" />
        </svg>
      ),
    },
    {
      name: "Candidates",
      shortName: "Candidates",
      href: "/admin/users",
      icon: (
        <svg className="w-5 h-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M12 4.354a4 4 0 110 5.292M15 21H3v-1a6 6 0 0112 0v1zm0 0h6v-1a6 6 0 00-9-5.197M13 7a4 4 0 11-8 0 4 4 0 018 0z" />
        </svg>
      ),
    },
    {
      name: "AI Telemetry & Logs",
      shortName: "Telemetry",
      href: "/admin/logs",
      icon: (
        <svg className="w-5 h-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M13 10V3L4 14h7v7l9-11h-7z" />
        </svg>
      ),
    },
    {
      name: "Web Analytics",
      shortName: "Analytics",
      href: "/admin/analytics",
      icon: (
        <svg className="w-5 h-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z" />
        </svg>
      ),
    },
  ];

  return (
    <div className="h-[100dvh] max-h-[100dvh] overflow-hidden overscroll-none flex flex-col md:h-auto md:min-h-screen md:overflow-visible md:overscroll-auto bg-nordic-bg text-nordic-text font-sans selection:bg-nordic-secondary selection:text-nordic-text">
      {/* Skip to Main Content Link (WCAG 2.1 AA 2.4.1 Bypass Blocks) */}
      <a href="#admin-main-content" className="skip-link">
        Skip to main content
      </a>

      {/* ==================== ADMIN TOP BAR ==================== */}
      <header className="sticky top-0 z-40 bg-nordic-text text-white shadow-sm border-b border-white/10 shrink-0 pt-[env(safe-area-inset-top,0px)] select-none" role="banner">
        <div className="flex h-14 sm:h-[60px] items-center justify-between px-3.5 sm:px-8 max-w-[1400px] mx-auto w-full">
          {/* Logo & Admin Badge */}
          <div className="flex items-center gap-2.5 sm:gap-4">
            <Logo theme="on-blue" size="sm" href="/admin" />
            <span className="px-2 py-0.5 bg-nordic-secondary text-nordic-text text-[10px] font-bold rounded-[2px] uppercase tracking-wider">
              Admin
            </span>
          </div>

          {/* Right Actions */}
          <div className="flex items-center gap-2 sm:gap-3">
            <Link
              href="/dashboard"
              aria-label="Return to candidate dashboard"
              className="text-xs font-bold text-white/90 hover:text-nordic-secondary px-2.5 py-1.5 rounded-[4px] border border-white/20 transition-colors flex items-center gap-1.5 tap-active"
            >
              <span aria-hidden="true">←</span>
              <span className="hidden sm:inline">Candidate View</span>
              <span className="sm:hidden text-[11px]">App</span>
            </Link>

            <button
              onClick={() => signOut({ callbackUrl: "/" })}
              aria-label="Sign out of admin portal"
              className="h-8 sm:h-9 px-2.5 sm:px-3 rounded-[4px] bg-nordic-error hover:bg-nordic-error/85 text-white text-xs font-bold transition-colors cursor-pointer tap-active flex items-center justify-center"
            >
              Exit
            </button>
          </div>
        </div>

        {/* Secondary Nav Bar (Desktop Only) */}
        <nav aria-label="Admin desktop navigation" className="hidden md:block bg-white border-b border-nordic-border shadow-xs">
          <div className="flex h-[44px] items-center px-4 sm:px-8 max-w-[1400px] mx-auto w-full overflow-x-auto gap-8">
            {navItems.map((item) => {
              const isActive = pathname === item.href;
              return (
                <Link
                  key={item.href}
                  href={item.href}
                  aria-current={isActive ? "page" : undefined}
                  className={`h-full flex items-center text-sm font-semibold whitespace-nowrap transition-colors relative ${
                    isActive
                      ? "text-nordic-primary font-bold border-b-[3px] border-nordic-primary"
                      : "text-nordic-text-secondary hover:text-nordic-text"
                  }`}
                >
                  {item.name}
                </Link>
              );
            })}
          </div>
        </nav>
      </header>

      {/* Main Content Area (Smooth native touch scrolling) */}
      <main
        id="admin-main-content"
        tabIndex={-1}
        className="flex-1 w-full mx-auto px-4 py-3.5 pb-24 md:max-w-[1400px] md:p-8 md:pb-8 outline-none overflow-y-auto overflow-x-hidden md:overflow-visible overscroll-y-contain [-webkit-overflow-scrolling:touch]"
      >
        {children}
      </main>

      {/* Mobile App Bottom Navigation Bar for Admin */}
      <nav
        aria-label="Admin mobile navigation"
        className="md:hidden fixed bottom-0 left-0 right-0 z-50 bg-white/95 backdrop-blur-xl border-t border-nordic-border/80 shadow-[0_-4px_24px_rgba(0,0,0,0.08)] select-none pb-[max(8px,env(safe-area-inset-bottom,8px))]"
      >
        <div className="grid grid-cols-4 h-14 max-w-md mx-auto px-2">
          {navItems.map((item) => {
            const isActive = pathname === item.href;
            return (
              <Link
                key={item.href}
                href={item.href}
                aria-current={isActive ? "page" : undefined}
                className={`flex flex-col items-center justify-center relative py-1 transition-all tap-active touch-target ${
                  isActive ? "text-nordic-primary font-bold" : "text-nordic-text-secondary hover:text-nordic-text"
                }`}
              >
                {isActive && (
                  <span className="absolute top-1 w-9 h-[3px] bg-nordic-primary rounded-full shadow-xs" />
                )}
                <div className={`transition-transform duration-150 ${isActive ? "scale-105" : "opacity-80"}`}>
                  {item.icon}
                </div>
                <span className={`text-[10px] mt-0.5 tracking-tight ${isActive ? "font-bold text-nordic-primary" : "font-medium text-nordic-neutral"}`}>
                  {item.shortName}
                </span>
              </Link>
            );
          })}
        </div>
      </nav>
    </div>
  );
}

export default function AdminLayout({ children }: { children: React.ReactNode }) {
  return (
    <SessionProvider>
      <AdminLayoutContent>{children}</AdminLayoutContent>
    </SessionProvider>
  );
}
