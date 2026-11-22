"use client";

import { useState, useEffect } from "react";
import { useRouter } from "next/navigation";
import { useSession } from "next-auth/react";
import SessionProvider from "@/components/SessionProvider";
import Link from "next/link";
import Logo from "@/components/Logo";

function CompleteProfileContent() {
  const router = useRouter();
  const { data: session, status } = useSession();

  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState("");

  const [targetRole, setTargetRole] = useState("");
  const [targetIndustry, setTargetIndustry] = useState("");
  const [targetCompanyTier, setTargetCompanyTier] = useState("Tier 1 Tech");
  const [minSalary, setMinSalary] = useState("");
  const [maxSalary, setMaxSalary] = useState("");
  const [skills, setSkills] = useState<string[]>([]);
  const [newSkill, setNewSkill] = useState("");

  useEffect(() => {
    if (status === "unauthenticated") {
      router.push("/login");
      return;
    }

    if (status === "authenticated") {
      fetch("/api/profile")
        .then((res) => (res.ok ? res.json() : null))
        .then((data) => {
          if (data) {
            const initialRole =
              (Array.isArray(data.targetRoles) && data.targetRoles[0]) ||
              data.targetRole ||
              "";
            setTargetRole(initialRole);
            setTargetIndustry(data.targetIndustry || "");
            setTargetCompanyTier(data.targetCompanyTier || "Tier 1 Tech");
            setMinSalary(data.minSalary ? String(data.minSalary) : "");
            setMaxSalary(data.maxSalary ? String(data.maxSalary) : "");
            setSkills(Array.isArray(data.skills) ? data.skills : []);
          }
          setLoading(false);
        })
        .catch(() => setLoading(false));
    }
  }, [status, router]);

  const addSkill = () => {
    const trimmed = newSkill.trim();
    if (trimmed && !skills.includes(trimmed)) {
      setSkills([...skills, trimmed]);
      setNewSkill("");
    }
  };

  const removeSkill = (skillToRemove: string) => {
    setSkills(skills.filter((s) => s !== skillToRemove));
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError("");
    setSaving(true);

    try {
      const res = await fetch("/api/profile", {
        method: "PUT",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          targetRole,
          targetIndustry,
          targetCompanyTier,
          minSalary: minSalary ? parseInt(minSalary, 10) : null,
          maxSalary: maxSalary ? parseInt(maxSalary, 10) : null,
          skills,
        }),
      });

      if (!res.ok) {
        throw new Error("Failed to save career target preferences.");
      }

      router.push("/dashboard");
    } catch (err) {
      setError(err instanceof Error ? err.message : "Save failed.");
      setSaving(false);
    }
  };

  if (loading) {
    return (
      <div className="min-h-screen flex items-center justify-center bg-nordic-bg text-sm font-semibold text-nordic-text-secondary">
        <div className="flex items-center gap-3">
          <div className="w-5 h-5 border-2 border-nordic-primary border-t-transparent rounded-full animate-spin" />
          <span>Loading Career Target Profile...</span>
        </div>
      </div>
    );
  }

  return (
    <div className="h-[100dvh] max-h-[100dvh] overflow-y-auto overflow-x-hidden [-webkit-overflow-scrolling:touch] bg-white md:bg-nordic-bg md:min-h-screen md:h-auto flex flex-col items-center justify-between md:justify-center px-4 sm:px-8 md:px-4 py-4 md:py-12 selection:bg-nordic-secondary selection:text-nordic-text pt-[max(16px,env(safe-area-inset-top,16px))] pb-28 md:pb-12">
      {/* Brand Header */}
      <div className="w-full max-w-2xl flex items-center justify-between mb-4 md:mb-8">
        <Logo size="md" theme="on-light" subtitle="Career Target Configuration" />
      </div>

      <div className="w-full max-w-2xl bg-transparent md:bg-white border-0 md:border md:border-nordic-border rounded-none md:rounded-[4px] shadow-none md:shadow-sm overflow-hidden flex-1 md:flex-initial flex flex-col">
        {/* Accent Bar (Desktop only) */}
        <div className="hidden md:block h-1.5 bg-nordic-primary w-full" />

        <div className="py-2 md:p-8 flex-1">
          <div className="mb-5 md:mb-6">
            <h1 className="text-2xl font-bold text-nordic-text tracking-tight">
              Calibrate Career Targets
            </h1>
            <p className="text-xs sm:text-sm text-nordic-text-secondary mt-1">
              These preferences configure the ATS matching engine and keyword alignment metrics.
            </p>
          </div>

          {error && (
            <div className="mb-6 border border-nordic-error bg-nordic-error/10 text-nordic-error p-3.5 rounded-xl md:rounded-[4px] text-xs font-semibold">
              {error}
            </div>
          )}

          <form id="onboarding-form" onSubmit={handleSubmit} className="space-y-5">
            <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
              <div>
                <label className="block text-xs font-bold text-nordic-text uppercase tracking-wide mb-1.5">
                  Primary Target Role
                </label>
                <input
                  type="text"
                  required
                  value={targetRole}
                  onChange={(e) => setTargetRole(e.target.value)}
                  placeholder="e.g. Lead Software Engineer"
                  className="w-full h-12 md:h-11 px-4 bg-white border border-nordic-border rounded-xl md:rounded-[4px] text-base md:text-sm text-nordic-text placeholder-nordic-neutral focus:outline-none focus:border-nordic-primary focus:ring-2 focus:ring-nordic-primary/15 transition-all"
                />
              </div>

              <div>
                <label className="block text-xs font-bold text-nordic-text uppercase tracking-wide mb-1.5">
                  Target Industry
                </label>
                <input
                  type="text"
                  value={targetIndustry}
                  onChange={(e) => setTargetIndustry(e.target.value)}
                  placeholder="e.g. Cloud Computing / SaaS"
                  className="w-full h-12 md:h-11 px-4 bg-white border border-nordic-border rounded-xl md:rounded-[4px] text-base md:text-sm text-nordic-text placeholder-nordic-neutral focus:outline-none focus:border-nordic-primary focus:ring-2 focus:ring-nordic-primary/15 transition-all"
                />
              </div>
            </div>

            <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
              <div>
                <label className="block text-xs font-bold text-nordic-text uppercase tracking-wide mb-1.5">
                  Company Tier
                </label>
                <select
                  value={targetCompanyTier}
                  onChange={(e) => setTargetCompanyTier(e.target.value)}
                  className="w-full h-12 md:h-11 px-3 bg-white border border-nordic-border rounded-xl md:rounded-[4px] text-base md:text-sm text-nordic-text focus:outline-none focus:border-nordic-primary focus:ring-2 focus:ring-nordic-primary/15 transition-all"
                >
                  <option value="Tier 1 Tech">Tier 1 Tech / FAANG</option>
                  <option value="Unicorn / High-Growth">High-Growth Unicorn</option>
                  <option value="Enterprise Global">Fortune 500 Enterprise</option>
                  <option value="Seed / Series A">Early Stage Startup</option>
                </select>
              </div>

              <div>
                <label className="block text-xs font-bold text-nordic-text uppercase tracking-wide mb-1.5">
                  Min Comp ($ / yr)
                </label>
                <input
                  type="number"
                  value={minSalary}
                  onChange={(e) => setMinSalary(e.target.value)}
                  placeholder="140000"
                  className="w-full h-12 md:h-11 px-4 bg-white border border-nordic-border rounded-xl md:rounded-[4px] text-base md:text-sm font-mono text-nordic-text placeholder-nordic-neutral focus:outline-none focus:border-nordic-primary focus:ring-2 focus:ring-nordic-primary/15 transition-all"
                />
              </div>

              <div>
                <label className="block text-xs font-bold text-nordic-text uppercase tracking-wide mb-1.5">
                  Max Comp ($ / yr)
                </label>
                <input
                  type="number"
                  value={maxSalary}
                  onChange={(e) => setMaxSalary(e.target.value)}
                  placeholder="220000"
                  className="w-full h-12 md:h-11 px-4 bg-white border border-nordic-border rounded-xl md:rounded-[4px] text-base md:text-sm font-mono text-nordic-text placeholder-nordic-neutral focus:outline-none focus:border-nordic-primary focus:ring-2 focus:ring-nordic-primary/15 transition-all"
                />
              </div>
            </div>

            {/* Core Competency Chips */}
            <div>
              <label className="block text-xs font-bold text-nordic-text uppercase tracking-wide mb-1.5">
                Core ATS Keywords & Skills
              </label>
              <div className="flex gap-2 mb-3">
                <input
                  type="text"
                  value={newSkill}
                  onChange={(e) => setNewSkill(e.target.value)}
                  onKeyDown={(e) => {
                    if (e.key === "Enter") {
                      e.preventDefault();
                      addSkill();
                    }
                  }}
                  placeholder="Add skill (e.g. Next.js, Docker)"
                  className="flex-1 h-12 md:h-11 px-4 bg-white border border-nordic-border rounded-xl md:rounded-[4px] text-base md:text-sm text-nordic-text placeholder-nordic-neutral focus:outline-none focus:border-nordic-primary focus:ring-2 focus:ring-nordic-primary/15 transition-all"
                />
                <button
                  type="button"
                  onClick={addSkill}
                  className="nordic-btn-yellow h-12 md:h-11 px-4 rounded-xl md:rounded-[4px] text-xs font-bold uppercase tracking-wide cursor-pointer tap-active shrink-0"
                >
                  Add Skill
                </button>
              </div>

              <div className="flex flex-wrap gap-2 min-h-12 border border-nordic-border p-3 rounded-xl md:rounded-[4px] bg-nordic-bg">
                {skills.length === 0 ? (
                  <span className="text-xs text-nordic-neutral self-center">
                    No custom keywords added yet. Type a skill above and press Enter.
                  </span>
                ) : (
                  skills.map((skill) => (
                    <span
                      key={skill}
                      className="inline-flex items-center gap-1.5 px-3 py-1 bg-white border border-nordic-border text-xs font-semibold rounded-[4px] text-nordic-text shadow-2xs"
                    >
                      {skill}
                      <button
                        type="button"
                        onClick={() => removeSkill(skill)}
                        className="text-nordic-neutral hover:text-nordic-error font-bold cursor-pointer ml-1 p-1"
                      >
                        ×
                      </button>
                    </span>
                  ))
                )}
              </div>
            </div>

            {/* Desktop Submit Button */}
            <button
              type="submit"
              disabled={saving}
              className="hidden md:inline-flex nordic-btn-primary w-full h-11 text-sm font-bold tracking-wide mt-2 cursor-pointer disabled:opacity-50"
            >
              {saving ? "Saving preferences..." : "Launch Application Workspace"}
            </button>
          </form>
        </div>

        <div className="border-t border-nordic-border bg-nordic-bg px-6 py-2.5 flex items-center justify-between text-xs text-nordic-neutral">
          <span>Step 2 of 2</span>
          <span className="font-semibold text-nordic-primary">Calibration</span>
        </div>
      </div>

      {/* Mobile Sticky Save Action Bar */}
      <div className="md:hidden fixed bottom-0 left-0 right-0 p-3 bg-white/95 backdrop-blur-md border-t border-nordic-border z-40 pb-[max(12px,env(safe-area-inset-bottom,12px))] shadow-lg">
        <button
          type="submit"
          form="onboarding-form"
          disabled={saving}
          className="nordic-btn-primary w-full h-12 rounded-xl text-sm font-bold tracking-wide cursor-pointer disabled:opacity-50 tap-active shadow-md"
        >
          {saving ? "Saving preferences..." : "Launch Application Workspace →"}
        </button>
      </div>
    </div>
  );
}

export default function CompleteProfilePage() {
  return (
    <SessionProvider>
      <CompleteProfileContent />
    </SessionProvider>
  );
}
