# 📋 Task Prompt — Phase 6: AI Generation Suite & Final Polish

> **Phase:** 6 of 6  
> **Target:** Flutter App (`mobile/lib/features/ai_generator/` & `mobile/lib/features/profile/`)  
> **Goal:** Implement the AI Generation Suite (Cover Letters, Resume Bullets, LinkedIn Outreach, Follow-up Emails), complete the Profile & Settings manager, enable local caching, and perform final cross-platform build validation.

---

## 🎯 Objectives

1. Build the AI Application Generator Studio with 4 generation modes:
   - **Tailored Cover Letter** (`/api/generate/cover-letter`)
   - **Resume Bullet Points Upgrade** (`/api/generate/resume-updates`)
   - **LinkedIn Outreach Drafts** (`/api/generate/linkedin-message`)
   - **Follow-up Emails** (`/api/generate/followup-email`)
2. Support context pre-filling from any saved job in the pipeline.
3. Implement 1-tap Copy to Clipboard, native sharing (`share_plus`), and export.
4. Build the Profile & Settings screen:
   - Manage target roles & skills
   - Display and regenerate the user API Token (`pnd_...`)
   - Sign out and session revocation
5. Implement offline caching for viewed applications and resume data.
6. Conduct end-to-end responsiveness and build verification for Android and iOS.

---

## 📂 Files to Create

```
mobile/lib/features/
├── ai_generator/
│   ├── data/
│   │   ├── ai_generator_repository.dart
│   │   └── models/generation_request_model.dart
│   ├── presentation/
│   │   ├── controllers/ai_generator_controller.dart
│   │   ├── screens/ai_studio_screen.dart
│   │   └── widgets/
│   │       ├── generation_type_selector.dart
│   │       ├── generated_result_card.dart
│   │       └── copy_and_share_bar.dart
└── profile/
    ├── data/profile_repository.dart
    ├── presentation/
    │   ├── controllers/profile_controller.dart
    │   ├── screens/profile_screen.dart
    │   └── widgets/
    │       ├── target_roles_editor.dart
    │       ├── api_token_card.dart
    │       └── account_info_tile.dart
```

---

## 📝 Detailed Implementation Steps

### 1. AI Studio Interface (`ai_studio_screen.dart`)
- **Mode Selector Tabs:**
  - 📝 **Cover Letter:** Contextual 3-paragraph letter targeting the company's pain points.
  - 🎯 **Bullet Upgrade:** Transforms weak bullets into quantifiable impact metrics (*XYZ formula*).
  - 💼 **LinkedIn Outreach:** High-converting connection requests (<300 chars) and InMail messages.
  - ✉️ **Follow-Up Email:** Post-application check-in or post-interview thank you email.
- **Input Parameters:**
  - Target Role & Company Name
  - Job Description paste field (with auto-fill button if launched from an existing job in Tracker)
  - Tone Selector: *Professional*, *Confident*, *Concise*
- **Execution & Stream/Loader:**
  - Tactile animation during generation with informative status message (*"Synthesizing candidate profile with job requirements..."*).

### 2. Output Presentation (`generated_result_card.dart`)
- Clean Markdown/Text viewer in a Nordic surface card.
- Floating / persistent action bar:
  - 📋 **Copy All:** Copies content to clipboard and triggers haptic feedback + toast notification.
  - 📤 **Share:** Uses `SharePlus.share(content)` to export directly to Notes, Gmail, WhatsApp, or Slack.
  - 🔄 **Regenerate:** Request another variation with modified prompts.

### 3. Profile & Settings (`profile_screen.dart`)
- **Profile Header:** Candidate name, email, target roles chips, and overall ATS score badge.
- **Career Preferences:** Target job titles, preferred job types (Remote, Full-time), location.
- **API Token Management:**
  - Displays user's unique `pnd_...` API token.
  - Copy button for use in browser extensions or custom integrations.
  - "Regenerate Token" with confirmation dialog.
- **Logout:** Clears secure storage and resets Riverpod state to redirect to `/login`.

### 4. Local Caching & Error Handling
- Cache the latest profile and pipeline applications so users can view their job search progress on subways or flights without connectivity.
- Provide clean offline warning banners and graceful retry handling on failed network requests.

### 5. Final Quality Audit & Production Build
- Verify keyboard avoidance (`resizeToAvoidBottomInset: true` and scrollable forms).
- Test on both light and high-contrast modes.
- Verify clean build execution: `flutter analyze` with 0 issues.

---

## ✅ Acceptance Criteria

1. All 4 AI generation types generate valid, context-aware output from the backend.
2. Users can copy or share generated text in a single tap.
3. Profile screen allows updating target roles, skills, and viewing the API token.
4. Cached applications remain readable when Wi-Fi/cellular connection is turned off.
5. `flutter analyze` runs with zero warnings or errors.
