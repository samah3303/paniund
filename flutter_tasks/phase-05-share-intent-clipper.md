# 📋 Task Prompt — Phase 5: Native Share Intent (1-Tap Job Clipper)

> **Phase:** 5 of 6  
> **Target:** Flutter App (`mobile/lib/features/share_intent/` & Native Android/iOS Config)  
> **Goal:** Implement native OS Share Intent integration so users browsing job listings in mobile apps (LinkedIn, Indeed, Bayt, Glassdoor) can tap **Share → paniund** to automatically extract job specifications, compute an instant ATS match score, and clip the role into their pipeline.

---

## 🎯 Objectives

1. Configure Android `AndroidManifest.xml` with an `intent-filter` for `android.intent.action.SEND` (`text/plain`).
2. Configure iOS Share Extension / URL Scheme handling.
3. Use `receive_sharing_intent` to listen for shared content on cold launch and in the background.
4. Extract the job URL from the shared text string using URL regex.
5. Call backend `POST /api/jobs/parse-url` or `POST /api/extension/clip` to scrape the job details and calculate the candidate's ATS match score.
6. Present a high-contrast Nordic modal sheet showing:
   - Extracted Job Title & Company
   - Real-time ATS Match Score meter (0–100)
   - Matched Skills vs. Missing Skills chips
   - Quick action: "Save to Wishlist", "Save as Applied", or "Draft Cover Letter"

---

## 📂 Files to Create / Modify

```
mobile/
├── android/app/src/main/AndroidManifest.xml        # [MODIFY] Add intent filter
├── ios/Runner/Info.plist                           # [MODIFY] Add URL scheme & share config
└── lib/features/share_intent/
    ├── data/
    │   └── job_clipper_repository.dart
    ├── presentation/
    │   ├── controllers/share_intent_controller.dart
    │   └── widgets/
    │       ├── job_clip_preview_sheet.dart
    │       └── clip_skill_match_chips.dart
    └── services/
        └── share_intent_service.dart
```

---

## 📝 Detailed Implementation Steps

### 1. Android Native Configuration (`android/app/src/main/AndroidManifest.xml`)
Inside the main `<activity>` block:
```xml
<intent-filter>
    <action android:name="android.intent.action.SEND" />
    <category android:name="android.intent.category.DEFAULT" />
    <data android:mimeType="text/plain" />
</intent-filter>
```
This ensures paniund appears in the Android system share sheet whenever text or a URL is shared.

### 2. iOS Native Configuration (`ios/Runner/Info.plist`)
Register URL schemes and document sharing types:
```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>paniund</string>
        </array>
    </dict>
</array>
```

### 3. Share Intent Service (`lib/features/share_intent/services/share_intent_service.dart`)
Initialize `receive_sharing_intent` in the root app lifecycle:
```dart
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

class ShareIntentService {
  static void initialize({required Function(String url) onJobUrlReceived}) {
    // 1. Listen to shared text when app is in memory
    ReceiveSharingIntent.instance.getTextStream().listen((String text) {
      final url = _extractUrl(text);
      if (url != null) onJobUrlReceived(url);
    });

    // 2. Handle shared text when app was closed (cold boot)
    ReceiveSharingIntent.instance.getInitialText().then((String? text) {
      if (text != null) {
        final url = _extractUrl(text);
        if (url != null) onJobUrlReceived(url);
      }
    });
  }

  static String? _extractUrl(String text) {
    final urlRegExp = RegExp(
      r'((https?:\/\/)|(www\.))[^\s]+',
      caseSensitive: false,
    );
    final match = urlRegExp.firstMatch(text);
    return match?.group(0);
  }
}
```

### 4. Job Clipper Sheet (`job_clip_preview_sheet.dart`)
When a URL is received:
1. Show a loading overlay: *"Scraping job specifications & computing ATS compatibility..."*
2. Call `POST /api/jobs/parse-url` (or `/api/extension/clip`) passing `{ "url": sharedUrl }`.
3. Display the result in a bottom sheet:
   - **Header:** Company name, role title, and source badge (e.g. `LinkedIn`, `Indeed`).
   - **Score Callout:** Animated `AtsScoreMeter` with score (e.g. `85% Match`).
   - **Skills Comparison:**
     - 🟢 Matched Skills (e.g., `Flutter`, `Dart`, `REST APIs`)
     - 🔴 Missing / Desired Keywords (e.g., `CI/CD`, `GraphQL`)
   - **CTA Buttons:**
     - `Save to Pipeline` (calls `POST /api/applications` with status `wishlist` or `applied`).
     - `Create Cover Letter Now` (routes directly to AI Studio with pre-filled context).

---

## ✅ Acceptance Criteria

1. Sharing a link from the LinkedIn or Indeed mobile app displays **paniund** in the system share sheet.
2. Selecting paniund opens the app (both on cold start and background wake).
3. The app extracts the job posting URL, triggers backend parsing, and returns job details within 3 seconds.
4. The ATS match score displays accurately against the user's active resume.
5. Tapping "Save to Pipeline" successfully adds the job to the user's applications board with zero friction.
