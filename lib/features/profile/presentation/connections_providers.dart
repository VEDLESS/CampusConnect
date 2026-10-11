import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/connections_repository.dart';
import 'profile_providers.dart';
import '../../../models/campus_user.dart';

final connectionsRepositoryProvider = Provider<ConnectionsRepository>((ref) {
  return ConnectionsRepository(FirebaseFirestore.instance);
});

final allUsersProvider = StreamProvider<List<CampusUser>>((ref) {
  return ref.watch(connectionsRepositoryProvider).getAllUsers();
});

final myConnectionsProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  final uid = ref.watch(currentUserIdProvider);
  if (uid == null) return Stream.value([]);
  return ref.watch(connectionsRepositoryProvider).getUserConnections(uid);
});
