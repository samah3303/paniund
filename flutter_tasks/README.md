# 🏛️ paniund Mobile (Flutter) — Task Prompts Index

This folder contains self-contained, execution-ready **Task Prompts** for building the **paniund Mobile** Flutter application. Each phase prompt can be passed directly to an AI agent or developer to implement that specific milestone.

---

## 📋 Execution Order & Roadmap

| Task File | Phase Name | Focus Area | Depends On |
| :--- | :--- | :--- | :--- |
| **[`phase-01-backend-auth.md`](./phase-01-backend-auth.md)** | **Phase 1: Backend Auth & API Readiness** | Next.js JWT auth endpoint, unified auth helper for Bearer token & session | None |
| **[`phase-02-scaffolding-design-system.md`](./phase-02-scaffolding-design-system.md)** | **Phase 2: Flutter Scaffolding & Nordic Design System** | `/mobile` project, Riverpod, GoRouter, Dio interceptors, Nordic Yellow theme | Phase 1 |
| **[`phase-03-auth-and-resume.md`](./phase-03-auth-and-resume.md)** | **Phase 3: Auth Flow & Resume ATS Audit** | Mobile Login/Register, PDF/DOCX file picker upload, ATS Score Gauge & Breakdown | Phase 2 |
| **[`phase-04-job-tracker.md`](./phase-04-job-tracker.md)** | **Phase 4: Job Tracker & Pipeline CRM** | 6-stage Kanban board, status transitions, interview scheduler, job search | Phase 3 |
| **[`phase-05-share-intent-clipper.md`](./phase-05-share-intent-clipper.md)** | **Phase 5: Native Share Intent (Job Clipper)** | Intercept shared URLs from LinkedIn/Indeed apps, parse specs, ATS match score | Phase 4 |
| **[`phase-06-ai-generation-suite.md`](./phase-06-ai-generation-suite.md)** | **Phase 6: AI Generation Suite & Final Polish** | Cover Letter, Bullet Rewriter, LinkedIn Outreach, Follow-up Emails, Offline Caching | Phase 5 |

---

## 🛠️ Tech Stack Reference

- **Mobile Framework:** Flutter (Dart >= 3.3.0)
- **State Management:** Riverpod 2.x (`flutter_riverpod`, `riverpod_annotation`)
- **Routing:** `go_router`
- **Networking:** `dio` with QueuedTokenInterceptor
- **Secure Storage:** `flutter_secure_storage`
- **Document Handling:** `file_picker`, `open_filex`
- **Native Sharing:** `receive_sharing_intent`, `share_plus`
- **Design System:** **Nordic Yellow**
  - Primary Navy: `#003399`
  - Accent Yellow: `#FFDA1A`
  - Canvas Light: `#F5F5F5`
  - Surface White: `#FFFFFF`
  - Success Green: `#0A8A00`
  - Typography: `Noto Sans` & `JetBrains Mono`
