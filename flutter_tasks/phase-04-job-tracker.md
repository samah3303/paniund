# 📋 Task Prompt — Phase 4: Job Tracker & Pipeline CRM

> **Phase:** 4 of 6  
> **Target:** Flutter App (`mobile/lib/features/tracker/`)  
> **Goal:** Build the mobile Application Pipeline CRM: a touch-optimized 6-stage tracker (*Wishlist → Applied → Screening → Interview → Offer → Archived*) with status transition sheets, interview scheduling, and funnel analytics.

---

## 🎯 Objectives

1. Connect to backend endpoints:
   - `GET /api/applications`
   - `POST /api/applications`
   - `PATCH /api/applications/[id]`
   - `DELETE /api/applications/[id]`
2. Implement a fluid, touch-friendly 6-stage Pipeline Board.
3. Build the Application Detail Sheet with:
   - 2-tap stage switcher
   - Interview date & time picker (with device calendar integration)
   - Recruiter contact info and interview prep notes
   - Quick access to launch AI Generator for this job
4. Build the "Add Job / Application" dialog (manual entry or URL clipper).
5. Display Funnel Analytics (total applications, interview rate, active offers).

---

## 📂 Files to Create

```
mobile/lib/features/tracker/
├── data/
│   ├── tracker_repository.dart
│   └── models/
│       ├── application_model.dart
│       └── job_model.dart
├── presentation/
│   ├── controllers/tracker_controller.dart
│   ├── screens/
│   │   ├── tracker_screen.dart
│   │   └── application_detail_screen.dart
│   └── widgets/
│       ├── application_card.dart
│       ├── stage_segmented_bar.dart
│       ├── stage_picker_bottom_sheet.dart
│       ├── interview_date_dialog.dart
│       └── add_application_modal.dart
```

---

## 📝 Detailed Implementation Steps

### 1. 6-Stage Pipeline Board (`tracker_screen.dart`)
- **Stage Navigation:**
  - Segmented control or scrollable tab bar showing all 6 stages:
    1. **Wishlist** (Saved opportunities)
    2. **Applied** (Sent applications)
    3. **Screening** (Recruiter phone/email screen)
    4. **Interview** (Technical / Onsite rounds)
    5. **Offer** (Job offers received)
    6. **Archived** (Closed or rejected)
  - Each tab includes a numerical pill badge showing the count of applications in that stage.
- **Application Card (`application_card.dart`):**
  - Company name & Job title.
  - ATS Match Score chip (e.g. `87% Match` in Green).
  - Interview date badge (highlighted in Yellow if upcoming within 48 hours).
  - Tap card → opens `ApplicationDetailScreen` or bottom sheet.
  - Swipe-to-action (e.g. swipe right to move to next stage; swipe left to archive).

### 2. Application Detail Screen (`application_detail_screen.dart`)
- **Header:** Company, Title, Location, Salary range, and days since applied.
- **Status Selector:**
  - Tap the current status pill to open `StagePickerBottomSheet` with haptic feedback.
  - Calls `TrackerRepository.updateStatus(applicationId, newStatus)`.
- **Interview Scheduler:**
  - Date & Time picker for upcoming rounds.
  - Form fields for `contactPerson` (recruiter email/name) and `notes`.
  - Auto-syncs changes to backend via `PATCH /api/applications/[id]`.
- **Linked AI Actions:**
  - Quick action buttons: *"Generate Cover Letter for this Role"*, *"Draft Follow-up Email"*.

### 3. Add New Opportunity Modal (`add_application_modal.dart`)
- Fast form allowing user to input:
  - Job Title (required)
  - Company Name (required)
  - Location & Salary (optional)
  - Job URL (optional)
  - Target Stage (defaults to `Wishlist` or `Applied`)
- Submits to `POST /api/applications` and updates local Riverpod state optimistically.

### 4. Funnel Stats Overview
- Compact metrics bar at the top of the tracker screen:
  - **Applied Count** | **Interview Rate %** | **Active Offers**
  - Provides quick motivation and visibility into job search velocity.

---

## ✅ Acceptance Criteria

1. All 6 stages correctly group and display applications fetched from `/api/applications`.
2. Changing an application's stage updates the server via `PATCH /api/applications/[id]` and updates the UI immediately with smooth animation.
3. Setting an interview date persists to the database and displays on the card.
4. Users can manually add a new application in under 15 seconds.
5. Deleting or archiving an application properly removes it from active views.
