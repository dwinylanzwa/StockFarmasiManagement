import 'package:flutter_test/flutter_test.dart';
import 'package:halobat/errors/admin_exception.dart';
import 'package:halobat/models/app_user.dart';
import 'package:halobat/models/user_role.dart';
import 'package:halobat/services/user_admin_controller.dart';
import 'package:halobat/services/user_service.dart';

class _FakeUserService implements UserService {
  final List<String> calls = [];
  AppUser? existingByEmail;

  @override
  Future<void> updateAccess(
    String uid, {
    required UserRole role,
    String? apotekId,
  }) async {
    calls.add('updateAccess:$uid:${role.value}:$apotekId');
  }
  @override
  Future<void> setActive(String uid, {required bool isActive}) async {
    calls.add('setActive:$uid:$isActive');
  }

  @override
  Future<void> updateRole(String uid, UserRole role) async {
    calls.add('updateRole:$uid:${role.value}');
  }

  @override
  Future<void> createInvite({
    required String email,
    required UserRole role,
    required String invitedByUid,
  }) async {
    calls.add('invite:$email:${role.value}');
  }

  @override
  Future<void> deleteInvite(String email) async {
    calls.add('deleteInvite:$email');
  }

  @override
  Future<AppUser?> findByEmail(String email) async => existingByEmail;

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

void main() {
  late _FakeUserService service;
  late AppUser? current;
  late UserAdminController controller;

  setUp(() {
    service = _FakeUserService();
    current = _user('admin', UserRole.superadmin);
    controller = UserAdminController(
      userService: service,
      currentUser: () => current,
    );
  });
  
  test('updateAccess menyimpan apotek hanya untuk role apoteker', () async {
    final target = _user('u1', UserRole.pengguna);
    await controller.updateAccess(
      target,
      role: UserRole.apoteker,
      apotekId: 'apt-1',
    );
    await controller.updateAccess(
      target,
      role: UserRole.pengguna,
      apotekId: 'apt-1',
    );
    expect(service.calls, [
      'updateAccess:u1:apoteker:apt-1',
      'updateAccess:u1:pengguna:null',
    ]);
  });

  test('updateAccess tidak boleh untuk akun sendiri', () async {
    await expectLater(
      controller.updateAccess(
        _user('admin', UserRole.superadmin),
        role: UserRole.apoteker,
      ),
      throwsA(isA<AdminActionException>()),
    );
    expect(service.calls, isEmpty);
  });
  test('Superadmin dapat menonaktifkan akun lain', () async {
    await controller.setActive(_user('u1', UserRole.pengguna), isActive: false);
    expect(service.calls, ['setActive:u1:false']);
  });

  test('Superadmin dapat mengubah role akun lain', () async {
    await controller.updateRole(
      _user('u1', UserRole.pengguna),
      UserRole.apoteker,
    );
    expect(service.calls, ['updateRole:u1:apoteker']);
  });

  test('tidak boleh mengubah status akun sendiri', () async {
    await expectLater(
      controller.setActive(_user('admin', UserRole.superadmin), isActive: false),
      throwsA(isA<AdminActionException>()),
    );
    expect(service.calls, isEmpty);
  });

  test('tidak boleh mengubah role akun sendiri', () async {
    await expectLater(
      controller.updateRole(
        _user('admin', UserRole.superadmin),
        UserRole.pengguna,
      ),
      throwsA(isA<AdminActionException>()),
    );
    expect(service.calls, isEmpty);
  });

  test('non-Superadmin ditolak untuk semua aksi', () async {
    current = _user('apt', UserRole.apoteker);
    final target = _user('u1', UserRole.pengguna);

    await expectLater(
      controller.setActive(target, isActive: false),
      throwsA(isA<AdminActionException>()),
    );
    await expectLater(
      controller.updateRole(target, UserRole.superadmin),
      throwsA(isA<AdminActionException>()),
    );
    await expectLater(
      controller.inviteApoteker('baru@halobat.com'),
      throwsA(isA<AdminActionException>()),
    );
    expect(service.calls, isEmpty);
  });

  test('belum login ditolak', () async {
    current = null;
    await expectLater(
      controller.deleteInvite('x@halobat.com'),
      throwsA(isA<AdminActionException>()),
    );
  });

  test('undangan memakai email huruf kecil dan role apoteker', () async {
    await controller.inviteApoteker('  Baru@HalObat.com ');
    expect(service.calls, ['invite:baru@halobat.com:apoteker']);
  });

  test('undangan ditolak jika email sudah punya akun', () async {
    service.existingByEmail = _user('u1', UserRole.pengguna);
    await expectLater(
      controller.inviteApoteker('u1@halobat.com'),
      throwsA(isA<AdminActionException>()),
    );
    expect(service.calls, isEmpty);
  });
}