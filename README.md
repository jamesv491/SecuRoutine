# SecuRoutine

SecuRoutine is a streak-based cybersecurity habit tracker built with Flutter and Firebase. Users complete short daily security tasks (password hygiene, two-factor authentication, account monitoring, phishing awareness) to build a streak, earn points, and level up over time.

Live app: [securoutine.web.app](https://securoutine.web.app)

## Team

- James Viola ([jamesv491](https://github.com/jamesv491)) — repo owner
- Harris Waheed ([harr566](https://github.com/harr566))
- Gia Hoang
- Phuc ([hghien2](https://github.com/hghien2))

Built for INFO 4290.

## Features

- Email/password registration and login (Firebase Authentication)
- Profile setup with experience level, age group, and security preference
- Daily task generation from a 19-task pool spanning 4 security categories, always including at least one task matching the user's preference
- Complete/Skip task actions with points and level tracking
- Streak engine — the streak only increases when every task in a day's set is completed with no skips, and resets if a full day is missed
- All streak and task-generation date logic is standardized to UTC
- Notifications tab with automatic task reminders and end-of-day streak warnings
- Dedicated Tasks and Settings tabs, with a persistent bottom navigation bar across all four tabs
- Production-mode Firestore Security Rules restricting each user to their own data
- Deployed to Firebase Hosting

## Tech Stack

- **Frontend:** Flutter (web-first, developed and tested via `flutter run -d edge`)
- **Backend:** Firebase Authentication + Cloud Firestore
- **Hosting:** Firebase Hosting

## Project Structure

```
SecuRoutine/
├── backend/
│   └── firebase/
│       └── docs/                     # backend/Firebase reference docs
├── frontend/
│   └── flutter_app/
│       ├── lib/
│       │   ├── assets/
│       │   │   └── data/
│       │   │       └── task_pool.json    # task definitions (loaded at runtime)
│       │   ├── data/
│       │   │   └── task_pool.dart        # legacy hardcoded task pool
│       │   ├── models/
│       │   ├── Modules/
│       │   ├── screens/
│       │   │   ├── login_screen.dart
│       │   │   ├── profile_setup_screen.dart
│       │   │   ├── main_shell.dart       # owns the bottom nav bar, switches between tabs
│       │   │   ├── dashboard_screen.dart
│       │   │   ├── tasks_screen.dart
│       │   │   ├── notifications_screen.dart
│       │   │   └── settings_screen.dart
│       │   ├── services/
│       │   │   └── auth_service.dart     # all Firebase Auth/Firestore logic
│       │   ├── firebase_options.dart
│       │   └── main.dart
│       ├── android/ ios/ linux/ macos/ web/ windows/   # platform-specific build folders
│       ├── test/
│       ├── build/                        # `flutter build web` output, deployed to Hosting
│       ├── firebase.json                 # per-app Hosting config
│       ├── pubspec.yaml
│       └── pubspec.lock
├── functions/                        # Cloud Functions (if/when used)
├── firebase.json                     # root Hosting config
├── .firebaserc
└── README.md
```

> Note: there are two `firebase.json` files in this repo, one at the repo root and one inside `frontend/flutter_app/`. Double check which one the `firebase deploy` command in your terminal is actually picking up (it uses whichever is in the current working directory), since only one of them needs its `"public"` path corrected to point at `build/web`.

> Also note: both `lib/data/task_pool.dart` (the original hardcoded list) and `lib/assets/data/task_pool.json` (the newer config file loaded by `loadTaskPool()`) currently exist in the repo. If `task_pool.dart` is no longer used anywhere, it's worth removing to avoid confusion about which one is the actual source of truth.

## Getting Started

### 1. Clone the repository
```bash
git clone https://github.com/jamesv491/SecuRoutine.git
cd SecuRoutine
```

### 2. Install Flutter
Install the Flutter SDK and confirm your setup:
```bash
flutter doctor
```

### 3. Install dependencies
```bash
cd frontend/flutter_app
flutter pub get
```

### 4. Set up Firebase
- Create a Firebase project in the [Firebase Console](https://console.firebase.google.com/)
- Enable **Authentication** with the Email/Password sign-in method
- Enable **Cloud Firestore** in production mode
- Add your Firebase web config to the Flutter project so it can reach your project's Authentication and Firestore instances

### 5. Deploy Firestore Security Rules
Rules restrict every user to reading and writing only their own `users/{uid}` document.
```bash
firebase deploy --only firestore:rules
```

### 6. Run locally
```bash
flutter run -d edge
```

### 7. Build and deploy
```bash
flutter build web
firebase deploy --only hosting
```
> Note: `firebase.json`'s `"public"` path must point to `frontend/flutter_app/build/web`, not the repository root — this misconfiguration previously caused the hosted site to serve the wrong content.

## Data Model

Each user document lives at `users/{uid}` in Firestore and includes:

| Field | Description |
|---|---|
| `display_name`, `experience_level`, `age_group`, `security_preference` | Profile info set during onboarding |
| `current_streak`, `total_points`, `current_level` | Progress tracking |
| `last_active_date`, `last_task_generation_date` | UTC date strings used for streak and task-refresh logic |
| `today_tasks` | Array of the current day's task set, each with a `status` of `pending`, `completed`, or `skipped` |

Notifications are stored per-user at `users/{uid}/notifications/{notifId}`, with deterministic IDs (e.g. `task_reminder_2026-07-27`) to prevent duplicate generation within the same UTC day.

## Known Issues

See the Bug Tracking Log in the Final Report for full details. As of this writing, one known issue is open:

- Registering a new account can fail after the task pool migration to `task_pool.json` (Bug 010) — under investigation.

## License

Built for academic purposes as part of INFO 4290.