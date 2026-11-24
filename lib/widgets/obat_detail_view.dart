import 'package:flutter/material.dart';

import '../models/obat.dart';
import 'golongan_badge.dart';

/// Isi halaman detail obat (read-only), dipakai Pengguna.
class ObatDetailView extends StatelessWidget {
  const ObatDetailView({required this.obat, super.key});

  final Obat obat;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final warning = obat.golongan.warning;

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text(obat.nama, style: theme.textTheme.headlineSmall),
        if (obat.namaGenerik.isNotEmpty)
          Text(obat.namaGenerik, style: theme.textTheme.bodyLarge),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerLeft,
          child: GolonganBadge(golongan: obat.golongan),
        ),
        if (warning != null) ...[
          const SizedBox(height: 16),
          _WarningBox(
            message: warning,
            strong: obat.golongan.requiresPrescription,
          ),
        ],
        const SizedBox(height: 16),
        Card(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.category_outlined),
                title: const Text('Bentuk sediaan'),
                subtitle: Text(obat.bentuk.label),
              ),
              if (obat.kekuatan.isNotEmpty)
                ListTile(
                  leading: const Icon(Icons.science_outlined),
                  title: const Text('Kekuatan'),
                  subtitle: Text(obat.kekuatan),
                ),
              if (obat.produsen.isNotEmpty)
                ListTile(
                  leading: const Icon(Icons.factory_outlined),
                  title: const Text('Produsen'),
                  subtitle: Text(obat.produsen),
                ),
            ],
          ),
        ),
        _TextSection(title: 'Deskripsi', body: obat.deskripsi),
        _TextSection(title: 'Indikasi', body: obat.indikasi),
        _TextSection(title: 'Peringatan', body: obat.peringatan),
        const SizedBox(height: 16),
        const Card(
          child: ListTile(
            leading: Icon(Icons.inventory_2_outlined),
            title: Text('Ketersediaan'),
            subtitle: Text('Informasi stok akan tersedia pada tahap berikutnya.'),
          ),
        ),
      ],
    );
  }
}

class _WarningBox extends StatelessWidget {
  const _WarningBox({required this.message, required this.strong});

  final String message;
  final bool strong;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final background =
        strong ? scheme.errorContainer : scheme.secondaryContainer;
    final foreground =
        strong ? scheme.onErrorContainer : scheme.onSecondaryContainer;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.warning_amber_rounded, color: foreground),
          const SizedBox(width: 12),
          Expanded(
            child: Text(message, style: TextStyle(color: foreground)),
          ),
        ],
      ),
    );
  }
}

class _TextSection extends StatelessWidget {
  const _TextSection({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    if (body.isEmpty) return const SizedBox.shrink();
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: theme.textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(body, style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }
}