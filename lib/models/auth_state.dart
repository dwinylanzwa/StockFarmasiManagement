import 'app_user.dart';
import 'user_role.dart';

/// Status autentikasi yang dibaca seluruh UI dan router.
///
/// UI cukup `ref.watch(authProvider)` tanpa menyentuh Firestore.
sealed class AuthState {
  const AuthState();
}

/// Aplikasi baru dibuka, belum ada pengecekan.
final class AuthInitial extends AuthState {
  const AuthInitial();
}

/// Sedang memeriksa session yang tersimpan.
final class AuthLoading extends AuthState {
  const AuthLoading();
}

/// Belum login. [message] opsional, mis. alasan dipaksa logout.
final class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated({this.message});

  final String? message;
}

/// Sudah login. [user] berisi uid, nama, email, role, dan lainnya.
final class AuthAuthenticated extends AuthState {
  const AuthAuthenticated(this.user);

  final AppUser user;

  UserRole get role => user.role;
}