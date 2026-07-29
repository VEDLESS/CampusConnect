import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/presentation/auth_providers.dart';
import '../../../widgets/app_feature_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
    appBar: AppBar(
      title: const Text('CampusConnect'),
      actions: [
        IconButton(
          onPressed: () => ref.read(authRepositoryProvider).signOut(),
          icon: const Icon(Icons.logout),
          tooltip: 'Sign out',
        ),
      ],
    ),
    body: ListView(
      padding: const EdgeInsets.all(20),
      children: const [
        Text(
          'Your campus, connected.',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
        ),
        SizedBox(height: 8),
        Text('Discover what matters around campus.'),
        SizedBox(height: 20),
        AppFeatureCard(
          icon: Icons.event_outlined,
          title: 'Events',
          description: 'Find upcoming campus events and registrations.',
        ),
        AppFeatureCard(
          icon: Icons.menu_book_outlined,
          title: 'Notes',
          description: 'Share, search, and download study materials.',
        ),
        AppFeatureCard(
          icon: Icons.storefront_outlined,
          title: 'Marketplace',
          description: 'Buy and sell books, electronics, and essentials.',
        ),
        AppFeatureCard(
          icon: Icons.search_outlined,
          title: 'Lost & Found',
          description: 'Help reunite items with their owners.',
        ),
      ],
    ),
  );
}
