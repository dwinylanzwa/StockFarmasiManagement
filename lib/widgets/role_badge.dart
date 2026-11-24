import 'package:flutter/material.dart';

import '../models/user_role.dart';

/// Lencana kecil berwarna untuk menampilkan role.
///
/// `switch` exhaustive: role baru wajib diberi warna di sini.
class RoleBadge extends StatelessWidget {
  const RoleBadge({required this.role, super.key});

  final UserRole role;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final (background, foreground) = switch (role) {
      UserRole.pengguna => (
          scheme.secondaryContainer,
          scheme.onSecondaryContainer,
        ),
      UserRole.apoteker => (
          scheme.tertiaryContainer,
          scheme.onTertiaryContainer,
        ),
      UserRole.superadmin => (
          scheme.primaryContainer,
          scheme.onPrimaryContainer,
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        role.label,
        style: Theme.of(context)
            .textTheme
            .labelSmall
            ?.copyWith(color: foreground),
      ),
    );
  }
}