import '../errors/admin_exception.dart';
import '../models/app_user.dart';
import '../models/apotek_draft.dart';
import '../models/user_role.dart';
import '../utils/validators.dart';
import 'apotek_service.dart';

/// Aturan bisnis pengelolaan apotek. Hanya Superadmin yang boleh menulis.
///
/// Semua method melempar [AdminActionException] jika gagal atau tidak
/// diizinkan. Penegak sebenarnya adalah Firestore Rules.
class ApotekController {
  ApotekController({
    required ApotekService apotekService,
    required AppUser? Function() currentUser,
  })  : _apotekService = apotekService,
        _currentUser = currentUser;

  final ApotekService _apotekService;
  final AppUser? Function() _currentUser;

  Future<String> create(ApotekDraft draft) {
    return _run(() async {
      final me = _requireSuperadmin();
      _validate(draft);
      return _apotekService.create(draft, createdByUid: me.uid);
    });
  }

  Future<void> update(String id, ApotekDraft draft) {
    return _run(() async {
      _requireSuperadmin();
      _validate(draft);
      await _apotekService.update(id, draft);
    });
  }

  Future<void> setActive(String id, {required bool isActive}) {
    return _run(() async {
      _requireSuperadmin();
      await _apotekService.setActive(id, isActive: isActive);
    });
  }

  AppUser _requireSuperadmin() {
    final me = _currentUser();
    if (me == null || me.role != UserRole.superadmin) {
      throw const AdminActionException(
        'Hanya Superadmin yang dapat mengelola data apotek.',
      );
    }
    return me;
  }

  void _validate(ApotekDraft draft) {
    final error = Validators.namaApotek(draft.nama) ??
        Validators.alamatApotek(draft.alamat) ??
        draft.jadwal.validate();
    if (error != null) throw AdminActionException(error);

    final latValid = draft.latitude >= -90 && draft.latitude <= 90;
    final lngValid = draft.longitude >= -180 && draft.longitude <= 180;
    if (!latValid || !lngValid) {
      throw const AdminActionException('Koordinat lokasi tidak valid.');
    }
  }

  Future<T> _run<T>(Future<T> Function() action) async {
    try {
      return await action();
    } catch (e) {
      throw AdminActionException.from(e);
    }
  }
}