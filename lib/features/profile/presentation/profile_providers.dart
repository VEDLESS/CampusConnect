import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/presentation/auth_providers.dart';
import '../data/profile_repository.dart';
import '../../../models/campus_user.dart';

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepository(FirebaseFirestore.instance);
});

final developerOverrideUidProvider = StateProvider<String?>((ref) => null);

final currentUserIdProvider = Provider<String?>((ref) {
  final override = ref.watch(developerOverrideUidProvider);
  if (override != null) return override;
  final authState = ref.watch(authStateProvider).value;
  return authState?.uid;
});

final userProfileProvider = StreamProvider<CampusUser?>((ref) {
  final uid = ref.watch(currentUserIdProvider);
  if (uid == null) {
    return Stream.value(null);
  }
  return ref.watch(profileRepositoryProvider).watchProfile(uid);
});
