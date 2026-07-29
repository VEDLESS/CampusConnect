import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/auth_repository.dart';

final firebaseConfiguredProvider = Provider<bool>((ref) => false);

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(FirebaseAuth.instance, FirebaseFirestore.instance);
});

final authStateProvider = StreamProvider<User?>((ref) {
  if (!ref.watch(firebaseConfiguredProvider)) {
    return Stream<User?>.value(null);
  }
  return ref.watch(authRepositoryProvider).authStateChanges();
});

final authControllerProvider =
    StateNotifierProvider.autoDispose<AuthController, AsyncValue<void>>((ref) {
      return AuthController();
    });

class AuthController extends StateNotifier<AsyncValue<void>> {
  AuthController() : super(const AsyncData(null));

  Future<void> run(
    Future<void> Function() action, {
    bool remember = false,
  }) async {
    state = const AsyncLoading();
    try {
      await action();
      if (remember) {
        final preferences = await SharedPreferences.getInstance();
        await preferences.setBool('remember_me', true);
      }
      state = const AsyncData(null);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    }
  }
}
