import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/events_repository.dart';
import '../../../models/event.dart';

final eventsRepositoryProvider = Provider<EventsRepository>((ref) {
  return EventsRepository(FirebaseFirestore.instance);
});

final eventsListProvider = StreamProvider<List<CampusEvent>>((ref) {
  return ref.watch(eventsRepositoryProvider).watchEvents();
});
