import 'package:flutter_test/flutter_test.dart';
import 'package:halobat/models/app_user.dart';
import 'package:halobat/models/auth_state.dart';
import 'package:halobat/models/user_role.dart';
import 'package:halobat/navigation/route_guard.dart';
import 'package:halobat/navigation/route_paths.dart';

AuthState _authenticated(UserRole role) {
  return AuthAuthenticated(
    AppUser(
      uid: 'uid-${role.value}',
      nama: 'Tester',
      email: '${role.value}@halobat.com',
      role: role,
      createdAt: DateTime(2024),
    ),
  );
}

String? _redirect(AuthState state, String location) =>
    RouteGuard.redirect(authState: state, location: location);

void main() {
  group('Session belum siap', () {
    test('Initial dan Loading ditahan di splash', () {
      expect(_redirect(const AuthInitial(), '/pengguna'), RoutePaths.splash);
      expect(_redirect(const AuthLoading(), '/login'), RoutePaths.splash);
      expect(_redirect(const AuthLoading(), RoutePaths.splash), isNull);
    });
  });

  group('Belum login', () {
    const state = AuthUnauthenticated();

    test('boleh membuka login dan register', () {
      expect(_redirect(state, RoutePaths.login), isNull);
      expect(_redirect(state, RoutePaths.register), isNull);
    });

    test('halaman lain dialihkan ke login', () {
      expect(_redirect(state, '/pengguna'), RoutePaths.login);
      expect(_redirect(state, '/apoteker/stok'), RoutePaths.login);
      expect(_redirect(state, '/superadmin/users'), RoutePaths.login);
      expect(_redirect(state, '/'), RoutePaths.login);
    });
  });

  group('Sudah login', () {
    test('diarahkan ke dashboard sesuai role dari halaman entry', () {
      for (final role in UserRole.values) {
        final state = _authenticated(role);
        final home = RoutePaths.homeFor(role);
        expect(_redirect(state, RoutePaths.login), home);
        expect(_redirect(state, RoutePaths.register), home);
        expect(_redirect(state, RoutePaths.splash), home);
        expect(_redirect(state, '/'), home);
      }
    });

    test('Pengguna tidak bisa masuk area Apoteker dan Superadmin', () {
      final state = _authenticated(UserRole.pengguna);
      expect(_redirect(state, '/pengguna/obat'), isNull);
      expect(_redirect(state, '/apoteker'), RoutePaths.pengguna);
      expect(_redirect(state, '/apoteker/stok'), RoutePaths.pengguna);
      expect(_redirect(state, '/superadmin/users'), RoutePaths.pengguna);
    });

    test('Apoteker tidak bisa masuk area Pengguna dan Superadmin', () {
      final state = _authenticated(UserRole.apoteker);
      expect(_redirect(state, '/apoteker/stok'), isNull);
      expect(_redirect(state, '/pengguna'), RoutePaths.apoteker);
      expect(_redirect(state, '/superadmin/settings'), RoutePaths.apoteker);
    });

    test('Superadmin hanya masuk area Superadmin', () {
      final state = _authenticated(UserRole.superadmin);
      expect(_redirect(state, '/superadmin/users'), isNull);
      expect(_redirect(state, '/pengguna/obat'), RoutePaths.superadmin);
      expect(_redirect(state, '/apoteker/stok'), RoutePaths.superadmin);
    });

    test('prefix mirip tidak dianggap area role', () {
      final state = _authenticated(UserRole.pengguna);
      expect(RoutePaths.ownerOf('/penggunaX'), isNull);
      expect(_redirect(state, '/penggunaX'), isNull);
    });
  });
}