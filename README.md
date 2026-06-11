# SecuRoutine — Setup Guide
**Team:** James Viola · Gia Hoang · Harris Waheed 
**Course:** INFO 4290 — Group 2

SecuRoutine is a streak-based cybersecurity habit tracker built with **Flutter** (frontend) and **Firebase** (Authentication + Firestore). This guide walks every team member through setting up the development environment from scratch so the app runs locally.

> **Note:** GitHub only stores our source code. Tools (Flutter SDK, Firebase CLI), generated build files, and dependency packages are **not** in the repo — each member must install them locally by following the steps below.

---

## 1. Prerequisites — Install These Tools

Install the following before touching the project. The app currently runs on **web (Microsoft Edge or Chrome)**, so a mobile emulator is **not** required.

| Tool | Purpose | Where to get it |
|------|---------|-----------------|
| **Flutter SDK 3.44.1** | Builds and runs the app | https://docs.flutter.dev/get-started/install |
| **Git** | Clone the repo / push changes | https://git-scm.com/downloads |
| **VS Code** | Code editor | https://code.visualstudio.com/ |
| **VS Code Flutter extension** | Flutter tooling inside the editor | Install from the Extensions tab in VS Code |
| **Node.js + npm** | Required by Firebase CLI tools | https://nodejs.org/ (LTS version) |
| **Microsoft Edge or Chrome** | Runs the web build | Pre-installed on most machines |

### Verify Flutter is installed correctly

After installing Flutter and adding it to your PATH, run:

```powershell
flutter doctor
```

You should see check marks for **Flutter**, **VS Code**, and **a web browser (Edge/Chrome)**. It is **normal** to see a red mark for the Windows desktop toolchain (Visual Studio) — we are not building for Windows desktop, so you can ignore that.

---

## 2. Windows: Enable Developer Mode

Flutter on Windows needs symlink support to build Firebase plugins. Enable Developer Mode once:

```powershell
start ms-settings:developers
```

In the Settings window that opens, turn **Developer Mode** ON. No restart needed.

---

## 3. Clone the Repository

```powershell
git clone <YOUR_GITHUB_REPO_URL>
cd <repo-folder>
```

The Flutter project lives inside `frontend/flutter_app` (an earlier HTML/CSS/JS prototype lives in `frontend/`, which is why the Flutter app is nested rather than at the root). Move into it:

```powershell
cd frontend/flutter_app
```

---

## 4. Install Project Dependencies

From inside `frontend/flutter_app`, pull all the Dart/Flutter packages listed in `pubspec.yaml`:

```powershell
flutter pub get
```

This installs everything the project needs, including `firebase_core`, `firebase_auth`, and `cloud_firestore`. You do **not** need to add these manually — `flutter pub get` reads `pubspec.yaml` and downloads them all.

---

## 5. Firebase Setup

Our Firebase project is named **securoutine** and is already created and shared by the team. You do **not** need to create a new Firebase project.

### 5a. Install the Firebase tooling

```powershell
npm install -g firebase-tools
dart pub global activate flutterfire_cli
```

> **PowerShell tip:** If npm is blocked by an execution-policy error, run this once:
> ```powershell
> Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned
> ```

> **PATH tip:** If the `flutterfire` command is not recognized after install, either reopen VS Code so it picks up the updated PATH, or call it by full path, for example:
> ```powershell
> & "C:\Users\<your-user>\AppData\Local\Pub\Cache\bin\flutterfire.bat" configure --platforms=web
> ```

### 5b. Log in to Firebase

Log in with **the Google account that has access to the securoutine project** (ask the team which account this is — you must be added as a member in the Firebase Console first):

```powershell
firebase login
```

If you are already logged in with the wrong account:

```powershell
firebase logout
firebase login
```

### 5c. Generate the Firebase config file

The file `lib/firebase_options.dart` holds the keys that connect the app to Firebase. It may **not** be committed to GitHub, so generate it locally. From inside `frontend/flutter_app`:

```powershell
flutterfire configure --platforms=web
```

When prompted:
- **Select project:** choose `securoutine (SecuRoutine)`
- If asked to overwrite an existing `firebase_options.dart`, choose **yes**

This creates `lib/firebase_options.dart` configured for **web only** (we intentionally support web only for now to keep the config clean; the Windows desktop toolchain is unavailable anyway).

---

## 6. Run the App

From inside `frontend/flutter_app`:

```powershell
flutter run -d edge
```

(Use `-d chrome` instead if you prefer Chrome.)

A browser window opens with the SecuRoutine login screen. A red **DEBUG** banner in the corner is normal — it just means the app is running in debug mode.

### Test that everything works

1. Click the **Register** tab, enter a display name, a valid email (e.g. `test@gmail.com`), and a password of **at least 6 characters**, then click **Create Account**.
2. The app moves to **Profile Setup** — fill in the three dropdowns and click **Save Profile and Generate Tasks**.
3. You should land on the **Dashboard** showing "Welcome back, [name]".
4. To confirm the backend works, open the [Firebase Console](https://console.firebase.google.com/project/securoutine):
   - **Authentication → Users** should list the new account.
   - **Firestore Database → Data** should show a `users` collection with a document for the new user.

---

## 7. Project Structure (what you'll be working in)

Focus on the `lib/` directory — the rest of the generated Flutter project can be ignored for now.

```
frontend/flutter_app/
├── lib/
│   ├── main.dart                  # App entry point, initializes Firebase
│   ├── firebase_options.dart      # Firebase config (generated locally, NOT in repo)
│   ├── screens/
│   │   ├── login_screen.dart      # Login / Register UI
│   │   ├── profile_setup_screen.dart
│   │   └── dashboard_screen.dart  # "Welcome back" + STREAK
│   ├── services/
│   │   └── auth_service.dart      # Auth + Firestore logic
│   └── models/                    # (data models — to be added)
├── pubspec.yaml                   # Dependency list (committed to repo)
└── functions/                     # Intentionally left empty — task/streak
                                   # logic is handled client-side in services/
```

---

## 8. Common Issues & Fixes

| Problem | Fix |
|---------|-----|
| `flutter` not recognized | Flutter isn't on your PATH. Re-check the install guide and reopen the terminal. |
| `Building with plugins requires symlink support` | Enable Developer Mode (Section 2). |
| `flutterfire` not recognized | Reopen VS Code, or call it by its full path (Section 5a). |
| npm blocked by execution policy | Run the `Set-ExecutionPolicy` command (Section 5a). |
| App can't reach Firebase / `configuration-not-found` | You skipped `flutterfire configure`, or logged in with the wrong Google account. Redo Section 5. |
| `Target of URI doesn't exist: firebase_options.dart` | The config file wasn't generated. Run `flutterfire configure --platforms=web`. |
| Email rejected as "badly formatted" | The email must be a full valid address (e.g. `name@gmail.com`). |
| Build folder taking too much disk space | Run `flutter clean` to clear it; it rebuilds automatically next run. |

---

## 9. Quick Reference — Full Setup in Order

For a member who already has Flutter, Git, Node.js, and VS Code installed:

```powershell
# 1. Clone and enter the project
git clone <YOUR_GITHUB_REPO_URL>
cd <repo-folder>/frontend/flutter_app

# 2. Install dependencies
flutter pub get

# 3. Install Firebase tooling (first time only)
npm install -g firebase-tools
dart pub global activate flutterfire_cli

# 4. Log in with the team's Firebase account
firebase login

# 5. Generate the Firebase config (web only)
flutterfire configure --platforms=web
#    -> select "securoutine", overwrite if asked

# 6. Run
flutter run -d edge
```

---

