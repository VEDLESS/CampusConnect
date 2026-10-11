import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../models/chat_message.dart';
import '../../../models/chat_session.dart';

class ChatRepository {
  const ChatRepository(this._firestore);

  final FirebaseFirestore _firestore;

  String _getChatId(String uid1, String uid2) {
    final list = [uid1, uid2]..sort();
    return '${list[0]}_${list[1]}';
  }

  // Get or create conversation session
  Future<String> getOrCreateChatSession(String uid1, String uid2) async {
    final chatId = _getChatId(uid1, uid2);
    final docRef = _firestore.collection('chats').doc(chatId);
    
    final doc = await docRef.get();
    if (!doc.exists) {
      await docRef.set({
        'participants': [uid1, uid2],
        'lastMessage': '',
        'lastMessageSenderId': '',
        'lastMessageTime': FieldValue.serverTimestamp(),
      });
    }
    return chatId;
  }

  // Stream active conversation lists for a user
  Stream<List<ChatSession>> watchChatSessions(String currentUid) {
    return _firestore
        .collection('chats')
        .where('participants', arrayContains: currentUid)
        .orderBy('lastMessageTime', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => ChatSession.fromMap(doc.id, doc.data())).toList();
    });
  }

  // Stream chat message history for a given chatId
  Stream<List<ChatMessage>> watchMessages(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => ChatMessage.fromMap(doc.id, doc.data())).toList();
    });
  }

  // Send message
  Future<void> sendMessage({
    required String senderId,
    required String receiverId,
    required String content,
    String type = 'text',
  }) async {
    final chatId = _getChatId(senderId, receiverId);

    final msgRef = _firestore.collection('chats').doc(chatId).collection('messages').doc();
    final batch = _firestore.batch();

    batch.set(msgRef, {
      'senderId': senderId,
      'receiverId': receiverId,
      'content': content,
      'timestamp': FieldValue.serverTimestamp(),
      'type': type,
    });

    batch.set(
      _firestore.collection('chats').doc(chatId),
      {
        'participants': [senderId, receiverId],
        'lastMessage': type == 'call' ? '📞 Call Log' : content,
        'lastMessageSenderId': senderId,
        'lastMessageTime': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );

    await batch.commit();
  }
}
