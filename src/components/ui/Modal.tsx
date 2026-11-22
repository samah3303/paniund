"use client";

import React, { useEffect, useRef } from "react";

export interface ModalProps {
  isOpen: boolean;
  onClose: () => void;
  title: string;
  subtitle?: string;
  children: React.ReactNode;
  maxWidth?: "sm" | "md" | "lg" | "xl" | "2xl" | "4xl";
  headerBadge?: React.ReactNode;
}

export default function Modal({
  isOpen,
  onClose,
  title,
  subtitle,
  children,
  maxWidth = "2xl",
  headerBadge,
}: ModalProps) {
  const dialogRef = useRef<HTMLDivElement>(null);
  const previousActiveElement = useRef<HTMLElement | null>(null);
  const titleId = useRef(`dialog-title-${Math.random().toString(36).slice(2, 9)}`);

  // Handle Escape key and focus trapping
  useEffect(() => {
    if (!isOpen) return;

    previousActiveElement.current = document.activeElement as HTMLElement;

    const handleKeyDown = (e: KeyboardEvent) => {
      if (e.key === "Escape") {
        e.preventDefault();
        onClose();
        return;
      }

      if (e.key === "Tab" && dialogRef.current) {
        const focusableElements = dialogRef.current.querySelectorAll<HTMLElement>(
          'button, [href], input, select, textarea, [tabindex]:not([tabindex="-1"])'
        );
        const first = focusableElements[0];
        const last = focusableElements[focusableElements.length - 1];

        if (e.shiftKey) {
          if (document.activeElement === first) {
            e.preventDefault();
            last?.focus();
          }
        } else {
          if (document.activeElement === last) {
            e.preventDefault();
            first?.focus();
          }
        }
      }
    };

    document.addEventListener("keydown", handleKeyDown);

    // Initial focus into modal
    const timer = setTimeout(() => {
      if (dialogRef.current) {
        const firstFocusable = dialogRef.current.querySelector<HTMLElement>(
          'button, [href], input, select, textarea, [tabindex]:not([tabindex="-1"])'
        );
        if (firstFocusable) {
          firstFocusable.focus();
        } else {
          dialogRef.current.focus();
        }
      }
    }, 50);

    // Prevent body scrolling while modal is open
    const originalOverflow = document.body.style.overflow;
    document.body.style.overflow = "hidden";

    return () => {
      document.removeEventListener("keydown", handleKeyDown);
      document.body.style.overflow = originalOverflow;
      clearTimeout(timer);
      if (previousActiveElement.current) {
        previousActiveElement.current.focus();
      }
    };
  }, [isOpen, onClose]);

  if (!isOpen) return null;

  const maxWidthClass = {
    sm: "max-w-sm",
    md: "max-w-md",
    lg: "max-w-lg",
    xl: "max-w-xl",
    "2xl": "max-w-2xl",
    "4xl": "max-w-4xl",
  }[maxWidth];

  return (
    <div
      className="fixed inset-0 z-[60] bg-black/60 backdrop-blur-xs flex items-end sm:items-center justify-center p-0 sm:p-4 overflow-hidden animate-in fade-in duration-200"
      onClick={(e) => {
        if (e.target === e.currentTarget) {
          onClose();
        }
      }}
    >
      <div
        ref={dialogRef}
        role="dialog"
        aria-modal="true"
        aria-labelledby={titleId.current}
        tabIndex={-1}
        className={`w-full ${maxWidthClass} bg-white border-t sm:border border-nordic-border rounded-t-2xl sm:rounded-[8px] shadow-2xl max-h-[90dvh] sm:max-h-[90vh] flex flex-col overflow-hidden outline-none animate-sheet-slide-up sm:animate-none`}
      >
        {/* Bottom Sheet Drag Handle Bar on Mobile */}
        <div
          className="w-full flex items-center justify-center pt-2.5 pb-1 sm:hidden bg-nordic-primary cursor-grab active:cursor-grabbing"
          aria-hidden="true"
        >
          <div className="w-12 h-1.5 bg-white/40 rounded-full" />
        </div>

        {/* Modal Header */}
        <div className="bg-nordic-primary text-white px-4 py-3 sm:p-5 flex items-center justify-between shrink-0">
          <div className="flex items-center gap-3">
            {headerBadge}
            <div>
              <h2
                id={titleId.current}
                className="text-base sm:text-base font-bold tracking-tight text-white leading-tight"
              >
                {title}
              </h2>
              {subtitle && (
                <p className="text-xs text-white/80 mt-0.5 line-clamp-1">
                  {subtitle}
                </p>
              )}
            </div>
          </div>

          <button
            type="button"
            onClick={onClose}
            aria-label="Close dialog"
            className="w-11 h-11 -mr-2 rounded-[6px] hover:bg-white/10 active:bg-white/20 text-white font-bold text-xl transition-colors cursor-pointer tap-active flex items-center justify-center shrink-0"
          >
            ✕
          </button>
        </div>

        {/* Modal Content with Safe Area Bottom Padding on Mobile */}
        <div className="flex-1 overflow-y-auto overflow-x-hidden p-4 sm:p-6 pb-[max(20px,env(safe-area-inset-bottom,20px))]">
          {children}
        </div>
      </div>
    </div>
  );
}
