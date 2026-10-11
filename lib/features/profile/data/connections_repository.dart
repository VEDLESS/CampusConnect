import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../models/campus_user.dart';

class ConnectionsRepository {
  const ConnectionsRepository(this._firestore);

  final FirebaseFirestore _firestore;

  // Stream all users for search/explore
  Stream<List<CampusUser>> getAllUsers() {
    return _firestore.collection('users').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => CampusUser.fromMap(doc.id, doc.data())).toList();
    });
  }

  // Get a specific connection between two users
  String _getConnectionId(String uid1, String uid2) {
    final list = [uid1, uid2]..sort();
    return '${list[0]}_${list[1]}';
  }

  Stream<Map<String, dynamic>?> watchConnection(String uid1, String uid2) {
    final connId = _getConnectionId(uid1, uid2);
    return _firestore.collection('connections').doc(connId).snapshots().map((doc) {
      return doc.exists ? doc.data() : null;
    });
  }

  // Stream all connections for a specific user
  Stream<List<Map<String, dynamic>>> getUserConnections(String uid) {
    return _firestore
        .collection('connections')
        .where('userUids', arrayContains: uid)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => doc.data()).toList();
    });
  }

  // Send a friend request
  Future<void> sendFriendRequest(String fromUid, String toUid) async {
    final connId = _getConnectionId(fromUid, toUid);
    await _firestore.collection('connections').doc(connId).set({
      'connectionId': connId,
      'userUids': [fromUid, toUid],
      'status': 'pending_${fromUid}_to_$toUid',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Accept a friend request
  Future<void> acceptFriendRequest(String connId) async {
    await _firestore.collection('connections').doc(connId).update({
      'status': 'accepted',
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Decline/Remove friend connection
  Future<void> removeConnection(String connId) async {
    await _firestore.collection('connections').doc(connId).delete();
  }
}
