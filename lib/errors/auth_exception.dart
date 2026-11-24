import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuthException;
import 'package:flutter/foundation.dart';

/// Error autentikasi yang sudah "dikenal". [message] aman ditampilkan ke
/// pengguna. `sealed` agar penanganan error bisa dicek exhaustive.
sealed class AuthException implements Exception {
  const AuthException(this.message);

  /// Menerjemahkan error Firebase Auth menjadi [AuthException].
  factory AuthException.fromFirebase(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-credential':
      case 'wrong-password':
      case 'user-not-found':
      case 'invalid-login-credentials':
        return const InvalidCredentialsException();
      case 'email-already-in-use':
        return const EmailAlreadyInUseException();
      case 'weak-password':
        return const WeakPasswordException();
      case 'invalid-email':
        return const InvalidEmailException();
      case 'user-disabled':
        return const AccountInactiveException();
      case 'too-many-requests':
        return const TooManyRequestsException();
      case 'network-request-failed':
        return const NetworkException();
      case 'canceled':
      case 'web-context-canceled':
      case 'popup-closed-by-user':
        return const SignInCancelledException();
      case 'operation-not-allowed':
        return const OperationNotAllowedException();

      default:
        debugPrint('[Auth] FirebaseAuthException code=${e.code} msg=${e.message}');
        return UnknownAuthException(e);
    }
  }

  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

final class InvalidCredentialsException extends AuthException {
  const InvalidCredentialsException() : super('Email atau password salah.');
}

final class EmailAlreadyInUseException extends AuthException {
  const EmailAlreadyInUseException()
      : super('Email sudah terdaftar. Silakan login atau gunakan email lain.');
}

final class WeakPasswordException extends AuthException {
  const WeakPasswordException()
      : super('Password terlalu lemah. Gunakan kombinasi yang lebih kuat.');
}

final class InvalidEmailException extends AuthException {
  const InvalidEmailException() : super('Format email tidak valid.');
}

final class AccountInactiveException extends AuthException {
  const AccountInactiveException()
      : super('Akun Anda dinonaktifkan. Hubungi administrator.');
}

final class TooManyRequestsException extends AuthException {
  const TooManyRequestsException()
      : super('Terlalu banyak percobaan. Coba lagi beberapa saat lagi.');
}

final class NetworkException extends AuthException {
  const NetworkException()
      : super('Tidak ada koneksi internet. Periksa jaringan Anda.');
}

/// Pengguna menutup jendela login Google. UI sebaiknya diam saja.
final class SignInCancelledException extends AuthException {
  const SignInCancelledException() : super('Login dibatalkan.');
}

/// Login/registrasi di Firebase Auth berhasil, tetapi profil di
/// Firestore gagal dibaca atau dibuat.
final class ProfileUnavailableException extends AuthException {
  const ProfileUnavailableException([this.cause])
      : super('Gagal memuat data akun. Periksa koneksi lalu coba lagi.');

  /// Error asli untuk debugging; jangan ditampilkan ke pengguna.
  final Object? cause;
}

final class UnknownAuthException extends AuthException {
  const UnknownAuthException([this.cause])
      : super('Terjadi kesalahan tak terduga. Silakan coba lagi.');

  final Object? cause;
}

final class OperationNotAllowedException extends AuthException {
  const OperationNotAllowedException()
      : super('Metode login ini belum diaktifkan di Firebase Console.');
}