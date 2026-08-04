import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../models/event.dart';

class EventsRepository {
  EventsRepository(this._firestore);

  final FirebaseFirestore _firestore;

  Stream<List<CampusEvent>> watchEvents() {
    return _firestore
        .collection('events')
        .orderBy('dateTime', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => CampusEvent.fromMap(doc.id, doc.data()))
            .toList());
  }

  Future<void> createEvent(CampusEvent event) async {
    await _firestore.collection('events').add(event.toMap());
  }

  Future<void> toggleRsvp(String eventId, String userId) async {
    final docRef = _firestore.collection('events').doc(eventId);
    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);
      if (!snapshot.exists) return;

      final data = snapshot.data()!;
      final attendees = List<String>.from(data['attendees'] ?? []);

      if (attendees.contains(userId)) {
        attendees.remove(userId);
      } else {
        attendees.add(userId);
      }

      transaction.update(docRef, {'attendees': attendees});
    });
  }
}
