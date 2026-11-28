import { z } from "zod";
import { sanitizeText, sanitizeUrl } from "@/lib/sanitize";
import { validApplicationStatuses } from "./index";

// Flexible status normalization: map common variations to valid database enum statuses
export const webhookStatusMap: Record<string, (typeof validApplicationStatuses)[number]> = {
  wishlist: "wishlist",
  applied: "applied",
  screening: "phone_screen",
  phone_screen: "phone_screen",
  phonescreen: "phone_screen",
  interview: "interview",
  interviewing: "interview",
  offer: "offer",
  offered: "offer",
  rejected: "rejected",
  rejection: "rejected",
  archived: "rejected",
};

export const n8nStatusUpdatePayloadSchema = z.object({
  event: z.literal("application.status_update"),
  company: z.string().min(1, "Company name is required").transform(sanitizeText),
  status: z.string().transform((s) => {
    const normalized = s.trim().toLowerCase().replace(/[\s-]/g, "_");
    return webhookStatusMap[normalized] || "applied";
  }),
  jobTitle: z.string().optional().transform((v) => (v ? sanitizeText(v) : undefined)),
  notes: z.string().max(5000).optional().transform((v) => (v ? sanitizeText(v) : undefined)),
  interviewDate: z
    .string()
    .optional()
    .nullable()
    .transform((v) => (v ? new Date(v).toISOString() : null)),
});

export const n8nJobIngestPayloadSchema = z.object({
  event: z.literal("job.ingest"),
  title: z.string().min(1, "Job title is required").max(200).transform(sanitizeText),
  company: z.string().max(150).optional().nullable().transform((v) => (v ? sanitizeText(v) : null)),
  location: z.string().max(150).optional().nullable().transform((v) => (v ? sanitizeText(v) : null)),
  salary: z.string().max(100).optional().nullable().transform((v) => (v ? sanitizeText(v) : null)),
  jobType: z.string().max(50).optional().nullable().transform((v) => (v ? sanitizeText(v) : null)),
  description: z.string().max(30000).optional().nullable().transform((v) => (v ? sanitizeText(v) : null)),
  requirements: z.string().optional().nullable().transform((v) => (v ? sanitizeText(v) : null)),
  sourceUrl: z.string().max(1000).optional().nullable().transform((v) => (v ? sanitizeUrl(v) : null)),
  source: z.string().max(50).optional().default("n8n_radar").transform(sanitizeText),
  matchScore: z.number().min(0).max(100).optional().nullable(),
  createApplication: z.boolean().optional().default(false),
});

export const n8nWebhookPayloadSchema = z.discriminatedUnion("event", [
  n8nStatusUpdatePayloadSchema,
  n8nJobIngestPayloadSchema,
]);

export type N8nStatusUpdatePayload = z.infer<typeof n8nStatusUpdatePayloadSchema>;
export type N8nJobIngestPayload = z.infer<typeof n8nJobIngestPayloadSchema>;
export type N8nWebhookPayload = z.infer<typeof n8nWebhookPayloadSchema>;
