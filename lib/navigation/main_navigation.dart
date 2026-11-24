import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/user_role.dart';
import 'role_navigation.dart';

/// Kerangka halaman dengan [NavigationBar] untuk satu role.
///
/// Isi tab ([navigationShell]) disediakan GoRouter dan state tiap tab
/// dipertahankan saat berpindah.
class MainNavigation extends StatelessWidget {
  const MainNavigation({
    required this.role,
    required this.navigationShell,
    super.key,
  });

  final UserRole role;
  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final items = RoleNavigation.itemsFor(role);

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) => navigationShell.goBranch(
          index,
          // Menekan tab yang sedang aktif kembali ke halaman awal tab itu.
          initialLocation: index == navigationShell.currentIndex,
        ),
        destinations: [
          for (final item in items)
            NavigationDestination(
              icon: Icon(item.icon),
              selectedIcon: Icon(item.selectedIcon),
              label: item.label,
            ),
        ],
      ),
    );
  }
}