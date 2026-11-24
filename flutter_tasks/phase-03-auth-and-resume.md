# 📋 Task Prompt — Phase 3: Auth Flow & Resume ATS Audit

> **Phase:** 3 of 6  
> **Target:** Flutter App (`mobile/lib/features/auth/` & `mobile/lib/features/resume/`)  
> **Goal:** Build full mobile authentication (Login, Register, Session Restore) and implement the Resume ATS Audit flow (native document picker, multipart upload, multi-dimensional scoring display, and actionable recommendations).

---

## 🎯 Objectives

1. Build responsive, high-contrast Login & Register screens matching Nordic Yellow styling.
2. Manage session lifecycle using Riverpod (`AuthNotifier`) with token persistence in `FlutterSecureStorage`.
3. Implement document upload for PDF, DOCX, DOC, and TXT files using `file_picker`.
4. Upload file as `multipart/form-data` to `/api/resume/upload`.
5. Display the parsed resume data and ATS scoring audit:
   - Animated circular score gauge (0–100)
   - 4-dimensional breakdown bars (Formatting, Keyword Coverage, Action Verbs, Impact)
   - Prioritized, itemized recommendation cards
   - Extracted candidate skills chips

---

## 📂 Files to Create

```
mobile/lib/features/
├── auth/
│   ├── data/
│   │   ├── auth_repository.dart
│   │   └── models/user_model.dart
│   ├── presentation/
│   │   ├── controllers/auth_controller.dart
│   │   ├── screens/login_screen.dart
│   │   ├── screens/register_screen.dart
│   │   └── screens/forgot_password_screen.dart
│   └── domain/auth_state.dart
└── resume/
    ├── data/
    │   ├── resume_repository.dart
    │   └── models/
    │       ├── ats_audit_model.dart
    │       └── profile_model.dart
    ├── presentation/
    │   ├── controllers/resume_controller.dart
    │   ├── screens/
    │   │   ├── resume_overview_screen.dart
    │   │   └── resume_upload_screen.dart
    │   └── widgets/
    │       ├── dimensional_score_bar.dart
    │       ├── recommendation_card.dart
    │       └── skills_wrap.dart
```

---

## 📝 Detailed Implementation Steps

### 1. Auth Flow (`features/auth/`)
- **LoginScreen:**
  - Deep Navy header with paniund logo / icon.
  - Inputs for Email & Password with validation.
  - Accent Yellow `NordicButton` for "Log In".
  - Quick link to Register and Forgot Password.
  - Shows friendly inline errors on invalid credentials.
- **AuthController:**
  - Calls `AuthRepository.login(email, password)`.
  - On success, saves token in `SecureStorageService`, updates `AuthState(isAuthenticated: true, user: user)`, and navigates to `/`.
  - On startup (`initialize()`), checks if a valid token exists and automatically restores the session.

### 2. Resume Upload (`features/resume/presentation/screens/resume_upload_screen.dart`)
- **File Picker Interaction:**
  - Uses `FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf', 'docx', 'doc', 'txt'])`.
  - Displays selected file name, file size, and extension icon before uploading.
- **Multipart Upload Request:**
  - Sends POST to `/api/resume/upload` with `FormData.fromMap({'file': await MultipartFile.fromFile(file.path, filename: file.name)})`.
  - Shows progress bar during upload and parsing.
- **Parsing Feedback:**
  - Handled seamlessly; transitions directly to the ATS Audit screen upon successful parse response.

### 3. ATS Audit Display (`features/resume/presentation/screens/resume_overview_screen.dart`)
- **Score Meter:**
  - Displays the 0–100 ATS Score using `AtsScoreMeter`.
  - Color-coded:
    - 🟢 **80–100**: ATS Optimized
    - 🟡 **60–79**: Needs Minor Keyword / Formatting Improvements
    - 🔴 **< 60**: High Risk of ATS Rejection
- **Dimensional Breakdown:**
  - Renders 4 horizontal progress bars with labels:
    1. **Structural & Formatting (25% weight)**
    2. **Domain Keywords & Coverage (35% weight)**
    3. **Action Verbs & Impact (25% weight)**
    4. **Contact & Metadata Completeness (15% weight)**
- **Recommendations List:**
  - Itemized cards with priority badges (`High`, `Medium`, `Low`).
  - Example: *"Add 3+ quantifiable metrics to your senior experience bullet points"*.
- **Candidate Skills Cloud:**
  - Wrap widget displaying extracted technical and soft skills as interactive chips.

---

## ✅ Acceptance Criteria

1. User can successfully register and log in on an Android/iOS device/emulator.
2. Credentials and JWT token persist across app restarts (auto-login works).
3. User can select a PDF or DOCX file from device storage and upload it to `/api/resume/upload`.
4. The server returns the parsed resume and ATS breakdown, which renders correctly in the UI.
5. All scores and suggestions match the data returned by the backend without calculation discrepancies.
