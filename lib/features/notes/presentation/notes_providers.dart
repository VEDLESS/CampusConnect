import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/notes_repository.dart';
import '../../../models/study_note.dart';

final notesRepositoryProvider = Provider<NotesRepository>((ref) {
  return NotesRepository(FirebaseFirestore.instance);
});

final notesListProvider = StreamProvider<List<StudyNote>>((ref) {
  return ref.watch(notesRepositoryProvider).watchNotes();
});
