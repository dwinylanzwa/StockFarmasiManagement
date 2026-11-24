import '../errors/admin_exception.dart';
import '../models/app_user.dart';
import '../models/user_role.dart';
import 'user_service.dart';

/// Aturan bisnis administrasi user (khusus Superadmin).
///
/// Dipisahkan dari UI agar bisa diuji. Semua method melempar
/// [AdminActionException] jika gagal atau tidak diizinkan.
class UserAdminController {
  UserAdminController({
    required UserService userService,
    required AppUser? Function() currentUser,
  })  : _userService = userService,
        _currentUser = currentUser;

  final UserService _userService;
  final AppUser? Function() _currentUser;

  /// Mengaktifkan atau menonaktifkan akun [target].
  Future<void> setActive(AppUser target, {required bool isActive}) {
    return _run(() async {
      final me = _requireSuperadmin();
      _ensureNotSelf(me, target);
      await _userService.setActive(target.uid, isActive: isActive);
    });
  }

  /// Mengubah role akun [target].
  Future<void> updateRole(AppUser target, UserRole role) {
    return _run(() async {
      final me = _requireSuperadmin();
      _ensureNotSelf(me, target);
      await _userService.updateRole(target.uid, role);
    });
  }
    /// Mengubah role dan apotek tugas sekaligus. Untuk role selain
  /// Apoteker, penugasan apotek otomatis dikosongkan.
  Future<void> updateAccess(
    AppUser target, {
    required UserRole role,
    String? apotekId,
  }) {
    return _run(() async {
      final me = _requireSuperadmin();
      _ensureNotSelf(me, target);
      await _userService.updateAccess(
        target.uid,
        role: role,
        apotekId: role == UserRole.apoteker ? apotekId : null,
      );
    });
  }

  /// Mengundang [email] sebagai Apoteker.
  Future<void> inviteApoteker(String email) {
    return _run(() async {
      final me = _requireSuperadmin();
      final normalized = email.trim().toLowerCase();

      final existing = await _userService.findByEmail(normalized);
      if (existing != null) {
        throw AdminActionException(
          'Email ini sudah terdaftar sebagai ${existing.role.label}. '
          'Ubah role-nya lewat halaman Users.',
        );
      }

      await _userService.createInvite(
        email: normalized,
        role: UserRole.apoteker,
        invitedByUid: me.uid,
      );
    });
  }

  /// Membatalkan undangan untuk [email].
  Future<void> deleteInvite(String email) {
    return _run(() async {
      _requireSuperadmin();
      await _userService.deleteInvite(email);
    });
  }

  AppUser _requireSuperadmin() {
    final me = _currentUser();
    if (me == null || me.role != UserRole.superadmin) {
      throw const AdminActionException(
        'Hanya Superadmin yang dapat melakukan tindakan ini.',
      );
    }
    return me;
  }

  void _ensureNotSelf(AppUser me, AppUser target) {
    if (me.uid == target.uid) {
      throw const AdminActionException(
        'Anda tidak dapat mengubah role atau status akun Anda sendiri.',
      );
    }
  }

  Future<void> _run(Future<void> Function() action) async {
    try {
      await action();
    } catch (e) {
      throw AdminActionException.from(e);
    }
  }
}