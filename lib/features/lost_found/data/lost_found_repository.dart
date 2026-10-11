import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../models/lost_found_item.dart';

class LostFoundRepository {
  LostFoundRepository(this._firestore);

  final FirebaseFirestore _firestore;

  Stream<List<LostFoundItem>> watchItems() {
    return _firestore
        .collection('lostAndFound')
        .orderBy('dateTime', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => LostFoundItem.fromMap(doc.id, doc.data()))
            .toList());
  }

  Future<void> reportItem(LostFoundItem item) async {
    await _firestore.collection('lostAndFound').add(item.toMap());
  }

  Future<void> deleteItem(String itemId) async {
    await _firestore.collection('lostAndFound').doc(itemId).delete();
  }

  Future<void> markAsFound(String itemId) async {
    await _firestore.collection('lostAndFound').doc(itemId).update({'isLost': false});
  }
}
