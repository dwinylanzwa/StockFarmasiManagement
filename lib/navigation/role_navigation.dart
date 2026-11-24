import 'package:flutter/material.dart';

import '../models/user_role.dart';
import 'route_paths.dart';

/// Satu item menu pada bottom navigation.
class NavItem {
  const NavItem({
    required this.label,
    required this.icon,
    required this.selectedIcon,
    required this.path,
  });

  final String label;
  final IconData icon;
  final IconData selectedIcon;

  /// Path rute tab ini. Item pertama selalu dashboard role-nya.
  final String path;
}

/// Definisi menu navigasi untuk setiap role (satu sumber kebenaran).
///
/// `switch` exhaustive: menambah role baru di [UserRole] menimbulkan error
/// kompilasi di sini sampai menunya didaftarkan.
abstract final class RoleNavigation {
  static List<NavItem> itemsFor(UserRole role) => switch (role) {
        UserRole.pengguna => _pengguna,
        UserRole.apoteker => _apoteker,
        UserRole.superadmin => _superadmin,
      };

  static const List<NavItem> _pengguna = [
    NavItem(
      label: 'Home',
      icon: Icons.home_outlined,
      selectedIcon: Icons.home,
      path: RoutePaths.pengguna,
    ),
    NavItem(
      label: 'Obat',
      icon: Icons.medication_outlined,
      selectedIcon: Icons.medication,
      path: RoutePaths.penggunaObat,
    ),
    NavItem(
      label: 'Edukasi',
      icon: Icons.menu_book_outlined,
      selectedIcon: Icons.menu_book,
      path: RoutePaths.penggunaEdukasi,
    ),
    NavItem(
      label: 'Konsultasi',
      icon: Icons.forum_outlined,
      selectedIcon: Icons.forum,
      path: RoutePaths.penggunaKonsultasi,
    ),
    NavItem(
      label: 'Profile',
      icon: Icons.person_outline,
      selectedIcon: Icons.person,
      path: RoutePaths.penggunaProfile,
    ),
  ];

  static const List<NavItem> _apoteker = [
    NavItem(
      label: 'Dashboard',
      icon: Icons.dashboard_outlined,
      selectedIcon: Icons.dashboard,
      path: RoutePaths.apoteker,
    ),
    NavItem(
      label: 'Obat',
      icon: Icons.medication_outlined,
      selectedIcon: Icons.medication,
      path: RoutePaths.apotekerObat,
    ),
    NavItem(
      label: 'Stok',
      icon: Icons.inventory_2_outlined,
      selectedIcon: Icons.inventory_2,
      path: RoutePaths.apotekerStok,
    ),
    NavItem(
      label: 'Konsultasi',
      icon: Icons.forum_outlined,
      selectedIcon: Icons.forum,
      path: RoutePaths.apotekerKonsultasi,
    ),
    NavItem(
      label: 'Profile',
      icon: Icons.person_outline,
      selectedIcon: Icons.person,
      path: RoutePaths.apotekerProfile,
    ),
  ];

  static const List<NavItem> _superadmin = [
    NavItem(
      label: 'Dashboard',
      icon: Icons.dashboard_outlined,
      selectedIcon: Icons.dashboard,
      path: RoutePaths.superadmin,
    ),
    NavItem(
      label: 'Users',
      icon: Icons.group_outlined,
      selectedIcon: Icons.group,
      path: RoutePaths.superadminUsers,
    ),
    NavItem(
      label: 'Apoteker',
      icon: Icons.local_pharmacy_outlined,
      selectedIcon: Icons.local_pharmacy,
      path: RoutePaths.superadminApoteker,
    ),
    NavItem(
      label: 'Settings',
      icon: Icons.settings_outlined,
      selectedIcon: Icons.settings,
      path: RoutePaths.superadminSettings,
    ),
    NavItem(
      label: 'Profile',
      icon: Icons.person_outline,
      selectedIcon: Icons.person,
      path: RoutePaths.superadminProfile,
    ),
  ];
}