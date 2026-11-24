import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/apotek_provider.dart';
import 'app_map.dart';

/// Menampilkan apotek tempat Apoteker bertugas beserta petanya.
class MyApotekCard extends ConsumerWidget {
  const MyApotekCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final apotekAsync = ref.watch(myApotekProvider);

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: apotekAsync.when(
          loading: () => const LinearProgressIndicator(),
          error: (_, _) => const Text('Gagal memuat data apotek.'),
          data: (apotek) {
            if (apotek == null) {
              return const Row(
                children: [
                  Icon(Icons.info_outline),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Anda belum ditugaskan ke apotek. Hubungi Superadmin.',
                    ),
                  ),
                ],
              );
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Apotek Anda', style: theme.textTheme.labelMedium),
                Text(apotek.nama, style: theme.textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(apotek.alamat),
                  const SizedBox(height: 4),
                Text(apotek.jadwal.ringkas),
                if (!apotek.isActive) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Apotek ini sedang nonaktif.',
                    style: TextStyle(color: theme.colorScheme.error),
                  ),
                ],
                const SizedBox(height: 12),
                ApotekMapPreview(
                  latitude: apotek.latitude,
                  longitude: apotek.longitude,
                  height: 140,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}