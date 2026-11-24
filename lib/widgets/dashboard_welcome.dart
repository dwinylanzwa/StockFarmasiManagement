import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/user_role.dart';
import '../providers/current_user_provider.dart';
import 'rbac_debug_panel.dart';

/// Isi dashboard sementara: nama user dan role tempat ia login.
class DashboardWelcome extends ConsumerWidget {
  const DashboardWelcome({required this.role, super.key});

  final UserRole role;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final user = ref.watch(currentUserProvider);

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.verified_user_outlined,
              size: 56,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'Halo, ${user?.nama ?? '-'}',
              style: theme.textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Anda login sebagai ${role.label}',
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: 32),
            const RbacDebugPanel(),
          ],
        ),
      ),
    );
  }
}