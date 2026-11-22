"use client";

import Link from "next/link";
import { JobListing } from "@/types";
import { JobDetailTab } from "@/hooks/useJobDetail";

interface JobHeaderProps {
  job: JobListing;
  isApplied: boolean;
  markingApplied: boolean;
  handleMarkApplied: () => void;
  activeTab: JobDetailTab;
  setActiveTab: (tab: JobDetailTab) => void;
}

export const JOB_DETAIL_TABS: Array<{ key: JobDetailTab; label: string }> = [
  { key: "details", label: "Job Info" },
  { key: "resume_updates", label: "Resume Fixes" },
  { key: "cover_letter", label: "Cover Letter" },
  { key: "followup", label: "Follow-Up Email" },
  { key: "linkedin", label: "LinkedIn Message" },
];

export default function JobHeader({
  job,
  isApplied,
  markingApplied,
  handleMarkApplied,
  activeTab,
  setActiveTab,
}: JobHeaderProps) {
  return (
    <div className="nordic-card rounded-2xl sm:rounded-[4px] p-4.5 sm:p-8">
      {/* Top Breadcrumb */}
      <div className="flex items-center gap-2 text-xs text-nordic-neutral mb-3 sm:mb-4">
        <Link
          href="/dashboard/jobs"
          className="hover:text-nordic-primary font-medium flex items-center gap-1 tap-active"
        >
          ← Back to Jobs
        </Link>
        <span>/</span>
        <span className="text-nordic-text font-semibold truncate max-w-[200px] sm:max-w-none">
          {job.company || "Company"}
        </span>
      </div>

      {/* Main Header Info */}
      <div className="flex flex-col md:flex-row md:items-center justify-between gap-4 sm:gap-6 border-b border-nordic-border pb-4 sm:pb-6">
        <div className="space-y-1">
          <div className="flex items-center gap-2 mb-1">
            <span className="text-xs font-bold uppercase tracking-wider text-nordic-primary">
              {job.company || "Company"}
            </span>
            {job.source && (
              <span className="px-2 py-0.5 rounded-[2px] font-mono text-[10px] font-bold bg-nordic-text text-white">
                {job.source.toUpperCase()}
              </span>
            )}
          </div>
          <h1 className="text-xl sm:text-3xl font-bold text-nordic-text tracking-tight">
            {job.title}
          </h1>
          <div className="flex flex-wrap items-center gap-2 sm:gap-3 text-xs text-nordic-neutral pt-1">
            <span>📍 {job.location || "Remote / Hybrid"}</span>
            <span>•</span>
            <span className="font-mono text-nordic-text font-semibold">
              {job.salary || job.jobType}
            </span>
            {job.sourceUrl && (
              <>
                <span>•</span>
                <a
                  href={job.sourceUrl}
                  target="_blank"
                  rel="noreferrer"
                  className="text-nordic-primary hover:underline font-semibold flex items-center gap-1"
                >
                  View Original Post ↗
                </a>
              </>
            )}
          </div>
        </div>

        <div className="flex items-center justify-between sm:justify-end gap-3 shrink-0 w-full md:w-auto mt-2 md:mt-0">
          {isApplied ? (
            <div className="flex items-center gap-2 px-3.5 py-2 bg-nordic-success/10 border border-nordic-success/30 rounded-xl sm:rounded-[4px] text-xs font-bold text-nordic-success">
              <span>✓ Applied</span>
              <Link
                href="/dashboard/tracker"
                className="underline text-[11px] hover:opacity-80 ml-1"
              >
                Tracker ➔
              </Link>
            </div>
          ) : (
            <button
              onClick={handleMarkApplied}
              disabled={markingApplied}
              className="nordic-btn-primary h-11 px-4 sm:px-5 rounded-xl sm:rounded-[4px] text-xs font-bold uppercase tracking-wide cursor-pointer tap-active disabled:opacity-50"
            >
              {markingApplied ? "Saving..." : "✓ Mark as Applied"}
            </button>
          )}

          {job.matchScore !== null && (
            <div className="p-2 sm:p-3 bg-nordic-bg border border-nordic-border rounded-xl sm:rounded-[4px] text-center min-w-[85px] sm:min-w-[100px]">
              <span className="text-[9px] sm:text-[10px] text-nordic-neutral font-bold uppercase block">
                Match Score
              </span>
              <span className="text-xl sm:text-3xl font-bold font-mono text-nordic-primary leading-tight">
                {job.matchScore}%
              </span>
              <span className="text-[9px] sm:text-[10px] font-semibold text-nordic-success block">
                {job.matchScore >= 75 ? "High Fit" : "Moderate Fit"}
              </span>
            </div>
          )}
        </div>
      </div>

      {/* Tab Controls - Native Horizontal Segmented Pill Bar */}
      <div className="pt-3 sm:pt-4">
        <div
          role="tablist"
          aria-label="Job preparation tools"
          className="flex items-center gap-2 overflow-x-auto no-scrollbar pb-1 -mx-1 px-1"
        >
          {JOB_DETAIL_TABS.map((tab) => {
            const isActive = activeTab === tab.key;
            return (
              <button
                key={tab.key}
                role="tab"
                id={`tab-${tab.key}`}
                aria-controls={`panel-${tab.key}`}
                aria-selected={isActive}
                type="button"
                onClick={() => setActiveTab(tab.key)}
                className={`h-10 px-4 rounded-full sm:rounded-[4px] text-xs font-bold uppercase tracking-wide cursor-pointer transition-colors whitespace-nowrap shrink-0 tap-active ${
                  isActive
                    ? "bg-nordic-primary text-white shadow-xs"
                    : "bg-white text-nordic-text-secondary border border-nordic-border hover:bg-nordic-bg"
                }`}
              >
                {tab.label}
              </button>
            );
          })}
        </div>
      </div>
    </div>
  );
}
