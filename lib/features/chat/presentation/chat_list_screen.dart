import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'chat_providers.dart';
import '../../profile/presentation/profile_providers.dart';
import '../../profile/presentation/connections_providers.dart';
import 'chat_detail_screen.dart';
import '../../../models/campus_user.dart';

class ChatListScreen extends ConsumerWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final sessionsAsync = ref.watch(chatSessionsProvider);
    final currentUid = ref.watch(currentUserIdProvider);
    final usersAsync = ref.watch(allUsersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Direct Messages'),
      ),
      body: currentUid == null
          ? const Center(child: Text('Please log in to chat.'))
          : sessionsAsync.when(
              data: (sessions) {
                if (sessions.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.chat_bubble_outline, size: 64, color: theme.colorScheme.primary.withOpacity(0.5)),
                        const SizedBox(height: 12),
                        Text('No conversations yet', style: theme.textTheme.titleMedium),
                        const SizedBox(height: 4),
                        const Text('Tap the button below to message a friend!'),
                      ],
                    ),
                  );
                }

                return usersAsync.when(
                  data: (allUsers) {
                    return ListView.builder(
                      itemCount: sessions.length,
                      itemBuilder: (context, index) {
                        final session = sessions[index];
                        final otherUid = session.participants.firstWhere(
                          (id) => id != currentUid,
                          orElse: () => '',
                        );

                        final otherUser = allUsers.firstWhere(
                          (u) => u.id == otherUid,
                          orElse: () => CampusUser(id: otherUid, email: '', displayName: 'Anonymous User'),
                        );

                        return ListTile(
                          leading: CircleAvatar(
                            backgroundImage: otherUser.photoUrl != null ? NetworkImage(otherUser.photoUrl!) : null,
                            child: otherUser.photoUrl == null ? Text(otherUser.displayName?[0] ?? '') : null,
                          ),
                          title: Text(otherUser.displayName ?? 'Anonymous'),
                          subtitle: Text(
                            session.lastMessage.isNotEmpty
                                ? session.lastMessage
                                : 'Start messaging...',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: Text(
                            _formatTime(session.lastMessageTime),
                            style: theme.textTheme.bodySmall,
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChatDetailScreen(
                                  otherUser: otherUser,
                                  chatId: session.id,
                                ),
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(child: Text('Error: $e')),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error loading chats: $e')),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showNewChatSelector(context, ref, currentUid),
        icon: const Icon(Icons.message_outlined),
        label: const Text('New Chat'),
      ),
    );
  }

  void _showNewChatSelector(BuildContext context, WidgetRef ref, String? currentUid) {
    if (currentUid == null) return;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Consumer(
          builder: (context, ref, _) {
            final usersAsync = ref.watch(allUsersProvider);
            final connectionsAsync = ref.watch(myConnectionsProvider);

            return usersAsync.when(
              data: (allUsers) {
                return connectionsAsync.when(
                  data: (connections) {
                    final friendUids = connections
                        .where((c) => c['status'] == 'accepted')
                        .map((c) => List<String>.from(c['userUids']).firstWhere((id) => id != currentUid))
                        .toList();

                    final friends = allUsers.where((u) => friendUids.contains(u.id)).toList();

                    return Container(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Select Friend to Chat',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 16),
                          if (friends.isEmpty)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 24.0),
                              child: Center(
                                child: Text('No friends added yet. Connect first in Connections!'),
                              ),
                            )
                          else
                            Expanded(
                              child: ListView.builder(
                                itemCount: friends.length,
                                itemBuilder: (context, index) {
                                  final friend = friends[index];
                                  return ListTile(
                                    leading: CircleAvatar(
                                      backgroundImage: friend.photoUrl != null ? NetworkImage(friend.photoUrl!) : null,
                                      child: friend.photoUrl == null ? Text(friend.displayName?[0] ?? '') : null,
                                    ),
                                    title: Text(friend.displayName ?? 'Anonymous'),
                                    subtitle: Text(friend.branch ?? ''),
                                    onTap: () async {
                                      Navigator.pop(context);
                                      // Get or create session
                                      final chatId = await ref.read(chatRepositoryProvider).getOrCreateChatSession(
                                            currentUid,
                                            friend.id,
                                          );
                                      if (context.mounted) {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => ChatDetailScreen(
                                              otherUser: friend,
                                              chatId: chatId,
                                            ),
                                          ),
                                        );
                                      }
                                    },
                                  );
                                },
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(child: Text('Error: $e')),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
            );
          },
        );
      },
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    if (dateTime.day == now.day && dateTime.month == now.month && dateTime.year == now.year) {
      return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    }
    return '${dateTime.day}/${dateTime.month}';
  }
}
