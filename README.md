# Flutter LMS

A Learning Management System mobile application built with Flutter and Dart.

This repository contains **Phase 1 — the complete frontend UI** for an LMS
supporting three roles: **Student**, **Instructor**, and **Admin**. The backend
will be integrated in Phase 2.

---

## Status

**Phase 1 (UI only) — Complete**

- Full UI for Student, Instructor, and Admin roles
- Feature-based architecture
- Mock data driven — no backend calls yet
- Material Design 3, responsive layouts, reusable widgets
- Centralized routing, theming, and local form validation

Phase 2 will connect this UI to the real backend using Docker, Postman, and
Dio without restructuring the existing application.

---

## Roles and Features

### Student

- Splash, onboarding, login, registration, email verification (OTP)
- Forgot password and password reset
- Dashboard with stats, continue learning, upcoming assignments
- Browse and search published courses by category
- Course details with curriculum preview and enrollment action
- My Learning with progress tracking
- Learning page with sections and lessons
- Lesson rendering for **TEXT**, **VIDEO**, and **DOCUMENT** lessons
- Quiz list, attempt flow, result, and attempt history
- Assignment list, details, submission (text + file), resubmission
- Reviews (create, edit, delete)
- Notifications list, details, unread count, mark as read
- Profile, edit profile, account details, change password

### Instructor

- Dashboard with courses, learners, submissions, and revenue stats
- Course management (create, edit, publish, archive)
- Course thumbnail selection UI
- Sections (create, edit, reorder, delete)
- Lessons (TEXT / VIDEO / DOCUMENT) with media upload UI
- Quiz management (create, edit, publish, delete)
- Question management (multiple choice with correct-answer selector)
- Quiz attempts view
- Assignment management with attachments
- Submission review, grading, and resubmission requests
- Learner list and per-learner progress view
- Reviews view
- Profile, edit profile, account, change password

### Admin

- Dashboard with platform-wide statistics
- User management (list, search, filter, view details)
- Suspend and reactivate users
- Category management (create, edit, activate, deactivate)
- Course moderation (list, filter, view details, archive)
- Enrollment list and details
- Review moderation (hide, show)
- Profile, account details, change password

---

## Project Structure

lib/
├── main.dart
│
├── core/
│ ├── constants/ # App-wide constants, strings, asset paths
│ ├── routes/ # Centralized route names and router
│ ├── theme/ # Colors, typography, spacing, ThemeData
│ ├── utils/ # Validators, formatters, role helpers
│ └── widgets/ # Reusable widgets shared across features
│
├── features/
│ ├── auth/ # Splash, onboarding, login, registration, OTP
│ ├── student/ # Student presentation layer
│ ├── instructor/ # Instructor presentation layer
│ └── admin/ # Admin presentation layer
│
└── mock_data/
├── models/ # Typed models with fromJson/toJson stubs
└── *.dart # Realistic mock data per feature


### Design principles

- **Feature-based** — Student, Instructor, and Admin presentation layers
  never import from each other.
- **Shared code lives in `core/`** — nothing feature-specific leaks into
  the shared layer.
- **Backend-ready** — every model has `fromJson` / `toJson` stubs; enum
  `wireValue` getters match backend contract strings exactly.
- **No hardcoded backend IDs, tokens, or secrets.**

---

## Tech Stack

- **Flutter** (Dart 3)
- **Material Design 3**
- **google_fonts** — Inter typeface
- No state-management dependency in Phase 1 — plain `setState` and
  `ChangeNotifier` only

---

## Getting Started

### Prerequisites

- Flutter SDK 3.3 or later
- Dart 3.3 or later
- Android Studio / VS Code with the Flutter plugin
- A device or emulator (Android phone size recommended)

### Run

```bash
flutter pub get
flutter run

Static analysis
bash

flutter analyze

Build (Android)
bash

flutter build apk --release

Demo Login

Phase 1 uses mock authentication. Any valid email and password signs in
with the role selected on the login screen:
Role	How to log in
Student	Select Student on the login screen, enter any valid email + password
Instructor	Select Instructor on the login screen, enter any valid email + password
Admin	Select Admin on the login screen, enter any valid email + password

No real authentication happens in Phase 1.
Roadmap
Phase 1 — UI Only (current)

    Complete UI for all three roles

    Navigation, reusable widgets, local validation

    Mock data for every feature

Phase 2 — Backend Integration

    Dockerized backend and Postman contract validation

    Dio-based API client with interceptors

    Secure token storage and automatic refresh

    Real authentication and role-based routing

    Real API integration for Student, Instructor, and Admin

    Multipart uploads for thumbnails, media, and submission files

The backend contract (from the official API report and Postman collection)
is the source of truth during Phase 2. UI will not drive the contract.
License

This project is currently unlicensed and intended for portfolio and
internship evaluation purposes.
Author

Dilshan Wijayawardhane
github.com/Dilshan-wijayawardhane

