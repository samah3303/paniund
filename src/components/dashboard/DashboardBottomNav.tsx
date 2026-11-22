"use client";

import { usePathname } from "next/navigation";
import Link from "next/link";
import { DASHBOARD_NAV_ITEMS } from "./DashboardHeader";

export default function DashboardBottomNav() {
  const pathname = usePathname();

  return (
    <nav
      aria-label="Mobile app navigation"
      className="md:hidden fixed bottom-0 left-0 right-0 z-50 bg-white/95 backdrop-blur-xl border-t border-nordic-border/80 shadow-[0_-4px_24px_rgba(0,0,0,0.08)] select-none pb-[max(8px,env(safe-area-inset-bottom,8px))]"
    >
      <div className="grid grid-cols-4 h-14 max-w-md mx-auto px-2">
        {DASHBOARD_NAV_ITEMS.map((item) => {
          const isActive =
            pathname === item.href ||
            (item.href !== "/dashboard" && pathname.startsWith(item.href));
          return (
            <Link
              key={item.href}
              href={item.href}
              aria-current={isActive ? "page" : undefined}
              className={`flex flex-col items-center justify-center relative py-1 transition-all tap-active touch-target ${
                isActive
                  ? "text-nordic-primary font-bold"
                  : "text-nordic-text-secondary hover:text-nordic-text"
              }`}
            >
              {/* Native Active Pill / Highlight Indicator */}
              {isActive && (
                <span className="absolute top-1 w-9 h-[3px] bg-nordic-primary rounded-full shadow-xs" />
              )}

              <div
                className={`transition-transform duration-150 ${
                  isActive ? "scale-105" : "opacity-80"
                }`}
                aria-hidden="true"
              >
                {item.icon}
              </div>

              <span
                className={`text-[10px] mt-0.5 tracking-tight transition-colors ${
                  isActive ? "font-bold text-nordic-primary" : "font-medium text-nordic-neutral"
                }`}
              >
                {item.shortName}
              </span>
            </Link>
          );
        })}
      </div>
    </nav>
  );
}
