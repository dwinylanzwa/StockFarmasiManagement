import 'package:flutter_test/flutter_test.dart';
import 'package:halobat/models/user_role.dart';
import 'package:halobat/navigation/role_navigation.dart';
import 'package:halobat/navigation/route_paths.dart';

List<String> _labels(UserRole role) =>
    RoleNavigation.itemsFor(role).map((item) => item.label).toList();

void main() {
  group('RoleNavigation', () {
    test('label menu sesuai spesifikasi tiap role', () {
      expect(
        _labels(UserRole.pengguna),
        ['Home', 'Obat', 'Edukasi', 'Konsultasi', 'Profile'],
      );
      expect(
        _labels(UserRole.apoteker),
        ['Dashboard', 'Obat', 'Stok', 'Konsultasi', 'Profile'],
      );
      expect(
        _labels(UserRole.superadmin),
        ['Dashboard', 'Users', 'Apoteker', 'Settings', 'Profile'],
      );
    });

    test('item pertama adalah dashboard dan semua path milik role-nya', () {
      for (final role in UserRole.values) {
        final items = RoleNavigation.itemsFor(role);
        expect(items.first.path, RoutePaths.homeFor(role));
        for (final item in items) {
          expect(RoutePaths.ownerOf(item.path), role);
        }
      }
    });
  });
}