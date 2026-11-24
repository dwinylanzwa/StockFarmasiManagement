import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../navigation/route_paths.dart';
import '../../providers/apotek_provider.dart';

/// Daftar semua apotek (Superadmin).
class ApotekListScreen extends ConsumerWidget {
  const ApotekListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final apotekAsync = ref.watch(allApotekStreamProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Kelola Apotek')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go(RoutePaths.superadminApotekTambah),
        icon: const Icon(Icons.add_business_outlined),
        label: const Text('Tambah Apotek'),
      ),
      body: apotekAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Gagal memuat data apotek.'),
              TextButton(
                onPressed: () => ref.invalidate(allApotekStreamProvider),
                child: const Text('Coba lagi'),
              ),
            ],
          ),
        ),
        data: (list) {
          if (list.isEmpty) {
            return const Center(child: Text('Belum ada apotek.'));
          }
          return ListView.separated(
            padding: const EdgeInsets.only(bottom: 96),
            itemCount: list.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final apotek = list[index];
              return Opacity(
                opacity: apotek.isActive ? 1 : 0.5,
                child: ListTile(
                  leading: const CircleAvatar(
                    child: Icon(Icons.local_pharmacy_outlined),
                  ),
                  title: Text(apotek.nama),
                  subtitle: Text(
                    apotek.isActive
                        ? apotek.alamat
                        : '${apotek.alamat}\nNonaktif',
                  ),
                  isThreeLine: !apotek.isActive,
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () =>
                      context.go(RoutePaths.superadminApotekDetail(apotek.id)),
                ),
              );
            },
          );
        },
      ),
    );
  }
}