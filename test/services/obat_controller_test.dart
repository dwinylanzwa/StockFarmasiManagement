import 'package:flutter_test/flutter_test.dart';
import 'package:halobat/errors/obat_exception.dart';
import 'package:halobat/models/app_user.dart';
import 'package:halobat/models/bentuk_sediaan.dart';
import 'package:halobat/models/obat_draft.dart';
import 'package:halobat/models/obat_golongan.dart';
import 'package:halobat/models/user_role.dart';
import 'package:halobat/services/obat_controller.dart';
import 'package:halobat/services/obat_service.dart';

class _FakeObatService implements ObatService {
  final List<String> calls = [];

  @override
  Future<String> create(ObatDraft draft, {required String createdByUid}) async {
    calls.add('create:${draft.nama.trim()}:$createdByUid');
    return 'id-baru';
  }

  @override
  Future<void> update(String id, ObatDraft draft) async {
    calls.add('update:$id');
  }

  @override
  Future<void> setActive(String id, {required bool isActive}) async {
    calls.add('setActive:$id:$isActive');
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

AppUser _user(String uid, UserRole role) {
  return AppUser(
    uid: uid,
    nama: 'User $uid',
    email: '$uid@halobat.com',
    role: role,
    createdAt: DateTime(2024),
  );
}

ObatDraft _draft({String nama = 'Paracetamol'}) {
  return ObatDraft(
    nama: nama,
    golongan: ObatGolongan.bebas,
    bentuk: BentukSediaan.tablet,
  );
}

void main() {
  late _FakeObatService service;
  late AppUser? current;
  late ObatController controller;

  setUp(() {
    service = _FakeObatService();
    current = _user('apt', UserRole.apoteker);
    controller = ObatController(
      obatService: service,
      currentUser: () => current,
    );
  });

  test('Apoteker dapat membuat, mengubah, dan menonaktifkan obat', () async {
    final id = await controller.create(_draft(nama: ' Paracetamol '));
    await controller.update(id, _draft());
    await controller.setActive(id, isActive: false);

    expect(service.calls, [
      'create:Paracetamol:apt',
      'update:id-baru',
      'setActive:id-baru:false',
    ]);
  });

  test('role selain Apoteker ditolak untuk semua aksi', () async {
    for (final role in [UserRole.pengguna, UserRole.superadmin]) {
      current = _user('u', role);
      await expectLater(
        controller.create(_draft()),
        throwsA(isA<ObatActionException>()),
      );
      await expectLater(
        controller.update('x', _draft()),
        throwsA(isA<ObatActionException>()),
      );
      await expectLater(
        controller.setActive('x', isActive: true),
        throwsA(isA<ObatActionException>()),
      );
    }
    expect(service.calls, isEmpty);
  });

  test('belum login ditolak', () async {
    current = null;
    await expectLater(
      controller.create(_draft()),
      throwsA(isA<ObatActionException>()),
    );
  });

  test('nama obat tidak valid ditolak sebelum menulis', () async {
    await expectLater(
      controller.create(_draft(nama: ' ')),
      throwsA(isA<ObatActionException>()),
    );
    await expectLater(
      controller.update('x', _draft(nama: 'A')),
      throwsA(isA<ObatActionException>()),
    );
    expect(service.calls, isEmpty);
  });
}