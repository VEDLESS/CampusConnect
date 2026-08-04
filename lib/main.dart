import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'config/firebase_bootstrap.dart';
import 'core/campus_connect_app.dart';
import 'features/auth/presentation/auth_providers.dart';
import 'utils/mock_data_seeder.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final firebaseConfigured = await FirebaseBootstrap.initialize();
  if (firebaseConfigured) {
    // Async call to seed database if empty
    MockDataSeeder.seedIfEmpty();
  }
  runApp(
    ProviderScope(
      overrides: [
        firebaseConfiguredProvider.overrideWithValue(firebaseConfigured),
      ],
      child: const CampusConnectApp(),
    ),
  );
}
