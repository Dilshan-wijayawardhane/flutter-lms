# Flutter LMS — Mobile Application

A cross-platform Learning Management System (LMS) mobile app built with
Flutter for three roles: **Student**, **Instructor**, and **Admin**.
Every screen is backed by a real REST API using Dio, with secure token
storage, automatic Bearer auth, and multipart file uploads.

---

## Table of Contents

- [Overview](#overview)
- [Tech Stack](#tech-stack)
- [Features by Role](#features-by-role)
- [Project Structure](#project-structure)
- [Getting Started](#getting-started)
- [Environment & Configuration](#environment--configuration)
- [API Integration](#api-integration)
- [State Management](#state-management)
- [Authentication](#authentication)
- [File Uploads](#file-uploads)
- [Folder Conventions](#folder-conventions)
- [Running the App](#running-the-app)
- [Testing the Flows](#testing-the-flows)
- [Roadmap](#roadmap)
- [License](#license)

---

## Overview

Flutter LMS is a mobile-first Learning Management System that supports
three distinct user roles. Each role has its own dashboard, navigation,
and set of features. The UI is consistent, responsive, and follows
Material 3 design principles.

The app was built in two phases:

1. **UI Phase** — complete visual layer with mock data.
2. **Backend Integration Phase** — every screen connected to a real
   REST API with Dio, secure token storage, and multipart uploads.

This repository contains the **integrated** application.

---

## Tech Stack

| Layer | Technology |
|---|---|
| Framework | Flutter (Dart 3) |
| State Management | `provider` |
| HTTP Client | `dio` |
| Secure Storage | `flutter_secure_storage` |
| Media Picking | `image_picker`, `file_picker` |
| MIME Detection | `mime`, `http_parser` |
| Typography | `google_fonts` (Inter) |
| Target Platforms | Android (primary), iOS (secondary) |

---

## Features by Role

### Student

- **Authentication** — register, verify email OTP, login, forgot/reset password
- **Dashboard** — enrolled courses, continue-learning card, stats, recommended courses
- **Courses** — browse published courses, search, filter by category, view details
- **Enrollment** — enroll in free/paid courses, view my learning
- **Learning** — curriculum, sections, lessons (TEXT / VIDEO / DOCUMENT), mark complete
- **Progress** — backend-driven course progress
- **Quizzes** — attempt quizzes, submit answers, view score, view attempt history
- **Assignments** — submit text or file, view feedback, resubmit when requested
- **Reviews** — view, create, delete course reviews
- **Notifications** — list, mark as read, mark all read, delete
- **Profile** — edit profile, upload profile image, change password, account details, logout

### Instructor

- **Dashboard** — total courses, learners, drafts, published, archived, quick actions
- **Course Management** — create, edit, publish, archive, delete, upload thumbnail
- **Sections** — create, edit, reorder, delete
- **Lessons** — create/edit TEXT, VIDEO, DOCUMENT lessons, upload media, publish, reorder, delete
- **Quizzes** — create quiz, edit, publish, manage questions, view student attempts
- **Assignments** — create, edit, publish, attach resources, view submissions, grade, request resubmission
- **Learners** — list enrollments per course, view learner progress
- **Reviews** — view course reviews
- **Profile** — edit profile, upload profile image, change password, account details, logout

### Admin

- **Dashboard** — platform-wide stats, recent users/courses/reviews/submissions, quick actions
- **Users** — list, search, filter by role/status, view details, suspend, reactivate
- **Categories** — create, edit, activate, deactivate
- **Courses** — list all courses, search, filter by status/category, view details, archive
- **Enrollments** — view enrollments per course, learner progress
- **Review Moderation** — hide/show reviews
- **Profile** — account details, change password, logout

---

## Project Structure

lib/

├── core/

│ ├── config/ # AppConfig — base URL, timeouts

│ ├── constants/ # App strings, sizes, asset paths

│ ├── errors/ # ApiException — clean error mapping

│ ├── network/ # ApiClient (Dio) + UploadService (multipart)

│ ├── routes/ # AppRoutes + AppRouter

│ ├── storage/ # TokenStorage (flutter_secure_storage)

│ ├── theme/ # Colors, text styles, spacing, ThemeData

│ ├── utils/ # Validators, formatters, media picker, LoadState

│ └── widgets/ # Reusable widgets shared across features

│
├── features/

│ ├── auth/

│ │ ├── data/

│ │ │ ├── models/ # LoginRequest, RegisterRequest, etc.

│ │ │ └── services/ # AuthService

│ │ ├── presentation/ # Pages and widgets
│ │ └── providers/ # AuthProvider

│ │
│ ├── student/

│ │ ├── data/

│ │ │ ├── models/ # Course, Lesson, Quiz, Assignment, etc.

│ │ │ └── services/ # CourseService, EnrollmentService, etc.

│ │ ├── presentation/ # Pages, widgets, StudentShell

│ │ └── providers/ # CourseProvider, EnrollmentProvider, etc.

│ │
│ ├── instructor/

│ │ ├── presentation/ # Pages, widgets, InstructorShell

│ │ └── providers/ # InstructorCourseProvider, etc.

│ │
│ └── admin/

│ ├── data/

│ │ └── services/ # AdminUserService

│ ├── presentation/ # Pages, widgets, AdminShell

│ └── providers/ # AdminUserProvider, AdminCourseProvider, etc.

│
└── main.dart # MultiProvider + MaterialApp


---

## Getting Started

### Prerequisites

- **Flutter SDK** ≥ 3.3.0
- **Dart SDK** ≥ 3.3.0
- **Android Studio** or **VS Code** with the Flutter extension
- **Android emulator** or a physical device
- The **backend API** running (see the backend repository)

### Clone the repository

```bash
git clone https://github.com/Dilshan-wijayawardhane/flutter-lms.git
cd flutter-lms
```

### Install dependencies
```bash

flutter pub get
```

### Environment & Configuration

The backend URL is set in lib/core/config/app_config.dart:

```bash

static const String baseUrl = 'http://10.0.2.2:5000';

```

Environment	          Base URL
-----
Android emulator	                               http://10.0.2.2:5000

iOS simulator	                                      http://localhost:5000

Physical device (LAN)	                          http://<your-lan-ip>:5000

Production	Set to your                         HTTPS host

---

Important: the base URL does not include /api/v1. Every endpoint path already carries that prefix.
API Integration

    All requests go through ApiClient (lib/core/network/api_client.dart).

    Every request automatically attaches Authorization: Bearer <token> when a session exists.

    Errors are converted into a single ApiException type with a clean message.

    File uploads go through UploadService using Dio's FormData.

No UI code calls Dio directly. Every screen goes through a provider → service → ApiClient chain.
State Management

The app uses provider with ChangeNotifier. One provider per feature area:

    AuthProvider — login, logout, session restore

    ProfileProvider — full profile for the logged-in user

    CourseProvider, CategoryProvider, EnrollmentProvider — student browsing + enrollment

    LearningProvider, LessonProvider — student learning experience

    QuizProvider, AssignmentProvider, ReviewProvider, NotificationProvider — student content

    InstructorCourseProvider, InstructorQuizProvider, InstructorAssignmentProvider, InstructorLearnerProvider — instructor tools

    AdminUserProvider, AdminCourseProvider, AdminEnrollmentProvider, AdminReviewProvider — admin tools

All providers share a common LoadState enum (lib/core/utils/load_state.dart):

```bash

enum LoadState { initial, loading, success, error }

```

### Authentication

    Login — POST /api/v1/auth/login

    Student registration — POST /api/v1/auth/register/student

    Instructor registration — POST /api/v1/auth/register/instructor

    Email verification — POST /api/v1/auth/verify-email

    Resend OTP — POST /api/v1/auth/resend-otp

    Forgot password — POST /api/v1/auth/forgot-password

    Reset password — POST /api/v1/auth/reset-password

    Logout — POST /api/v1/auth/logout

Tokens are stored in flutter_secure_storage (Keychain on iOS, EncryptedSharedPreferences on Android).

After login, the role determines which shell loads:

    STUDENT → StudentShell

    INSTRUCTOR → InstructorShell

    ADMIN → AdminShell

### File Uploads

Multipart endpoints handled by UploadService:

Feature	                    Endpoint	                                 Field
-

Profile image	                                       POST /api/v1/users/me/profile-image	                             image

Course thumbnail	                                POST /api/v1/courses/:id/thumbnail	                               thumbnail

Lesson video	                                        POST /api/v1/lessons/:id/video	                                       video

Lesson document	                                 POST /api/v1/lessons/:id/document                                document

Assignment attachment	                        POST /api/v1/assignments/:id/attachment	                    attachment

Student submission file	                         POST /api/v1/assignments/:id/submit/file	                     file

Replace submission file	                         POST /api/v1/assignments/:id/submission/file	              file




Upload progress is displayed via LinearProgressIndicator.


### Folder Conventions

    data/models/ — plain Dart classes with fromJson factories. No Flutter imports.

    data/services/ — thin wrappers over ApiClient. Only place that knows endpoint paths.

    presentation/pages/ — full screens. Named after the feature.

    presentation/widgets/ — feature-specific widgets.

    providers/ — ChangeNotifier state.

    core/widgets/ — shared widgets (used by 2+ features).

    core/theme/ — colors, text styles, spacing, ThemeData.

### Running the App

Start the backend first, then:

``` bash

flutter clean
flutter pub get
flutter analyze
flutter run
```

The app boots into the splash screen, checks for a saved session, and either
restores the session or routes to onboarding → login.

### Demo accounts

Use the backend's seeded accounts (e.g. from a .env or seed script) or
register a new student account and verify the OTP from the backend logs.

### Testing the Flows

### Student

    Register → verify OTP → login

    Browse courses → open details → enroll → open learning page

    Open a lesson (TEXT / VIDEO / DOCUMENT) → mark complete

    Open an assignment → submit text or file → view feedback

    Take a quiz → view score + attempt history

    Profile → edit → upload profile image

### Instructor

    Login → dashboard

    Courses → create course → add sections → add lessons → publish

    Quizzes → create quiz → add questions → publish

    Assignments → create → publish → grade submissions → request resubmission

    Learners → view enrollment list per course

### Admin

    Login → dashboard

    Users → search → filter → suspend / reactivate

    Categories → create / edit / activate / deactivate

    Courses → filter → view details → archive

    Reviews → hide / show

### Roadmap

The following are intentionally not implemented yet and can be added later:

    Automatic token refresh on 401 (retry interceptor)

    Pagination for long lists

    Offline caching / persistence

    Push notifications

    Dark theme

    Localization (i18n)

    Course video player

    Certificate generation

    Payment integration for paid courses

### License

This project is submitted as part of an internship task.
See the repository owner for licensing details.

### Built with Flutter · Powered by a Docker-based REST API









