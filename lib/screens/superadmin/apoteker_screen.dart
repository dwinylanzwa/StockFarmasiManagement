import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../errors/admin_exception.dart';
import '../../models/app_user.dart';
import '../../models/invite.dart';
import '../../models/user_role.dart';
import '../../providers/user_admin_provider.dart';
import '../../utils/formatters.dart';
import '../../widgets/invite_apoteker_dialog.dart';

class SuperadminApotekerScreen extends StatelessWidget {
  const SuperadminApotekerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Apoteker')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showDialog<void>(
          context: context,
          builder: (_) => const InviteApotekerDialog(),
        ),
        icon: const Icon(Icons.person_add_alt_1),
        label: const Text('Undang Apoteker'),
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 96),
        children: const [
          _SectionTitle('Akun Apoteker'),
          _ApotekerSection(),
          _SectionTitle('Undangan menunggu'),
          _InviteSection(),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(text, style: Theme.of(context).textTheme.titleMedium),
    );
  }
}

class _EmptyText extends StatelessWidget {
  const _EmptyText(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(text),
    );
  }
}

class _ApotekerSection extends ConsumerWidget {
  const _ApotekerSection();

  Future<void> _toggle(
    BuildContext context,
    WidgetRef ref,
    AppUser user, {
    required bool isActive,
  }) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref
          .read(userAdminControllerProvider)
          .setActive(user, isActive: isActive);
    } on AdminActionException catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersAsync = ref.watch(usersStreamProvider);

    return usersAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.all(24),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (_, _) => const _EmptyText('Gagal memuat akun Apoteker.'),
      data: (users) {
        final apoteker =
            users.where((u) => u.role == UserRole.apoteker).toList();
        if (apoteker.isEmpty) {
          return const _EmptyText('Belum ada akun Apoteker.');
        }
        return Column(
          children: [
            for (final user in apoteker)
              ListTile(
                leading: const CircleAvatar(
                  child: Icon(Icons.local_pharmacy_outlined),
                ),
                title: Text(user.nama),
                subtitle: Text(
                  '${user.email}\n${user.isActive ? 'Aktif' : 'Nonaktif'}',
                ),
                isThreeLine: true,
                trailing: Switch(
                  value: user.isActive,
                  onChanged: (value) =>
                      _toggle(context, ref, user, isActive: value),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _InviteSection extends ConsumerWidget {
  const _InviteSection();

  Future<void> _delete(
    BuildContext context,
    WidgetRef ref,
    Invite invite,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref.read(userAdminControllerProvider).deleteInvite(invite.email);
      messenger.showSnackBar(
        const SnackBar(content: Text('Undangan dibatalkan.')),
      );
    } on AdminActionException catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final invitesAsync = ref.watch(invitesStreamProvider);

    return invitesAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.all(24),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (_, _) => const _EmptyText('Gagal memuat undangan.'),
      data: (invites) {
        final pending =
            invites.where((i) => i.role == UserRole.apoteker).toList();
        if (pending.isEmpty) {
          return const _EmptyText('Tidak ada undangan.');
        }
        return Column(
          children: [
            for (final invite in pending)
              ListTile(
                leading: const Icon(Icons.mail_outline),
                title: Text(invite.email),
                subtitle: Text('Dibuat ${Formatters.date(invite.createdAt)}'),
                trailing: IconButton(
                  tooltip: 'Batalkan undangan',
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => _delete(context, ref, invite),
                ),
              ),
          ],
        );
      },
    );
  }
}