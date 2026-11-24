import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/auth_provider.dart';
import '../providers/current_user_provider.dart';

/// Isi halaman Profile (dipakai semua role): data akun dan tombol Logout.
class ProfileContent extends ConsumerWidget {
  const ProfileContent({super.key});

  static String _formatDate(DateTime date) {
    final d = date.day.toString().padLeft(2, '0');
    final m = date.month.toString().padLeft(2, '0');
    return '$d/$m/${date.year}';
  }

  Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Keluar dari akun?'),
        content: const Text('Anda harus login kembali untuk melanjutkan.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirmed ?? false) {
      // Session dihapus; RouteGuard otomatis mengalihkan ke Login.
      await ref.read(authProvider.notifier).signOut();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final user = ref.watch(currentUserProvider);
    if (user == null) return const SizedBox.shrink();

    final initial = user.nama.isEmpty ? '?' : user.nama[0].toUpperCase();

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Center(
          child: CircleAvatar(
            radius: 40,
            child: Text(initial, style: theme.textTheme.headlineMedium),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          user.nama,
          textAlign: TextAlign.center,
          style: theme.textTheme.titleLarge,
        ),
        Text(
          user.email,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: 24),
        Card(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.badge_outlined),
                title: const Text('Role'),
                subtitle: Text(user.role.label),
              ),
              ListTile(
                leading: const Icon(Icons.check_circle_outline),
                title: const Text('Status akun'),
                subtitle: Text(user.isActive ? 'Aktif' : 'Nonaktif'),
              ),
              ListTile(
                leading: const Icon(Icons.event_outlined),
                title: const Text('Bergabung sejak'),
                subtitle: Text(_formatDate(user.createdAt)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        FilledButton.icon(
          onPressed: () => _confirmLogout(context, ref),
          icon: const Icon(Icons.logout),
          label: const Text('Logout'),
        ),
      ],
    );
  }
}