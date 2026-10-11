import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../models/campus_user.dart';

class ProfileRepository {
  ProfileRepository(this._firestore);

  final FirebaseFirestore _firestore;

  Stream<CampusUser?> watchProfile(String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .snapshots()
        .map((snapshot) {
          final data = snapshot.data();
          if (data == null) return null;
          return CampusUser.fromMap(uid, data);
        });
  }

  Future<void> updateProfile(CampusUser user) async {
    await _firestore
        .collection('users')
        .doc(user.id)
        .set(user.toMap(), SetOptions(merge: true));
  }

  Future<bool> isUsernameUnique(String username, String currentUid) async {
    if (username.trim().isEmpty) return true;
    final query = await _firestore
        .collection('users')
        .where('username', isEqualTo: username.trim().toLowerCase())
        .get();
    
    for (var doc in query.docs) {
      if (doc.id != currentUid) {
        return false;
      }
    }
    return true;
  }
}
