import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/app_user.dart';
import '../models/auth_state.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';

/// ViewModel autentikasi: satu-satunya pemilik [AuthState].
///
/// Method login/register melempar `AuthException` agar halaman bisa
/// menampilkan pesan error dan mengatur loading tombolnya sendiri.
class AuthNotifier extends Notifier<AuthState> {
  StreamSubscription<AppUser?>? _profileSubscription;

  AuthService get _authService => ref.read(authServiceProvider);
  UserService get _userService => ref.read(userServiceProvider);

  @override
  AuthState build() {
    ref.onDispose(() => unawaited(_cancelProfileWatch()));
    unawaited(_restoreSession());
    return const AuthInitial();
  }

  /// Dipanggil sekali saat aplikasi dibuka.
  Future<void> _restoreSession() async {
    state = const AuthLoading();
    try {
      final firebaseUser = await _authService.waitForInitialUser();
      if (firebaseUser == null) {
        state = const AuthUnauthenticated();
        return;
      }

      final profile = await _userService.getUser(firebaseUser.uid);
      if (profile == null) {
        await _authService.signOut();
        state = const AuthUnauthenticated();
      } else if (!profile.isActive) {
        await _authService.signOut();
        state = const AuthUnauthenticated(
          message: 'Akun Anda dinonaktifkan. Hubungi administrator.',
        );
      } else {
        _onAuthenticated(profile);
      }
    } catch (_) {
      state = const AuthUnauthenticated(
        message: 'Gagal memuat sesi. Periksa koneksi lalu login kembali.',
      );
    }
  }

  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final profile = await _authService.signInWithEmail(
      email: email,
      password: password,
    );
    _onAuthenticated(profile);
  }

  Future<void> signInWithGoogle() async {
    final profile = await _authService.signInWithGoogle();
    _onAuthenticated(profile);
  }

  /// Registrasi tidak mengubah [AuthState]: user tetap Unauthenticated
  /// dan diarahkan ke Login oleh UI.
  Future<void> register({
    required String nama,
    required String email,
    required String password,
  }) {
    return _authService.register(nama: nama, email: email, password: password);
  }

  /// Logout: hentikan pemantauan, hapus session Firebase, ubah state.
  Future<void> signOut() async {
    await _cancelProfileWatch();
    await _authService.signOut();
    state = const AuthUnauthenticated();
  }

  void _onAuthenticated(AppUser profile) {
    state = AuthAuthenticated(profile);
    _watchProfile(profile.uid);
  }

  /// Memantau profil secara realtime. Jika akun dinonaktifkan, dihapus,
  /// atau datanya rusak, user langsung dikeluarkan (fail closed). Jika
  /// role berubah, state ikut diperbarui.
  void _watchProfile(String uid) {
    unawaited(_cancelProfileWatch());
    _profileSubscription = _userService.watchUser(uid).listen(
      (profile) {
        if (profile == null) {
          unawaited(_forceSignOut('Akun tidak ditemukan.'));
        } else if (!profile.isActive) {
          unawaited(
            _forceSignOut('Akun Anda dinonaktifkan. Hubungi administrator.'),
          );
        } else if (state case AuthAuthenticated(:final user)
            when user != profile) {
          state = AuthAuthenticated(profile);
        }
      },
      onError: (Object _) {
        unawaited(_forceSignOut('Data akun tidak valid. Silakan login ulang.'));
      },
    );
  }

  Future<void> _forceSignOut(String message) async {
    await _cancelProfileWatch();
    await _authService.signOut();
    state = AuthUnauthenticated(message: message);
  }

  Future<void> _cancelProfileWatch() async {
    final subscription = _profileSubscription;
    _profileSubscription = null;
    await subscription?.cancel();
  }
}

final authProvider = NotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);