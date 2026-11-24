import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../navigation/route_paths.dart';

/// Tombol uji RBAC. Hanya tampil di debug mode.
///
/// Mencoba membuka path milik role lain harus dialihkan oleh
/// `RouteGuard` kembali ke dashboard role sendiri.
class RbacDebugPanel extends StatelessWidget {
  const RbacDebugPanel({super.key});

  static const List<String> _probes = [
    RoutePaths.penggunaObat,
    RoutePaths.apotekerStok,
    RoutePaths.superadminUsers,
  ];

  @override
  Widget build(BuildContext context) {
    if (!kDebugMode) return const SizedBox.shrink();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('Uji RBAC (hanya debug):'),
        const SizedBox(height: 8),
        for (final path in _probes)
          TextButton(
            onPressed: () => context.go(path),
            child: Text('Buka $path'),
          ),
      ],
    );
  }
}