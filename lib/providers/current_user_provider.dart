import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/app_user.dart';
import '../models/auth_state.dart';
import 'auth_provider.dart';

/// User yang sedang login, atau `null` jika belum login.
///
/// Halaman cukup `ref.watch(currentUserProvider)` tanpa perlu mengecek
/// jenis [AuthState] atau menyentuh Firestore.
final currentUserProvider = Provider<AppUser?>((ref) {
  final authState = ref.watch(authProvider);
  return authState is AuthAuthenticated ? authState.user : null;
});