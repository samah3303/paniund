# 📋 Task Prompt — Phase 2: Flutter Scaffolding & Nordic Design System

> **Phase:** 2 of 6  
> **Target:** Flutter App (`mobile/`)  
> **Goal:** Initialize the Flutter mobile application in `/mobile`, configure Riverpod 2.x, set up GoRouter with route guards, configure the Dio HTTP client with JWT interceptor, and implement the complete Nordic Yellow design system with reusable atomic UI components.

---

## 🎯 Objectives

1. Create a Flutter project inside `mobile/` with bundle identifier `com.paniund.app`.
2. Configure `pubspec.yaml` with core dependencies (Riverpod, Dio, GoRouter, Secure Storage, Google Fonts).
3. Implement the **Nordic Yellow** theme system (`NordicColors`, `NordicTypography`, `NordicTheme`).
4. Set up the `DioClient` with base URL configuration and a `QueuedInterceptor` that attaches `Authorization: Bearer <token>` from `FlutterSecureStorage`.
5. Implement `GoRouter` with navigation shell, bottom navigation bar, and authentication redirect logic.
6. Build reusable atomic UI widgets in `lib/shared/`:
   - `NordicButton` (Primary yellow-accented, Navy outline, Ghost)
   - `NordicCard` (High-contrast surface, clean border, subtle shadow)
   - `ScoreBadge` & `AtsScoreMeter` (Color-coded 0-100 score indicator)
   - `NordicTextField` (Input with clean borders and active Navy outline)
   - `LoadingIndicator` (Minimalist Nordic spinner)

---

## 📂 Directory Structure to Establish

```
mobile/
├── pubspec.yaml
├── lib/
│   ├── main.dart
│   ├── core/
│   │   ├── constants/
│   │   │   ├── api_endpoints.dart
│   │   │   └── storage_keys.dart
│   │   ├── network/
│   │   │   ├── api_client.dart
│   │   │   ├── auth_interceptor.dart
│   │   │   └── api_response.dart
│   │   ├── router/
│   │   │   ├── app_router.dart
│   │   │   └── route_names.dart
│   │   ├── storage/
│   │   │   └── secure_storage_service.dart
│   │   └── theme/
│   │       ├── nordic_colors.dart
│   │       ├── nordic_typography.dart
│   │       └── nordic_theme.dart
│   └── shared/
│       ├── widgets/
│       │   ├── nordic_button.dart
│       │   ├── nordic_card.dart
│       │   ├── nordic_text_field.dart
│       │   ├── ats_score_meter.dart
│       │   └── status_pill.dart
│       └── scaffold/
│           └── app_scaffold.dart          # Bottom navigation shell
```

---

## 📝 Detailed Implementation Steps

### 1. `pubspec.yaml` Configuration
Include:
```yaml
name: paniund
description: "Intelligent Career & ATS Workspace Mobile App"
publish_to: "none"
version: 1.0.0+1

environment:
  sdk: ">=3.3.0 <4.0.0"

dependencies:
  flutter:
    sdk: flutter
  flutter_riverpod: ^2.6.1
  riverpod_annotation: ^2.6.1
  dio: ^5.7.0
  flutter_secure_storage: ^9.2.2
  go_router: ^14.6.2
  google_fonts: ^6.2.1
  flutter_animate: ^4.5.2
  file_picker: ^8.1.7
  open_filex: ^4.5.0
  receive_sharing_intent: ^1.8.1
  share_plus: ^10.1.2
  intl: ^0.19.0
  uuid: ^4.5.1

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^5.0.0
  build_runner: ^2.4.13
  riverpod_generator: ^2.6.2
```

### 2. Nordic Color Palette (`lib/core/theme/nordic_colors.dart`)
```dart
import 'package:flutter/material.dart';

class NordicColors {
  // Brand Colors
  static const Color navy = Color(0xFF003399);          // Primary Deep Navy
  static const Color navyDark = Color(0xFF002266);      // Active / Header
  static const Color yellow = Color(0xFFFFDA1A);        // Accent Warm Yellow
  static const Color yellowHover = Color(0xFFECC400);   // Yellow pressed
  
  // Surfaces & Backgrounds
  static const Color canvasLight = Color(0xFFF5F5F5);   // Background Light
  static const Color surfaceWhite = Color(0xFFFFFFFF);  // Card / Sheet surface
  static const Color borderLight = Color(0xFFE5E7EB);   // Clean border
  static const Color borderSubtle = Color(0xFFD1D5DB);
  
  // Text & Content
  static const Color textDark = Color(0xFF1A1A1A);      // Primary body
  static const Color textMuted = Color(0xFF6B7280);     // Secondary text
  
  // ATS Score & Status Tiers
  static const Color scoreHigh = Color(0xFF0A8A00);     // Score >= 80 (Green)
  static const Color scoreMed = Color(0xFFD97706);      // Score 60-79 (Amber)
  static const Color scoreLow = Color(0xFFDC2626);      // Score < 60 (Red)
  static const Color scoreHighBg = Color(0xFFE8F5E9);
  static const Color scoreMedBg = Color(0xFFFEF3C7);
  static const Color scoreLowBg = Color(0xFFFEE2E2);

  static Color getScoreColor(int score) {
    if (score >= 80) return scoreHigh;
    if (score >= 60) return scoreMed;
    return scoreLow;
  }
}
```

### 3. Typography & ThemeData (`lib/core/theme/nordic_theme.dart`)
- Configure `ThemeData.light()` using `GoogleFonts.notoSansTextTheme()`.
- Use `GoogleFonts.jetbrainsMono()` for numbers, scores, and tokens.
- Configure AppBar with deep navy background and white text.
- Configure `BottomNavigationBarThemeData` with Navy active icons and yellow accents.

### 4. Network Layer (`lib/core/network/`)
- Create `ApiClient` using `Dio(BaseOptions(baseUrl: ApiEndpoints.baseUrl, connectTimeout: 15s))`.
- Base URL should default to `https://paniund.com` with an easily swappable override (e.g. `http://10.0.2.2:3000` for Android emulator or `http://localhost:3000` for iOS simulator during local development).
- `AuthInterceptor` checks `SecureStorageService.getJwtToken()` and attaches `Authorization: Bearer $token` to every request.
- Handles 401 Unauthorized responses by clearing stored credentials and redirecting to `/login`.

### 5. Navigation Shell (`lib/core/router/app_router.dart`)
- Set up `StatefulShellRoute.indexedStack` with 4 bottom tabs:
  1. **Dashboard** (`/`) — Score summary & quick actions
  2. **Pipeline** (`/tracker`) — 6-stage application CRM
  3. **AI Suite** (`/generator`) — Cover letter & bullet generator
  4. **Profile** (`/profile`) — Resume text, skills, settings
- Route guard checks authentication state from Riverpod `authProvider`.

---

## ✅ Acceptance Criteria

1. Running `flutter run` compiles cleanly without warnings or errors.
2. Bottom navigation switches seamlessly between the 4 main tabs.
3. The Nordic Yellow design language is immediately recognizable (Navy top bars, warm yellow buttons/accents, crisp typography).
4. `Dio` requests automatically include the Bearer token when a user is logged in.
5. All shared UI components (`NordicButton`, `NordicCard`, `AtsScoreMeter`) render consistently across both iOS and Android.
