import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/presentation/auth_providers.dart';
import '../../profile/presentation/profile_screen.dart';
import '../../profile/presentation/profile_providers.dart';
import '../../profile/presentation/connections_screen.dart';
import '../../chat/presentation/chat_list_screen.dart';
import '../../feed/presentation/feed_screen.dart';
import '../../events/presentation/events_screen.dart';
import '../../notes/presentation/notes_screen.dart';
import '../../marketplace/presentation/marketplace_screen.dart';
import '../../lost_found/presentation/lost_found_screen.dart';
import '../../calculator/presentation/calculator_screen.dart';
import '../../../models/campus_user.dart';
import '../../../widgets/app_feature_card.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  late PageController _pageController;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _onPageChanged(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _showUserSwapperDialog(BuildContext context) {
    final currentOverride = ref.read(developerOverrideUidProvider);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Simulate Campus User'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Select a user profile to swap sessions and test direct messaging/friends interaction:',
                  style: TextStyle(fontSize: 13),
                ),
                const SizedBox(height: 12),
                _buildSwapTile(context, 'Default (Firebase Auth)', null, currentOverride),
                _buildSwapTile(context, 'Alice Vance (CS Junior)', 'dummy_alice', currentOverride),
                _buildSwapTile(context, 'Bob Miller (EE Senior)', 'dummy_bob', currentOverride),
                _buildSwapTile(context, 'Charlie Day (ME Soph)', 'dummy_charlie', currentOverride),
                _buildSwapTile(context, 'Diana Prince (CE Fresh)', 'dummy_diana', currentOverride),
                _buildSwapTile(context, 'Evan Wright (BT Senior)', 'dummy_evan', currentOverride),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSwapTile(
    BuildContext context,
    String name,
    String? uid,
    String? currentUid,
  ) {
    final isSelected = currentUid == uid;
    return ListTile(
      title: Text(name, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
      leading: Icon(
        isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
        color: isSelected ? Theme.of(context).colorScheme.primary : null,
      ),
      onTap: () {
        ref.read(developerOverrideUidProvider.notifier).state = uid;
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Swapped to simulated user: $name')),
        );
      },
    );
  }

  Widget _buildDashboard(BuildContext context, CampusUser? currentProfile) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CampusConnect'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_alt_1_outlined),
            tooltip: 'Social Connections',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ConnectionsScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.chat_bubble_outline),
            tooltip: 'Direct Messages',
            onPressed: () {
              _onItemTapped(2); // Switch to DM tab (index 2)
            },
          ),
          IconButton(
            icon: const Icon(Icons.swap_horizontal_circle_outlined),
            tooltip: 'Swap User Session (Simulate)',
            onPressed: () => _showUserSwapperDialog(context),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            currentProfile != null
                ? 'Hello, ${currentProfile.displayName}!'
                : 'Your campus, connected.',
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          const Text('Discover what matters around campus.'),
          const SizedBox(height: 20),
          // Campus Banner Card
          Container(
            height: 180,
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              image: const DecorationImage(
                image: NetworkImage('vjti_mumbai_campus.png'),
                fit: BoxFit.cover,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withOpacity(0.7),
                    Colors.transparent,
                  ],
                ),
              ),
              padding: const EdgeInsets.all(16),
              alignment: Alignment.bottomLeft,
              child: const Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Veermata Jijabai Technological Institute',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'VJTI Mumbai • Estd. 1887',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
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

  @override
  Widget build(BuildContext context) {
    final currentProfile = ref.watch(userProfileProvider).value;

    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        children: [
          _buildDashboard(context, currentProfile),
          const FeedScreen(),
          const ChatListScreen(),
          const ProfileScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onItemTapped,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.feed_outlined),
            selectedIcon: Icon(Icons.feed),
            label: 'Buzz',
          ),
          NavigationDestination(
            icon: Icon(Icons.chat_bubble_outline),
            selectedIcon: Icon(Icons.chat_bubble),
            label: 'Messages',
          ),
          NavigationDestination(
            icon: Icon(Icons.account_circle_outlined),
            selectedIcon: Icon(Icons.account_circle),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
