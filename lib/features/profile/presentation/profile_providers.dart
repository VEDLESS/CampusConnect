import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/presentation/auth_providers.dart';
import '../data/profile_repository.dart';
import '../../../models/campus_user.dart';

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepository(FirebaseFirestore.instance);
});

final userProfileProvider = StreamProvider<CampusUser?>((ref) {
  // Watch authState to automatically load/unload profile based on login state
  final authState = ref.watch(authStateProvider).value;
  if (authState == null) {
    return Stream.value(null);
  }
  return ref.watch(profileRepositoryProvider).watchProfile(authState.uid);
});
