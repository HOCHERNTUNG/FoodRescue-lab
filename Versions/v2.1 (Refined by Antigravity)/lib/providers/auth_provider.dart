import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/firebase_service.dart';

/// Firebase authentication providers used by the login view and app shell.
///
/// This file keeps auth-specific dependencies separate from the marketplace
/// and reservation repository providers so the presentation layer can remain
/// modular and easy to defend in a live demonstration.
final firebaseServiceProvider = Provider<FirebaseService>((ref) {
  return FirebaseService();
});

/// Emits a [User] when authentication state changes, or null when signed out.
///
/// This provider is observed by [AuthGatekeeper] in `main.dart` to decide
/// whether the app should render [LoginScreen] or [RootNavigationScreen].
final authStateProvider = StreamProvider<User?>((ref) {
  return ref.read(firebaseServiceProvider).authStateChanges;
});
