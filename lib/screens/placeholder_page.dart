import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/auth_state.dart';
import '../navigation/route_paths.dart';
import '../providers/auth_provider.dart';

/// Halaman sementara untuk Tahap 1D. Diganti halaman sungguhan di 1E.
///
/// Di debug mode menampilkan tombol uji RBAC: mencoba membuka path milik
/// role lain harus dialihkan kembali ke dashboard sendiri.
class PlaceholderPage extends ConsumerWidget {
  const PlaceholderPage({required this.title, super.key});

  /// Contoh: "Ini Dashboard Pengguna".
  final String title;

  static const List<(String, String)> _rbacProbes = [
    ('/pengguna/obat', RoutePaths.penggunaObat),
    ('/apoteker/stok', RoutePaths.apotekerStok),
    ('/superadmin/users', RoutePaths.superadminUsers),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState is AuthAuthenticated ? authState.user : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('HalObat'),
        actions: [
          IconButton(
            tooltip: 'Logout',
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(authProvider.notifier).signOut(),
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleLarge),
              if (user != null) ...[
                const SizedBox(height: 8),
                Text('${user.nama} (${user.role.label})'),
              ],
              if (kDebugMode) ...[
                const SizedBox(height: 32),
                const Text('Uji RBAC (hanya debug):'),
                const SizedBox(height: 8),
                for (final (label, path) in _rbacProbes)
                  TextButton(
                    onPressed: () => context.go(path),
                    child: Text('Buka $label'),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}