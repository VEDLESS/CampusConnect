# CampusConnect

A Flutter campus community application built with Material 3, Riverpod, GoRouter, and Firebase.

## Run locally

1. Create a Firebase project named `CampusConnect`, then enable Authentication (Email/Password and Google), Cloud Firestore, Firebase Storage, and Cloud Messaging.
2. In this directory run `flutterfire configure` and select Android, iOS, and Web. Choose the Android application ID `com.campusconnect.app` and iOS bundle ID `com.campusconnect.app`.
3. Deploy the included secure access rules: `firebase use <your-project-id>` then `firebase deploy --only firestore:rules,storage`.
4. Run `flutter run`.

The project has email/password authentication, Google authentication, password reset, persistent remember-me preference, and Firebase-safe startup handling. Feature folders are prepared for the remaining milestone modules.