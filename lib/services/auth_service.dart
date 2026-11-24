import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../errors/auth_exception.dart';
import '../models/app_user.dart';
import 'user_service.dart';

/// Pembungkus Firebase Auth: login, register, dan logout.
///
/// Service ini TIDAK menyimpan state. State dikelola `AuthNotifier`.
/// Semua method melempar [AuthException] jika gagal.
class AuthService {
    AuthService({required this._userService, FirebaseAuth? auth})
      : _auth = auth ?? FirebaseAuth.instance;

  final UserService _userService;
  final FirebaseAuth _auth;

  static String _normalizeEmail(String email) => email.trim().toLowerCase();

  /// Menunggu Firebase selesai memulihkan session lama, lalu mengembalikan
  /// user-nya (`null` jika belum login).
  Future<User?> waitForInitialUser() => _auth.authStateChanges().first;

  /// Login email + password.
  Future<AppUser> signInWithEmail({
    required String email,
    required String password,
  }) {
    return _guard(() async {
      final credential = await _auth.signInWithEmailAndPassword(
        email: _normalizeEmail(email),
        password: password,
      );
      return _completeSignIn(credential.user);
    });
  }

  /// Login Google lewat Firebase (tanpa package google_sign_in).
  Future<AppUser> signInWithGoogle() {
    return _guard(() async {
      final credential = await _auth.signInWithProvider(GoogleAuthProvider());
      return _completeSignIn(credential.user);
    });
  }

  /// Registrasi akun baru. Role TIDAK bisa ditentukan dari sini: profil
  /// dibuat oleh [UserService.ensureProfile] dengan aturan yang dikunci
  /// juga oleh Firestore Security Rules.
  ///
  /// Setelah berhasil, user di-sign-out agar alurnya kembali ke Login.
  Future<void> register({
    required String nama,
    required String email,
    required String password,
  }) {
    return _guard(() async {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: _normalizeEmail(email),
        password: password,
      );
      final user = credential.user;
      if (user == null) throw const UnknownAuthException();

      try {
        await _userService.ensureProfile(user, nama: nama);
      } catch (e) {
        // Rollback: hapus akun Auth yatim agar email bisa dipakai lagi.
        await _discardOrphanAccount(user);
        throw ProfileUnavailableException(e);
      }

      await _sendVerificationQuietly(user);
      await _auth.signOut();
    });
  }

  Future<void> signOut() => _auth.signOut();

  /// Memuat/membuat profil dan memastikan akun aktif.
  Future<AppUser> _completeSignIn(User? user) async {
    if (user == null) throw const UnknownAuthException();

    try {
      final profile = await _userService.ensureProfile(user);
      if (!profile.isActive) {
        await _auth.signOut();
        throw const AccountInactiveException();
      }
      return profile;
    } on AuthException {
      rethrow;
    } catch (e) {
      await _auth.signOut();
      throw ProfileUnavailableException(e);
    }
  }

  Future<void> _discardOrphanAccount(User user) async {
    try {
      await user.delete();
    } catch (_) {
      await _auth.signOut();
    }
  }

  Future<void> _sendVerificationQuietly(User user) async {
    try {
      await user.sendEmailVerification();
    } catch (_) {
      // Gagal kirim email verifikasi tidak boleh menggagalkan registrasi.
    }
  }

  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on FirebaseAuthException catch (e) {
      throw AuthException.fromFirebase(e);
    }
  }
}

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(userService: ref.watch(userServiceProvider));
});