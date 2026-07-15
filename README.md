# ALU Venture Connect

A Flutter and Firebase mobile application that connects African Leadership University (ALU) students seeking internship experience with student-led startups and early-stage ventures on campus.

Students discover and apply to opportunities posted by verified startups, and both sides communicate through a built-in real-time messaging system. The app is built with **Clean Architecture** and the **BLoC** state-management pattern on a **Cloud Firestore** backend.

---

## Features

- **Authentication & onboarding** — email/password sign-up and login with a role (student or startup admin) chosen at registration.
- **Startup profiles & verification** — startups create profiles; only verified startups can post opportunities. Verification is an administrative action (set in the Firebase console), so no client can self-verify.
- **Opportunity posting** — verified startups post roles with a title, description, role type, and tags.
- **Opportunity discovery & search** — a home feed plus an explore screen with category filters and search.
- **Application submission with a form** — students apply through a dedicated form (role/skills, cover message, portfolio link), with input validation. Applicant name is taken from the account and cannot be faked.
- **Duplicate-application guard** — a student who has already applied sees a confirmation state instead of the apply button; this state is derived from the live Firestore stream, so it survives app restarts.
- **Two-sided real-time messaging** — students and startups message each other in the context of an application; messages appear in real time with no manual refresh, and the conversation list shows live last-message previews.
- **Role-aware UI** — the same screens present different content and actions for students versus startup admins.

---

## Tech Stack

| Area | Technology |
|---|---|
| Framework | Flutter (Dart) |
| Backend | Firebase Authentication, Cloud Firestore |
| State management | BLoC (`flutter_bloc`) |
| Dependency injection | GetIt |
| Value equality | Equatable |
| Architecture | Clean Architecture (domain / data / presentation), feature-first |

---

## Architecture

The project uses Clean Architecture, organised feature-first. Each feature (`auth`, `startup_profile`, `opportunities`, `applications`, `messaging`) is split into three layers:

```
lib/
├── core/
│   ├── di/                 # GetIt dependency injection setup
│   └── theme/              # app-wide theme / design tokens
└── features/
    └── <feature>/
        ├── domain/         # entities, repository interfaces, use cases
        ├── data/           # datasources, models, repository implementations
        └── presentation/   # BLoC (event/state), pages/widgets
```

Dependencies point inward toward the domain layer, which has no knowledge of Flutter or Firebase. The data layer is the only layer that depends on Firestore. See the technical report for full architecture and schema diagrams.

---

## Requirements

- **Flutter SDK** — `[VERIFY: run `flutter --version` and paste your version, e.g. 3.x.x]`
- **Dart SDK** — bundled with Flutter `[VERIFY]`
- A configured **Firebase project** (Authentication + Cloud Firestore enabled)
- An Android emulator or physical device (the app is intended to run on a device/emulator, not a browser)
- Android Studio or VS Code with the Flutter and Dart plugins

---

## Getting Started

### 1. Clone the repository

```bash
git clone https://github.com/DaVinci34162/ALU-Venture-Connect.git
cd ALU-Venture-Connect
```

### 2. Install dependencies

```bash
flutter pub get
```

### 3. Set up Firebase

This repository does **not** include Firebase configuration files (`google-services.json`, `firebase_options.dart`) because they are project-specific credentials and are excluded via `.gitignore`. To run the app you must connect it to a Firebase project of your own:

1. Create a Firebase project at [console.firebase.google.com](https://console.firebase.google.com).
2. Enable **Authentication** (Email/Password provider) and **Cloud Firestore**.
3. Configure the app with the FlutterFire CLI:
   ```bash
   dart pub global activate flutterfire_cli
   flutterfire configure
   ```
   This generates `lib/firebase_options.dart` and the platform config files.
4. Apply the Firestore **security rules** (see below) and create the required **composite index** (see below).

### 4. Run the app

```bash
flutter run
```

> **Note:** After changing dependency-injection registrations or Firebase configuration, use a full restart (`R`) rather than hot reload (`r`).

---

## Firestore Security Rules

The application relies on security rules that restrict access appropriately (a student reads their own applications, a startup owner reads applications submitted to their startup, and messages are readable only by the two parties to a conversation). The full rules are included in the technical report (Appendix A) and should be pasted into the Firebase console under **Firestore Database → Rules** before running.

## Required Composite Index

The startup-side conversations query requires a composite index on the `applications` collection:

| Collection | Field 1 | Field 2 |
|---|---|---|
| `applications` | `startupOwnerUid` (Ascending) | `submittedAt` (Descending) |

The first time this query runs, Firestore prints a console link that creates this index automatically; alternatively, add it manually under **Firestore Database → Indexes**.

---

## Firestore Data Model

| Collection | Description |
|---|---|
| `users` | One document per user (`uid`, `email`, `name`, `role`) |
| `startups` | Startup profiles (`name`, `description`, `verified`, `createdBy`) |
| `opportunities` | Roles posted by startups (`title`, `roleType`, `description`, `tags`, `status`, `startupId`, `startupName`) |
| `applications` | Student applications (`opportunityId`, `studentId`, `startupOwnerUid`, applicant details, `status`, `submittedAt`) |
| `applications/{id}/messages` | Chat messages, as a subcollection of each application |
| `notifications` | Per-user notifications |


---

## Project Status

This project was built as an individual final project for a Flutter development course. It is a functional prototype; known limitations and planned improvements (automated tests, server-side timestamps, a dedicated applicant-details view, in-app startup verification) are documented in the technical report.

---

