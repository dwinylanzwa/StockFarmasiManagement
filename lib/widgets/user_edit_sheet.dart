import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../errors/admin_exception.dart';
import '../models/app_user.dart';
import '../models/user_role.dart';
import '../providers/apotek_provider.dart';
import '../providers/user_admin_provider.dart';

/// Membuka sheet untuk mengubah role, apotek tugas, dan status [user].
Future<void> showUserEditSheet(BuildContext context, AppUser user) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => UserEditSheet(user: user),
  );
}

class UserEditSheet extends ConsumerStatefulWidget {
  const UserEditSheet({required this.user, super.key});

  final AppUser user;

  @override
  ConsumerState<UserEditSheet> createState() => _UserEditSheetState();
}

class _UserEditSheetState extends ConsumerState<UserEditSheet> {
  late UserRole _role = widget.user.role;
  late String? _apotekId = widget.user.apotekId;
  late bool _isActive = widget.user.isActive;
  bool _saving = false;
  String? _error;

  bool get _roleChanged => _role != widget.user.role;
  bool get _apotekChanged =>
      _role == UserRole.apoteker && _apotekId != widget.user.apotekId;
  bool get _accessChanged => _roleChanged || _apotekChanged;
  bool get _activeChanged => _isActive != widget.user.isActive;
  bool get _changed => _accessChanged || _activeChanged;

  Future<bool> _confirmSuperadmin() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Jadikan Superadmin?'),
        content: Text(
          '${widget.user.nama} akan memiliki akses penuh ke manajemen user '
          'dan konfigurasi sistem.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Ya, jadikan'),
          ),
        ],
      ),
    );
    return confirmed ?? false;
  }

  Future<void> _save() async {
    if (!_changed || _saving) return;

    if (_roleChanged && _role == UserRole.superadmin) {
      if (!await _confirmSuperadmin()) return;
      if (!mounted) return;
    }

    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final controller = ref.read(userAdminControllerProvider);

    setState(() {
      _saving = true;
      _error = null;
    });

    try {
      if (_accessChanged) {
        await controller.updateAccess(
          widget.user,
          role: _role,
          apotekId: _apotekId,
        );
      }
      if (_activeChanged) {
        await controller.setActive(widget.user, isActive: _isActive);
      }
      navigator.pop();
      messenger.showSnackBar(
        const SnackBar(content: Text('Perubahan disimpan.')),
      );
    } on AdminActionException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Widget _buildApotekPicker(ThemeData theme) {
    final apotekAsync = ref.watch(allApotekStreamProvider);

    return apotekAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: LinearProgressIndicator(),
      ),
      error: (_, _) => const Text('Gagal memuat daftar apotek.'),
      data: (list) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Apotek tempat bertugas', style: theme.textTheme.titleSmall),
          const SizedBox(height: 8),
          if (list.isEmpty)
            const Text('Belum ada apotek. Buat di Settings → Kelola Apotek.')
          else
            Wrap(
              spacing: 8,
              children: [
                ChoiceChip(
                  label: const Text('Belum ditugaskan'),
                  selected: _apotekId == null,
                  onSelected: _saving
                      ? null
                      : (_) => setState(() => _apotekId = null),
                ),
                for (final apotek in list)
                  ChoiceChip(
                    label: Text(
                      apotek.isActive ? apotek.nama : '${apotek.nama} (nonaktif)',
                    ),
                    selected: _apotekId == apotek.id,
                    onSelected: _saving
                        ? null
                        : (_) => setState(() => _apotekId = apotek.id),
                  ),
              ],
            ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          24,
          0,
          24,
          24 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(widget.user.nama, style: theme.textTheme.titleLarge),
            Text(widget.user.email, style: theme.textTheme.bodyMedium),
            const SizedBox(height: 24),
            Text('Role', style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                for (final role in UserRole.values)
                  ChoiceChip(
                    label: Text(role.label),
                    selected: _role == role,
                    onSelected: _saving
                        ? null
                        : (selected) {
                            if (selected) setState(() => _role = role);
                          },
                  ),
              ],
            ),
            if (_role == UserRole.apoteker) ...[
              const SizedBox(height: 16),
              _buildApotekPicker(theme),
            ],
            const SizedBox(height: 8),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Akun aktif'),
              subtitle: const Text(
                'Akun nonaktif tidak dapat login dan langsung dikeluarkan '
                'jika sedang login.',
              ),
              value: _isActive,
              onChanged:
                  _saving ? null : (value) => setState(() => _isActive = value),
            ),
            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(
                _error!,
                style: TextStyle(color: theme.colorScheme.error),
              ),
            ],
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _changed && !_saving ? _save : null,
              child: _saving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }
}