<div align="center">

# 🏛️ paniund — Intelligent Career & ATS Workspace

**Beat the ATS filter. Tailor applications with AI. Organize your job search across the globe.**

[![Next.js 16](https://img.shields.io/badge/Next.js-16.2-black?style=flat-square&logo=next.js)](https://nextjs.org/)
[![React 19](https://img.shields.io/badge/React-19.2-blue?style=flat-square&logo=react)](https://react.dev/)
[![TypeScript](https://img.shields.io/badge/TypeScript-5-blue?style=flat-square&logo=typescript)](https://www.typescriptlang.org/)
[![Tailwind CSS v4](https://img.shields.io/badge/Tailwind_CSS-v4-38B2AC?style=flat-square&logo=tailwind-css)](https://tailwindcss.com/)
[![Prisma ORM](https://img.shields.io/badge/Prisma-5.22-2D3748?style=flat-square&logo=prisma)](https://www.prisma.io/)
[![Neon Database](https://img.shields.io/badge/Neon-PostgreSQL-00E599?style=flat-square&logo=postgresql)](https://neon.tech/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow?style=flat-square)](LICENSE)

[🌐 Live App](https://paniund.com) • [✨ Features](#-core-features) • [🛠️ Tech Stack](#️-tech-stack) • [🚀 Quick Start](#-getting-started) • [🔒 Privacy & Security](#-privacy--security)

</div>

---

## 💡 About paniund

Over 70% of candidate resumes are filtered out by automated **Applicant Tracking Systems (ATS)** like Workday, Taleo, and Greenhouse before a hiring manager ever reads them. 

**paniund** is a full-stack career platform designed to empower job seekers. It simulates enterprise ATS parsers, identifies missing keywords, tailors application materials in seconds, and organizes applications across a unified multi-stage pipeline.

Built following the **Nordic Yellow** design language, the interface is minimal, fast, accessible, and high-contrast.

---

## ✨ Core Features

### 1. 📄 Multi-Engine Resume Parsing (`unpdf` + PDF.js + Mammoth)
* **Universal Format Ingestion:** Seamless drag-and-drop parsing for PDF, DOCX, DOC, and TXT documents.
* **4-Tier Parsing Cascade:** Powered by `unpdf` (Mozilla PDF.js by UnJS) with automatic CMap font decoding, handling kerning arrays (`TJ`), UTF-16 streams, and complex multi-column resumes.
* **Smart Contact Extraction:** Multi-pattern extraction for standard, spaced-out, and obfuscated contact emails with zero-friction inline fallback.

### 2. 🎯 Dimensional ATS Scoring & Audit (0–100)
* **Keyword Density & Gap Analysis:** Identifies critical technical skills, tools, and domain keywords present in job descriptions but absent from the resume.
* **Structural Formatting Compliance:** Verifies headings, chronological structure, and parser readability.
* **Action Verbs & Impact:** Evaluates quantifiable achievements, scale metrics, and strong action verbs.
* **Actionable Recommendations:** Delivers prioritized, itemized suggestions to boost resume discoverability.

### 3. 🧩 1-Click Browser Extension (Chrome Manifest V3)
* **Instant Job Clipping:** Clip job listings directly from **LinkedIn, Indeed, Bayt.com, NaukriGulf, Glassdoor, and Greenhouse**.
* **Zero-Context Switching:** Automatically analyzes candidate compatibility and syncs live job postings into the pipeline with a single click.

### 4. ✍️ AI-Powered Application Generation Suite
* **Tailored Cover Letters:** Generates context-aware, 3-paragraph cover letters addressing specific company requirements.
* **Bullet Point Upgrades:** Proposes high-impact resume bullet rewrites tailored to target roles.
* **Recruiter Outreach Drafts:** Produces concise LinkedIn connection requests (<300 characters) and InMail messages.
* **Follow-Up Emails:** Pre-drafts post-application, post-interview, and status check emails.

### 5. 📊 Application Pipeline CRM & Funnel Analytics
* **6-Stage Pipeline Board:** Organize active opportunities across `Wishlist` → `Applied` → `Screening` → `Interview` → `Offer` → `Archived`.
* **Interview Scheduling & Notes:** Store recruiter contacts, interview dates, and preparation notes.
* **Funnel Analytics:** Real-time visibility into application velocity, response rates, and interview-to-offer conversions.

---

## 🎨 Nordic Yellow Design System

Designed for speed, low cognitive load, and accessibility:

* **Primary Deep Navy (`#003399`):** Headers, navigation, and primary focus areas.
* **Accent Warm Yellow (`#FFDA1A`):** High-visibility badges, score callouts, and key interaction points.
* **Canvas Light (`#F5F5F5`):** Low-glare background surfaces.
* **Surface White (`#FFFFFF`):** High-contrast cards and reading panes.
* **Success Green (`#0A8A00`):** Score badges and status indicators.
* **Typography:** `Noto Sans` for clean legibility paired with `JetBrains Mono` for tabular metrics and tokens.

---

## 🛠️ Tech Stack

| Layer | Technology |
| :--- | :--- |
| **Framework** | [Next.js 16](https://nextjs.org/) (App Router, Server Actions, Standalone Build) |
| **UI & Components** | [React 19](https://react.dev/), [Tailwind CSS v4](https://tailwindcss.com/) |
| **Document Processing**| [`unpdf`](https://github.com/unjs/unpdf) (PDF.js), [`pdf-parse`](https://www.npmjs.com/package/pdf-parse), [`mammoth`](https://www.npmjs.com/package/mammoth) (DOCX) |
| **Database & ORM** | [PostgreSQL (Neon Serverless)](https://neon.tech/) with [Prisma 5](https://www.prisma.io/) |
| **AI Inference** | Multi-engine SDK compatible with [DeepSeek](https://www.deepseek.com/), [Groq](https://groq.com/), and [OpenAI](https://openai.com/) |
| **Authentication** | [NextAuth v4](https://next-auth.js.org/) (Secure bcrypt password hashing) |
| **Email Delivery** | [Resend](https://resend.com/) for transactional password resets and notifications |
| **Browser Extension** | Chrome Manifest V3 (Dynamic bundle generator, Content Scripts, Service Worker) |
| **Analytics** | Privacy-focused telemetry via [Umami](https://umami.is/) |

---

## 🚀 Getting Started

### Prerequisites

* **Node.js**: `20.x` or later
* **npm** or **pnpm**
* **PostgreSQL Database** (e.g., [Neon](https://neon.tech/) free tier)

### 1. Clone the repository
```bash
git clone https://github.com/samah3303/paniund.git
cd paniund
```

### 2. Install dependencies
```bash
npm install
```

### 3. Configure environment variables
Create a `.env` file in the project root:
```env
# Database
DATABASE_URL="postgresql://user:password@ep-sample-pooler.neon.tech/paniund?sslmode=require"

# NextAuth Configuration
NEXTAUTH_URL="http://localhost:3000"
NEXTAUTH_SECRET="generate-a-secure-secret-with-openssl-rand-base64-32"

# AI Inference (DeepSeek, Groq, or OpenAI)
DEEPSEEK_API_KEY="your-deepseek-api-key"
DEEPSEEK_BASE_URL="https://api.deepseek.com"

# Transactional Email (Resend)
RESEND_API_KEY="re_your_resend_api_key"
EMAIL_FROM="paniund <noreply@yourdomain.com>"
```

### 4. Setup Database Schema
```bash
npx prisma generate
npx prisma db push
```

### 5. Launch Development Server
```bash
npm run dev
```

Visit [http://localhost:3000](http://localhost:3000) in your browser.

---

## 🔒 Privacy & Security

* **Zero Public AI Training:** Candidate resume data is never used to train public LLM models.
* **No Commercial Data Resale:** We do not sell candidate data to recruitment brokers or third parties.
* **Encrypted at Rest & in Transit:** All network traffic is enforced over TLS 1.3 with strict CSP headers, HSTS, and X-Content-Type protections.
* **User Data Sovereignty:** Users can export or permanently delete their account and resumes at any time.

---

## 📄 License

This project is open-source under the [MIT License](LICENSE).
