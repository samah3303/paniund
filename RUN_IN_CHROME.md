# How to Run the paniund Mobile App in Chrome

This guide explains how to set up and run the **paniund** Flutter app in Google Chrome after pulling this repository.

---

## 1. Prerequisites

Before starting, ensure you have the following installed on your machine:

1. **Node.js** (v18.x or v20.x+) & **npm**
2. **Flutter SDK** (Channel `stable`, version 3.22+ or newer)
   - Verify Flutter is on your PATH:
     ```bash
     flutter --version
     flutter doctor
     ```
   - Ensure the Chrome toolchain shows a checkmark: `[✓] Chrome - develop for the web`
3. **Google Chrome** browser

---

## 2. Step 1: Start the Next.js Backend

The Flutter mobile app relies on the Next.js API backend for authentication (JWT), resume audits, CRM job tracking, and AI generation.

1. In the root project directory, install dependencies:
   ```bash
   npm install
   ```

2. Make sure your environment variables are configured. If you don't have a `.env.local`, you can copy the example:
   ```bash
   cp .env.example .env.local
   ```

3. Start the Next.js development server:
   ```bash
   npm run dev
   ```
   > The backend API will start on **`http://localhost:3000`**. Keep this terminal running.

---

## 3. Step 2: Set Up the Flutter App

Open a new terminal window and navigate into the `mobile` directory:

```bash
cd mobile
```

Fetch and resolve all Dart/Flutter dependencies:

```bash
flutter pub get
```

---

## 4. Step 3: Run the App in Chrome

You have two simple ways to launch the app:

### Option A: Direct Flutter Chrome Runner (Recommended for Development)

This automatically launches a Chrome window connected to Flutter's hot-reload and debugging engine:

```bash
flutter run -d chrome --web-port 8088
```

> **Note on Hot Reload:** In the terminal running Flutter, press `r` to hot-reload changes or `R` to hot-restart.

---

### Option B: Web Server Mode (Recommended if you already have Chrome open)

If you already have Chrome open and want to use your existing browser profile without spawning a separate debugger instance:

```bash
flutter run -d web-server --web-port 8088
```

Once running, open Google Chrome and navigate to:
```
http://localhost:8088
```

---

### Option C: Production Web Build & Serve

To compile the optimized production web bundle:

```bash
# Inside the mobile/ folder:
flutter build web

# Serve the static build with npx serve (or python http.server):
npx serve build/web -l 8088
```

---

## 5. Summary of Ports & Architecture

| Service | Port | Description |
| :--- | :--- | :--- |
| **Next.js Backend** | `3000` | Authentication, JWT issuing, ATS audit engine, AI studio APIs |
| **Flutter Web Client** | `8088` | Flutter Nordic UI frontend running in Chrome |

---

## 6. Troubleshooting & Common Issues

### Issue 1: Port 8088 is already in use
If another process is using port 8088, you can specify any other port:
```bash
flutter run -d chrome --web-port 8089
```

### Issue 2: `flutter` command not found
Add the Flutter `bin` directory to your system environment `PATH`:
- **Windows**: Add `C:\Users\<YourUser>\flutter\bin` (or wherever your Flutter SDK was extracted) to User `PATH`.
- **macOS/Linux**: Add `export PATH="$PATH:$HOME/flutter/bin"` to `~/.bashrc` or `~/.zshrc`.

### Issue 3: Login or API calls fail
- Ensure the Next.js backend server (`npm run dev`) is actively running on port 3000.
- Check that the base URL in [api_endpoints.dart](file:///c:/Users/afsal/Desktop/work/ats-resume-optimizer/mobile/lib/core/constants/api_endpoints.dart) points to `http://localhost:3000`.
