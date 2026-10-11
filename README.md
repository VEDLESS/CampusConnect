# CampusConnect

CampusConnect is a Flutter-based campus community application scaffolded with Material 3, Riverpod for state management, GoRouter for navigation, and Firebase for backend services. It provides core campus features such as authentication, events, lost & found, marketplace, notes, and profiles — with Firebase Firestore for persistence, Firebase Storage for media, and Cloud Messaging for notifications.

## Features
- Email/password authentication and Google Sign-In
- Password reset and persistent "remember me" preference
- Cloud Firestore-backed feature modules (events, marketplace, notes, lost & found)
- Firebase Storage for file/media uploads
- Firebase Cloud Messaging (FCM) integration for push notifications
- Platform support: Android, iOS, Web, macOS, Linux, Windows

## Screenshots
- See `screen.png`, `screen2.png`, and `screen3.png` in the project root for example UI screenshots.

## Prerequisites
- Flutter SDK (recommended: latest stable channel). Install from https://flutter.dev
- Firebase CLI: `npm install -g firebase-tools` or https://firebase.google.com/docs/cli
- Dart & Flutter tools available in your PATH
- Optional: `flutterfire` CLI for generating `firebase_options.dart` (`dart pub global activate flutterfire_cli`)

## Quick Setup (Local Development)

1. Clone the repository (if not already local):

```bash
git clone https://github.com/VEDLESS/CPAD_Lab.git
cd CPAD_Lab/mark1
```

2. Install Flutter packages:

```bash
flutter pub get
```

3. Create a Firebase project (console.firebase.google.com) and enable:
- Authentication: Email/Password and Google Sign-In
- Cloud Firestore
- Firebase Storage
- Cloud Messaging (for push notifications)

4. Configure Firebase for this project. From the repo root run:

```bash
# Install/ensure flutterfire CLI is available
dart pub global activate flutterfire_cli

# Run the interactive configuration and select Android, iOS, Web
flutterfire configure
```

During `flutterfire configure` choose the Android application ID `com.campusconnect.app` and the iOS bundle ID `com.campusconnect.app` (or your own IDs if you registered different apps).

5. Add platform-specific Firebase config files (if not generated):
- Android: place `google-services.json` into `android/app/`
- iOS: place `GoogleService-Info.plist` into `ios/Runner/`

6. Deploy the included Firebase security rules (optional but recommended for real backend):

```bash
firebase use <your-project-id>
firebase deploy --only firestore:rules,storage
```

7. Run the app on a connected device or emulator:

```bash
flutter run
```

To run for a specific platform, use `-d` with a device id (e.g., `-d chrome` or `-d emulator-5554`).

## Building Releases

- Android APK/AAB:

```bash
flutter build apk --release
# or build app bundle for Play Store
flutter build appbundle --release
```

- iOS (on macOS):

```bash
flutter build ios --release
```

- Web:

```bash
flutter build web --release
```

## Testing

Run unit/widget tests:

```bash
flutter test
```

## Project Structure (high level)
- `lib/` — main Dart code and feature folders (auth, events, marketplace, notes, profile, etc.)
- `android/`, `ios/`, `web/`, `macos/`, `linux/`, `windows/` — platform integrations and native config
- `firebase.json`, `firestore.rules`, `storage.rules` — Firebase configuration and security rules
- `pubspec.yaml` — Dart/Flutter dependencies

## Environment & Secrets
- Do NOT commit private keys, credentials, or production `google-services.json` / `GoogleService-Info.plist` to the public repository. Use environment-specific config and CI/CD secret storage when releasing.

## Troubleshooting
- If Firebase initialization fails, ensure `firebase_options.dart` exists and matches your selected Firebase project or re-run `flutterfire configure`.
- For Google sign-in issues on Android, ensure your SHA-1 keys are registered in the Firebase console for the Android app.
- If push notifications do not arrive, check FCM setup and that the app requests notification permissions on the platform.

## Contributing
- Fork the repo, create a feature branch, implement changes, add tests where relevant, and open a pull request describing your changes.

## Feature Expansion Ideas

For future versions of CampusConnect, the following features are planned to meet the needs of college students (e.g. at VJTI Mumbai):

### 🎓 Academic & Study Features
*   **Smart Class Timetable & Sync**: A collaborative schedule manager synced to the home page with push reminders (10 mins before class).
*   **Attendance Optimizer (75% Tracker)**: Subject-wise logger indicating safe-skip thresholds for the 75% attendance rule.
*   **PYQ & Syllabus Hub**: Structured catalog of previous years' question papers and mid-sem solutions.
*   **Exam Countdown & Pomodoro Timer**: Multi-student Pomodoro session lobby.

### 🤝 Social & Community Features
*   **Anonymous Confession Board**: Moderated anonymous chat board for general thoughts and sharing.
*   **Lost & Found Smart Match**: Triggers auto-notifications when a lost item's details match a found item's details.
*   **Club Hub & RSVPs**: Directory pages for clubs (e.g. VJTI Racing, DLA) to handle registrations.

### 🍔 Campus Life & Utilities
*   **Canteen Pre-Ordering**: UPI payment menu ordering to skip cafeteria queues.
*   **AR Campus Navigator**: Guided department and classroom finder for freshmen.
*   **Eco-Commute Carpooling**: Rideshare coordination for Dadar/Matunga rail hubs.
*   **Library Occupancy Tracker**: Real-time capacity monitoring.

## License & Attribution
This repository does not include a license file. Add an appropriate `LICENSE` if you intend to permit reuse. The app scaffolding uses Flutter and community packages; consult individual package licenses in `pubspec.yaml`.