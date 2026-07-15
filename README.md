# ALU Venture Connect

A Flutter and Firebase mobile application that connects African Leadership University (ALU) students seeking internship experience with student-led startups and early-stage ventures across the ALU ecosystem.

ALU Venture Connect enables students to discover internship opportunities, apply directly through the platform, and communicate with startup founders in real time. The application is built using **Flutter**, **Firebase**, **Clean Architecture**, and **BLoC** state management to ensure scalability, maintainability, and a modern user experience.

---

# Features

- **Authentication & Onboarding** – Secure email/password registration and login using Firebase Authentication, with user roles (Student or Startup Admin).
- **Startup Profiles & Verification** – Student-led startups create organization profiles. Only verified startups can publish internship opportunities.
- **Opportunity Posting** – Startup administrators can create internship opportunities including title, description, role type, required skills, and tags.
- **Opportunity Discovery & Search** – Students can browse opportunities, search by keywords, and filter by categories.
- **Application Submission** – Students submit internship applications with their skills, portfolio link, and cover message.
- **Duplicate Application Protection** – Students cannot apply multiple times to the same opportunity.
- **Real-Time Messaging** – Applicants and startup administrators communicate through Firebase-powered live chat.
- **Role-Based Experience** – Different interfaces and permissions are provided for students and startup administrators.

---

# Technology Stack

| Area | Technology |
|------|------------|
| Framework | Flutter (Dart) |
| Backend | Firebase Authentication & Cloud Firestore |
| State Management | BLoC (`flutter_bloc`) |
| Dependency Injection | GetIt |
| Value Equality | Equatable |
| Architecture | Clean Architecture (Feature-first) |

---

# Project Architecture

The application follows **Clean Architecture** with a feature-first folder structure.

```
lib/
├── core/
│   ├── di/
│   └── theme/
│
└── features/
    ├── auth/
    ├── startup_profile/
    ├── opportunities/
    ├── applications/
    └── messaging/
        ├── domain/
        ├── data/
        └── presentation/
```

Each feature is separated into:

- **Domain Layer** – Business logic, entities, repositories, and use cases.
- **Data Layer** – Firebase models, repositories, and data sources.
- **Presentation Layer** – UI, Pages, Widgets, and BLoC state management.

This separation improves scalability, maintainability, and testing.

---

# Requirements

- Flutter SDK
- Dart SDK
- Firebase Project
- Firebase Authentication
- Cloud Firestore
- Android Studio or VS Code
- Android Emulator or Physical Android Device

---

# Getting Started

## Clone the Repository

```bash
git clone https://github.com/DaVinci34162/ALU-Venture-Connect.git
cd ALU-Venture-Connect
```

## Install Dependencies

```bash
flutter pub get
```

## Configure Firebase

This repository does **not** include Firebase configuration files (`google-services.json` and `firebase_options.dart`) because they contain project-specific credentials.

To configure Firebase:

1. Create a Firebase project.
2. Enable **Email/Password Authentication**.
3. Enable **Cloud Firestore**.
4. Run:

```bash
dart pub global activate flutterfire_cli
flutterfire configure
```

This will generate the required Firebase configuration files.

---

## Run the Application

```bash
flutter run
```

---

# Firestore Database Structure

| Collection | Description |
|------------|-------------|
| users | Stores registered users |
| startups | Startup profiles and verification status |
| opportunities | Internship opportunities created by startups |
| applications | Internship applications submitted by students |
| applications/{id}/messages | Real-time conversation between applicant and startup |
| notifications | User notifications |

---

# Main Features Demonstrated

- Firebase Authentication
- Cloud Firestore CRUD Operations
- Real-Time Data Synchronization
- Role-Based Access Control
- Clean Architecture
- BLoC State Management
- Responsive Flutter UI
- Firebase Backend Integration

---

# Future Improvements

Future versions of ALU Venture Connect could include:

- Push notifications
- AI-powered internship recommendations
- Interview scheduling
- Student portfolio integration
- Startup analytics dashboard
- Bookmarking opportunities
- CV upload support
- Advanced search and filtering

---

# Project Information

**Project Name:** ALU Venture Connect

**Developer:** Murengezi Gisanura DaVinci

**Course:** Flutter Mobile Application Development

**Institution:** African Leadership University (ALU)

---

# License

This project was developed for academic purposes as part of a Flutter Mobile Development course at the African Leadership University.
