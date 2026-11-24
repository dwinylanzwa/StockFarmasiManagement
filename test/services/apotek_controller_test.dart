import 'package:flutter_test/flutter_test.dart';
import 'package:halobat/errors/admin_exception.dart';
import 'package:halobat/models/apotek_draft.dart';
import 'package:halobat/models/app_user.dart';
import 'package:halobat/models/user_role.dart';
import 'package:halobat/models/hari.dart';
import 'package:halobat/models/jadwal_operasional.dart';
import 'package:halobat/services/apotek_controller.dart';
import 'package:halobat/services/apotek_service.dart';

class _FakeApotekService implements ApotekService {
  final List<String> calls = [];

  @override
  Future<String> create(
    ApotekDraft draft, {
    required String createdByUid,
  }) async {
    calls.add('create:${draft.nama.trim()}:$createdByUid');
    return 'id-baru';
  }

  @override
  Future<void> update(String id, ApotekDraft draft) async {
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

ApotekDraft _draft({
  String nama = 'Apotek Sehat',
  String alamat = 'Jl. Contoh No. 1',
  double lat = -6.2,
  double lng = 106.8,
  JadwalOperasional jadwal = JadwalOperasional.standar,
}) {
  return ApotekDraft(
    nama: nama,
    alamat: alamat,
    latitude: lat,
    longitude: lng,
    jadwal: jadwal,
  );
}

void main() {
  late _FakeApotekService service;
  late AppUser? current;
  late ApotekController controller;

  setUp(() {
    service = _FakeApotekService();
    current = _user('admin', UserRole.superadmin);
    controller = ApotekController(
      apotekService: service,
      currentUser: () => current,
    );
  });

  test('Superadmin dapat membuat, mengubah, dan menonaktifkan apotek', () async {
    final id = await controller.create(_draft(nama: ' Apotek Sehat '));
    await controller.update(id, _draft());
    await controller.setActive(id, isActive: false);

    expect(service.calls, [
      'create:Apotek Sehat:admin',
      'update:id-baru',
      'setActive:id-baru:false',
    ]);
  });

  test('role selain Superadmin ditolak untuk semua aksi', () async {
    for (final role in [UserRole.pengguna, UserRole.apoteker]) {
      current = _user('u', role);
      await expectLater(
        controller.create(_draft()),
        throwsA(isA<AdminActionException>()),
      );
      await expectLater(
        controller.update('x', _draft()),
        throwsA(isA<AdminActionException>()),
      );
      await expectLater(
        controller.setActive('x', isActive: true),
        throwsA(isA<AdminActionException>()),
      );
      await expectLater(
      controller.create(_draft(jadwal: const JadwalOperasional(hari: {}))),
      throwsA(isA<AdminActionException>()),
      );
      await expectLater(
        controller.create(
          _draft(
            jadwal: const JadwalOperasional(
              hari: {Hari.senin},
              bukaMenit: 900,
              tutupMenit: 600,
            ),
          ),
        ),
        throwsA(isA<AdminActionException>()),
      );
    }
    expect(service.calls, isEmpty);
  });

  test('input tidak valid ditolak sebelum menulis', () async {
    await expectLater(
      controller.create(_draft(nama: ' ')),
      throwsA(isA<AdminActionException>()),
    );
    await expectLater(
      controller.create(_draft(alamat: 'abc')),
      throwsA(isA<AdminActionException>()),
    );
    await expectLater(
      controller.create(_draft(lat: 91)),
      throwsA(isA<AdminActionException>()),
    );
    await expectLater(
      controller.create(_draft(lng: -181)),
      throwsA(isA<AdminActionException>()),
    );
    expect(service.calls, isEmpty);
  });
}