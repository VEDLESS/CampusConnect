import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'connections_providers.dart';
import 'profile_providers.dart';
import '../../../models/campus_user.dart';

class ConnectionsScreen extends ConsumerStatefulWidget {
  const ConnectionsScreen({super.key});

  @override
  ConsumerState<ConnectionsScreen> createState() => _ConnectionsScreenState();
}

class _ConnectionsScreenState extends ConsumerState<ConnectionsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final usersAsync = ref.watch(allUsersProvider);
    final connectionsAsync = ref.watch(myConnectionsProvider);
    final currentUid = ref.watch(currentUserIdProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Social Connections'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'My Friends', icon: Icon(Icons.people_outline)),
            Tab(text: 'Requests', icon: Icon(Icons.mark_email_unread_outlined)),
            Tab(text: 'Find Users', icon: Icon(Icons.person_add_alt_1_outlined)),
          ],
        ),
      ),
      body: usersAsync.when(
        data: (allUsers) {
          return connectionsAsync.when(
            data: (connections) {
              if (currentUid == null) {
                return const Center(child: Text('Please log in to manage connections.'));
              }

              // Filter users
              final otherUsers = allUsers.where((u) => u.id != currentUid).toList();

              // Helper maps
              final Map<String, String> connectionStatusMap = {}; // otherUid -> status
              final Map<String, String> connectionIdMap = {}; // otherUid -> connId

              for (var conn in connections) {
                final status = conn['status'] as String;
                final connId = conn['connectionId'] as String;
                final participants = List<String>.from(conn['userUids']);
                final otherUid = participants.firstWhere((id) => id != currentUid, orElse: () => '');
                if (otherUid.isNotEmpty) {
                  connectionStatusMap[otherUid] = status;
                  connectionIdMap[otherUid] = connId;
                }
              }

              // Split categories
              final myFriends = otherUsers.where((u) => connectionStatusMap[u.id] == 'accepted').toList();
              
              // Incoming requests
              final incomingRequests = otherUsers.where((u) {
                final status = connectionStatusMap[u.id];
                return status == 'pending_${u.id}_to_$currentUid';
              }).toList();

              return TabBarView(
                controller: _tabController,
                children: [
                  _buildFriendsTab(myFriends, connectionIdMap, theme),
                  _buildRequestsTab(incomingRequests, connectionIdMap, theme),
                  _buildFindUsersTab(otherUsers, connectionStatusMap, connectionIdMap, theme, currentUid),
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Error loading connections: $e')),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error loading users: $e')),
      ),
    );
  }

  Widget _buildFriendsTab(List<CampusUser> friends, Map<String, String> connIdMap, ThemeData theme) {
    if (friends.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 64, color: theme.colorScheme.primary.withOpacity(0.5)),
            const SizedBox(height: 12),
            Text('No friends added yet.', style: theme.textTheme.titleMedium),
            const SizedBox(height: 4),
            const Text('Go to "Find Users" to search and add campus friends.'),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: friends.length,
      itemBuilder: (context, index) {
        final friend = friends[index];
        final connId = connIdMap[friend.id]!;
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundImage: friend.photoUrl != null ? NetworkImage(friend.photoUrl!) : null,
              child: friend.photoUrl == null ? Text(friend.displayName?[0] ?? '') : null,
            ),
            title: Text(friend.displayName ?? 'Anonymous'),
            subtitle: Text('${friend.branch ?? 'No branch'} • Sem ${friend.semester ?? '?'}' ),
            trailing: IconButton(
              icon: const Icon(Icons.person_remove_outlined),
              color: theme.colorScheme.error,
              tooltip: 'Remove Friend',
              onPressed: () => _confirmRemoveFriend(friend.displayName ?? 'this user', connId),
            ),
          ),
        );
      },
    );
  }

  Widget _buildRequestsTab(List<CampusUser> requests, Map<String, String> connIdMap, ThemeData theme) {
    if (requests.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.mark_email_read_outlined, size: 64, color: theme.colorScheme.primary.withOpacity(0.5)),
            const SizedBox(height: 12),
            Text('No pending requests', style: theme.textTheme.titleMedium),
            const SizedBox(height: 4),
            const Text('Incoming friend requests will show up here.'),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: requests.length,
      itemBuilder: (context, index) {
        final requester = requests[index];
        final connId = connIdMap[requester.id]!;
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundImage: requester.photoUrl != null ? NetworkImage(requester.photoUrl!) : null,
              child: requester.photoUrl == null ? Text(requester.displayName?[0] ?? '') : null,
            ),
            title: Text(requester.displayName ?? 'Anonymous'),
            subtitle: Text('${requester.branch ?? 'No branch'} • Sem ${requester.semester ?? '?'}' ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.check_circle_outline),
                  color: Colors.green,
                  tooltip: 'Accept Request',
                  onPressed: () {
                    ref.read(connectionsRepositoryProvider).acceptFriendRequest(connId);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.cancel_outlined),
                  color: theme.colorScheme.error,
                  tooltip: 'Decline Request',
                  onPressed: () {
                    ref.read(connectionsRepositoryProvider).removeConnection(connId);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFindUsersTab(
    List<CampusUser> users,
    Map<String, String> connStatusMap,
    Map<String, String> connIdMap,
    ThemeData theme,
    String currentUid,
  ) {
    final query = _searchController.text.toLowerCase().trim();
    final filtered = users.where((u) {
      final name = (u.displayName ?? '').toLowerCase();
      final username = (u.username ?? '').toLowerCase();
      final branch = (u.branch ?? '').toLowerCase();
      return name.contains(query) || username.contains(query) || branch.contains(query);
    }).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search by name, username, or branch...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: query.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () => setState(() => _searchController.clear()),
                    )
                  : null,
              border: const OutlineInputBorder(),
            ),
            onChanged: (val) => setState(() {}),
          ),
        ),
        Expanded(
          child: filtered.isEmpty
              ? const Center(child: Text('No users found matching query.'))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final user = filtered[index];
                    final status = connStatusMap[user.id];
                    final connId = connIdMap[user.id];

                    Widget actionButton;
                    if (status == null) {
                      actionButton = ElevatedButton.icon(
                        onPressed: () {
                          ref.read(connectionsRepositoryProvider).sendFriendRequest(currentUid, user.id);
                        },
                        icon: const Icon(Icons.person_add_alt_1, size: 16),
                        label: const Text('Add'),
                      );
                    } else if (status == 'accepted') {
                      actionButton = Text(
                        'Friends',
                        style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold),
                      );
                    } else if (status == 'pending_${currentUid}_to_${user.id}') {
                      actionButton = TextButton(
                        onPressed: () {
                          if (connId != null) {
                            ref.read(connectionsRepositoryProvider).removeConnection(connId);
                          }
                        },
                        child: const Text('Cancel Request', style: TextStyle(color: Colors.grey)),
                      );
                    } else {
                      // Status is pending_other_to_me
                      actionButton = ElevatedButton(
                        onPressed: () {
                          if (connId != null) {
                            ref.read(connectionsRepositoryProvider).acceptFriendRequest(connId);
                          }
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                        child: const Text('Accept', style: TextStyle(color: Colors.white)),
                      );
                    }

                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundImage: user.photoUrl != null ? NetworkImage(user.photoUrl!) : null,
                          child: user.photoUrl == null ? Text(user.displayName?[0] ?? '') : null,
                        ),
                        title: Row(
                          children: [
                            Text(user.displayName ?? 'Anonymous', style: const TextStyle(fontWeight: FontWeight.bold)),
                            if (user.username != null) ...[
                              const SizedBox(width: 8),
                              Text('@${user.username}', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.primary)),
                            ],
                          ],
                        ),
                        subtitle: Text('${user.branch ?? 'No branch'} • Sem ${user.semester ?? '?'}' ),
                        trailing: actionButton,
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  void _confirmRemoveFriend(String name, String connId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Remove $name?'),
          content: Text('Are you sure you want to remove $name from your friends list?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                ref.read(connectionsRepositoryProvider).removeConnection(connId);
                Navigator.pop(context);
              },
              child: const Text('Remove', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}
