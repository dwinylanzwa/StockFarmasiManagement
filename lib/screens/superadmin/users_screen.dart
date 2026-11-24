import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/app_user.dart';
import '../../models/user_role.dart';
import '../../providers/current_user_provider.dart';
import '../../providers/user_admin_provider.dart';
import '../../widgets/role_badge.dart';
import '../../widgets/user_edit_sheet.dart';

class UsersScreen extends ConsumerStatefulWidget {
  const UsersScreen({super.key});

  @override
  ConsumerState<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends ConsumerState<UsersScreen> {
  final _searchController = TextEditingController();
  String _query = '';
  UserRole? _roleFilter;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<AppUser> _applyFilters(List<AppUser> users) {
    final query = _query.trim().toLowerCase();
    return users.where((user) {
      final matchesRole = _roleFilter == null || user.role == _roleFilter;
      final matchesQuery = query.isEmpty ||
          user.nama.toLowerCase().contains(query) ||
          user.email.toLowerCase().contains(query);
      return matchesRole && matchesQuery;
    }).toList();
  }

  void _onTapUser(AppUser user, AppUser? me) {
    if (me?.uid == user.uid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Akun Anda sendiri tidak dapat diubah dari sini.'),
        ),
      );
      return;
    }
    showUserEditSheet(context, user);
  }

  @override
  Widget build(BuildContext context) {
    final usersAsync = ref.watch(usersStreamProvider);
    final me = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Users')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _query = value),
              decoration: InputDecoration(
                hintText: 'Cari nama atau email',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _query.isEmpty
                    ? null
                    : IconButton(
                        tooltip: 'Hapus pencarian',
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _query = '');
                        },
                      ),
              ),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                ChoiceChip(
                  label: const Text('Semua'),
                  selected: _roleFilter == null,
                  onSelected: (_) => setState(() => _roleFilter = null),
                ),
                for (final role in UserRole.values) ...[
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: Text(role.label),
                    selected: _roleFilter == role,
                    onSelected: (_) => setState(() => _roleFilter = role),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: usersAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, _) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Gagal memuat daftar user.'),
                    TextButton(
                      onPressed: () => ref.invalidate(usersStreamProvider),
                      child: const Text('Coba lagi'),
                    ),
                  ],
                ),
              ),
              data: (users) {
                final filtered = _applyFilters(users);
                if (filtered.isEmpty) {
                  return const Center(child: Text('Tidak ada user ditemukan.'));
                }
                return ListView.separated(
                  itemCount: filtered.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final user = filtered[index];
                    final isMe = me?.uid == user.uid;
                    return ListTile(
                      leading: CircleAvatar(
                        child: Text(
                          user.nama.isEmpty ? '?' : user.nama[0].toUpperCase(),
                        ),
                      ),
                      title: Text(isMe ? '${user.nama} (Anda)' : user.nama),
                      subtitle: Text(user.email),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (!user.isActive)
                            Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: Icon(
                                Icons.block,
                                size: 18,
                                color: Theme.of(context).colorScheme.error,
                              ),
                            ),
                          RoleBadge(role: user.role),
                        ],
                      ),
                      onTap: () => _onTapUser(user, me),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}