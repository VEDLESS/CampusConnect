import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../models/marketplace_item.dart';

class MarketplaceRepository {
  MarketplaceRepository(this._firestore);

  final FirebaseFirestore _firestore;

  Stream<List<MarketplaceItem>> watchItems() {
    return _firestore
        .collection('marketplace')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MarketplaceItem.fromMap(doc.id, doc.data()))
            .toList());
  }

  Future<void> createItem(MarketplaceItem item) async {
    await _firestore.collection('marketplace').add(item.toMap());
  }

  Future<void> deleteItem(String itemId) async {
    await _firestore.collection('marketplace').doc(itemId).delete();
  }
}
