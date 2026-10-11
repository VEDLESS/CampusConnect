# CampusConnect -- Flutter Project Setup Guide

## Project Goal

Build a production-quality cross-platform Flutter application named
**CampusConnect** that works on Android and iOS using a single codebase.

------------------------------------------------------------------------

# 1. Install Required Software

## Flutter SDK

Already installed.

Verify:

``` bash
flutter doctor
```

------------------------------------------------------------------------

## Android Studio

Already installed.

------------------------------------------------------------------------

## VS Code

Install these extensions:

-   Flutter
-   Dart
-   GitHub Copilot
-   GitHub Copilot Chat
-   Error Lens
-   Pubspec Assist
-   Material Icon Theme

------------------------------------------------------------------------

## Git

Install Git:

https://git-scm.com

Verify:

``` bash
git --version
```

------------------------------------------------------------------------

## Node.js (Optional)

Install the latest LTS version.

Useful for Firebase CLI and Cloud Functions.

------------------------------------------------------------------------

# 2. Create a Firebase Project

Open:

https://console.firebase.google.com

Create a project named:

    CampusConnect

Enable:

-   Authentication
-   Cloud Firestore
-   Firebase Storage

Authentication providers:

-   Email & Password
-   Google Sign-In

------------------------------------------------------------------------

# 3. Install Firebase CLI

``` bash
npm install -g firebase-tools
```

Verify:

``` bash
firebase --version
```

------------------------------------------------------------------------

# 4. Install FlutterFire CLI

``` bash
dart pub global activate flutterfire_cli
```

Verify:

``` bash
flutterfire --version
```

------------------------------------------------------------------------

# 5. Configure Firebase

Inside the project folder:

``` bash
flutterfire configure
```

Select:

-   Android
-   iOS
-   Web

This generates:

    lib/firebase_options.dart

------------------------------------------------------------------------

# 6. Recommended Flutter Packages

``` yaml
firebase_core
firebase_auth
cloud_firestore
firebase_storage
firebase_messaging

flutter_riverpod

go_router

image_picker

cached_network_image

shared_preferences

flutter_svg

intl

uuid

connectivity_plus

fluttertoast

google_sign_in

permission_handler

file_picker

url_launcher

lottie

flutter_launcher_icons

flutter_native_splash
```

------------------------------------------------------------------------

# 7. Folder Structure

    lib/
    │
    ├── core/
    ├── config/
    ├── constants/
    ├── theme/
    ├── utils/
    ├── models/
    ├── services/
    ├── repositories/
    ├── features/
    │   ├── auth/
    │   ├── home/
    │   ├── events/
    │   ├── notes/
    │   ├── marketplace/
    │   ├── lost_found/
    │   └── profile/
    ├── widgets/
    ├── routes/
    └── main.dart

Avoid placing all code inside `main.dart`.

------------------------------------------------------------------------

# 8. Firestore Rules

-   Users can edit only their own profile.
-   Authenticated users can read posts.
-   Only the owner can delete their posts.
-   Images are stored in Firebase Storage.

------------------------------------------------------------------------

# 9. Initialize Git

``` bash
git init
git add .
git commit -m "Initial commit"
```

------------------------------------------------------------------------

# 10. State Management

Use:

-   Riverpod

Avoid:

-   Provider
-   GetX

------------------------------------------------------------------------

# Core Features

## Authentication

-   Email login
-   Google login
-   Forgot password
-   Remember me

## Home Feed

-   LinkedIn-style feed
-   Cards
-   Images
-   Likes
-   Comments
-   Sharing

## Events

-   Upcoming events
-   Registration
-   Calendar

## Notes

-   Upload PDFs
-   Search
-   Download
-   Semester filters

## Lost & Found

-   Item listing
-   Image upload
-   Location
-   Contact owner

## Marketplace

-   Buy
-   Sell
-   Books
-   Electronics
-   Calculator

## Chat

-   Real-time messaging
-   Online status
-   Image sharing
-   Read receipts

## Profile

-   Edit profile
-   Skills
-   Department
-   Semester
-   Bio
-   Social links

## Notifications

-   Push notifications
-   Local notifications

## Settings

-   Dark mode
-   Language
-   Privacy

------------------------------------------------------------------------

# Design Guidelines

-   Material 3
-   Responsive UI
-   Dark & Light themes
-   Rounded cards
-   Google Fonts
-   Reusable widgets
-   Smooth animations

------------------------------------------------------------------------

# Copilot Prompt

``` text
You are a senior Flutter software architect.

Build a production-quality Flutter application named CampusConnect.

Requirements:

• Flutter latest stable
• Material 3
• Clean Architecture
• Feature-first folder structure
• Riverpod for state management
• GoRouter for navigation
• Firebase Authentication
• Cloud Firestore
• Firebase Storage
• Firebase Cloud Messaging
• Responsive UI
• Dark and Light themes
• Reusable widgets
• SOLID principles
• Null Safety
• Error handling
• Loading and empty states
• Repository pattern
• Well-documented code
• No deprecated APIs

Folder structure:

lib/
 core/
 config/
 constants/
 theme/
 utils/
 models/
 services/
 repositories/
 features/
 widgets/
 routes/

Implement the project incrementally. First create the folder structure, routing, theme, Firebase initialization, authentication flow, and reusable UI components. Do not generate placeholder code for future features. Ensure every generated file compiles successfully before moving to the next module.
```

------------------------------------------------------------------------

# Recommended Development Milestones

1.  Project setup + Firebase
2.  Authentication
3.  Home feed
4.  User profiles
5.  Events
6.  Notes
7.  Marketplace
8.  Lost & Found
9.  Chat
10. Notifications
11. Testing, polishing, and deployment

> Build one milestone at a time instead of generating the entire
> application in one prompt. This results in cleaner code, easier
> debugging, and a project you can confidently explain in interviews.
