import { getServerSession } from "next-auth";
import { authOptions } from "@/lib/auth";
import { redirect } from "next/navigation";
import Link from "next/link";
import SessionProvider from "@/components/SessionProvider";
import DashboardHeader from "@/components/dashboard/DashboardHeader";
import DashboardBottomNav from "@/components/dashboard/DashboardBottomNav";

export default async function DashboardLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  const session = await getServerSession(authOptions);

  if (!session?.user) {
    redirect("/login");
  }

  return (
    <SessionProvider session={session}>
      <div className="h-[100dvh] max-h-[100dvh] overflow-hidden overscroll-none flex flex-col md:h-auto md:min-h-screen md:overflow-visible md:overscroll-auto bg-nordic-bg text-nordic-text font-sans selection:bg-nordic-secondary selection:text-nordic-text">
        {/* Skip to Main Content Link (WCAG 2.1 AA 2.4.1 Bypass Blocks) */}
        <a href="#main-content" className="skip-link">
          Skip to main content
        </a>

        {/* Top Header & Desktop Secondary Navigation / Mobile Top Bar */}
        <DashboardHeader user={session.user} />

        {/* Main Content Viewport (native smooth touch scrolling on mobile) */}
        <main
          id="main-content"
          tabIndex={-1}
          className="flex-1 w-full mx-auto px-4 py-3.5 pb-24 md:max-w-[1400px] md:p-8 md:pb-8 outline-none overflow-y-auto overflow-x-hidden md:overflow-visible overscroll-y-contain [-webkit-overflow-scrolling:touch]"
        >
          {children}
        </main>

        {/* Mobile App Bottom Navigation Bar */}
        <DashboardBottomNav />

        {/* Application Footer (Desktop Only) */}
        <footer className="hidden md:block border-t border-nordic-border bg-white py-6 px-4 sm:px-8 text-xs text-nordic-neutral mt-auto">
          <div className="max-w-[1400px] mx-auto flex flex-col sm:flex-row justify-between items-center gap-3">
            <div className="flex items-center gap-2">
              <span className="w-2.5 h-2.5 rounded-[2px] bg-nordic-primary inline-block" />
              <span className="w-2.5 h-2.5 rounded-[2px] bg-nordic-secondary inline-block" />
              <span className="font-bold text-nordic-text lowercase">paniund</span>
              <span>• Democratic ATS Career Operating System</span>
            </div>
            <div className="flex items-center gap-4 text-xs font-medium">
              <Link href="/dashboard" className="hover:text-nordic-primary transition-colors">
                Overview
              </Link>
              <span>•</span>
              <Link href="/dashboard/jobs" className="hover:text-nordic-primary transition-colors">
                Jobs
              </Link>
              <span>•</span>
              <Link href="/dashboard/tracker" className="hover:text-nordic-primary transition-colors">
                Tracker
              </Link>
              <span>•</span>
              <Link href="/dashboard/profile" className="hover:text-nordic-primary transition-colors">
                Profile
              </Link>
            </div>
          </div>
        </footer>
      </div>
    </SessionProvider>
  );
}
