import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../home/presentation/home_screen.dart';
import '../../../widgets/app_loading_view.dart';
import 'auth_providers.dart';
import 'sign_in_screen.dart';

class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final configured = ref.watch(firebaseConfiguredProvider);
    if (!configured) return const FirebaseSetupScreen();
    return ref
        .watch(authStateProvider)
        .when(
          data: (user) =>
              user == null ? const SignInScreen() : const HomeScreen(),
          loading: () => const AppLoadingView(),
          error: (error, _) => Scaffold(
            body: Center(child: Text('Authentication error: $error')),
          ),
        );
  }
}

class FirebaseSetupScreen extends StatelessWidget {
  const FirebaseSetupScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.cloud_off_outlined,
                  size: 64,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 20),
                Text(
                  'Connect Firebase to continue',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Run flutterfire configure after creating the CampusConnect Firebase project. Then rebuild the app.',
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
