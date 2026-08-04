import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../models/study_note.dart';

class NotesRepository {
  NotesRepository(this._firestore);

  final FirebaseFirestore _firestore;

  Stream<List<StudyNote>> watchNotes() {
    return _firestore
        .collection('notes')
        .orderBy('uploadedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => StudyNote.fromMap(doc.id, doc.data()))
            .toList());
  }

  Future<void> uploadNote(StudyNote note) async {
    await _firestore.collection('notes').add(note.toMap());
  }

  Future<void> deleteNote(String noteId) async {
    await _firestore.collection('notes').doc(noteId).delete();
  }
}
