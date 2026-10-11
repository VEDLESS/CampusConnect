import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/chat_repository.dart';
import '../../profile/presentation/profile_providers.dart';
import '../../../models/chat_session.dart';
import '../../../models/chat_message.dart';

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return ChatRepository(FirebaseFirestore.instance);
});

final chatSessionsProvider = StreamProvider<List<ChatSession>>((ref) {
  final currentUid = ref.watch(currentUserIdProvider);
  if (currentUid == null) return Stream.value([]);
  return ref.watch(chatRepositoryProvider).watchChatSessions(currentUid);
});

final chatMessagesProvider = StreamProvider.family<List<ChatMessage>, String>((ref, chatId) {
  return ref.watch(chatRepositoryProvider).watchMessages(chatId);
});
