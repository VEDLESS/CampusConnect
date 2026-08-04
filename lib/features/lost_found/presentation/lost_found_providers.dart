import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/lost_found_repository.dart';
import '../../../models/lost_found_item.dart';

final lostFoundRepositoryProvider = Provider<LostFoundRepository>((ref) {
  return LostFoundRepository(FirebaseFirestore.instance);
});

final lostFoundListProvider = StreamProvider<List<LostFoundItem>>((ref) {
  return ref.watch(lostFoundRepositoryProvider).watchItems();
});
