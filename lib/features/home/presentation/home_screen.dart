import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/presentation/auth_providers.dart';
import '../../profile/presentation/profile_screen.dart';
import '../../events/presentation/events_screen.dart';
import '../../notes/presentation/notes_screen.dart';
import '../../marketplace/presentation/marketplace_screen.dart';
import '../../lost_found/presentation/lost_found_screen.dart';
import '../../calculator/presentation/calculator_screen.dart';
import '../../../widgets/app_feature_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
    appBar: AppBar(
      title: const Text('CampusConnect'),
      actions: [
        IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ProfileScreen()),
            );
          },
          icon: const Icon(Icons.person_outline),
          tooltip: 'My Profile',
        ),
        IconButton(
          onPressed: () => ref.read(authRepositoryProvider).signOut(),
          icon: const Icon(Icons.logout),
          tooltip: 'Sign out',
        ),
      ],
    ),
    body: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          'Your campus, connected.',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        const Text('Discover what matters around campus.'),
        const SizedBox(height: 20),
        AppFeatureCard(
          icon: Icons.event_outlined,
          title: 'Events',
          description: 'Find upcoming campus events and registrations.',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const EventsScreen()),
            );
          },
        ),
        AppFeatureCard(
          icon: Icons.menu_book_outlined,
          title: 'Notes',
          description: 'Share, search, and download study materials.',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const NotesScreen()),
            );
          },
        ),
        AppFeatureCard(
          icon: Icons.storefront_outlined,
          title: 'Marketplace',
          description: 'Buy and sell books, electronics, and essentials.',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const MarketplaceScreen()),
            );
          },
        ),
        AppFeatureCard(
          icon: Icons.search_outlined,
          title: 'Lost & Found',
          description: 'Help reunite items with their owners.',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const LostFoundScreen()),
            );
          },
        ),
        AppFeatureCard(
          icon: Icons.calculate_outlined,
          title: 'GPA Calculator',
          description: 'Estimate and calculate your Semester GPA and overall CGPA.',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CalculatorScreen()),
            );
          },
        ),
      ],
    ),
  );
}
