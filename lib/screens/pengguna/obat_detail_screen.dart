import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/obat_provider.dart';
import '../../widgets/obat_detail_view.dart';

class ObatDetailScreen extends ConsumerWidget {
  const ObatDetailScreen({required this.obatId, super.key});

  final String obatId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final obatAsync = ref.watch(obatByIdProvider(obatId));

    return Scaffold(
      appBar: AppBar(title: const Text('Detail Obat')),
      body: obatAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        // Termasuk obat nonaktif: Rules menolak baca, jadi tampil sebagai error.
        error: (_, _) => const Center(child: Text('Obat tidak tersedia.')),
        data: (obat) => obat == null
            ? const Center(child: Text('Obat tidak ditemukan.'))
            : ObatDetailView(obat: obat),
      ),
    );
  }
}