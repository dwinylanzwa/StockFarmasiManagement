import '../errors/obat_exception.dart';
import '../models/app_user.dart';
import '../models/obat_draft.dart';
import '../models/user_role.dart';
import '../utils/validators.dart';
import 'obat_service.dart';

/// Aturan bisnis pengelolaan katalog obat.
///
/// Hanya Apoteker yang boleh menulis. Semua method melempar
/// [ObatActionException] jika gagal atau tidak diizinkan.
class ObatController {
  ObatController({
    required ObatService obatService,
    required AppUser? Function() currentUser,
  })  : _obatService = obatService,
        _currentUser = currentUser;

  final ObatService _obatService;
  final AppUser? Function() _currentUser;

  Future<String> create(ObatDraft draft) {
    return _run(() async {
      final me = _requireApoteker();
      _validate(draft);
      return _obatService.create(draft, createdByUid: me.uid);
    });
  }

  Future<void> update(String id, ObatDraft draft) {
    return _run(() async {
      _requireApoteker();
      _validate(draft);
      await _obatService.update(id, draft);
    });
  }

  Future<void> setActive(String id, {required bool isActive}) {
    return _run(() async {
      _requireApoteker();
      await _obatService.setActive(id, isActive: isActive);
    });
  }

  AppUser _requireApoteker() {
    final me = _currentUser();
    if (me == null || me.role != UserRole.apoteker) {
      throw const ObatActionException(
        'Hanya Apoteker yang dapat mengelola data obat.',
      );
    }
    return me;
  }

  void _validate(ObatDraft draft) {
    final error = Validators.namaObat(draft.nama);
    if (error != null) throw ObatActionException(error);
  }

  Future<T> _run<T>(Future<T> Function() action) async {
    try {
      return await action();
    } catch (e) {
      throw ObatActionException.from(e);
    }
  }
}