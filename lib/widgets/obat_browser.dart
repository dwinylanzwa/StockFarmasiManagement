import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/obat.dart';
import '../models/obat_golongan.dart';
import '../utils/obat_filter.dart';
import 'golongan_badge.dart';

/// Daftar obat dengan pencarian dan filter golongan.
///
/// Dipakai Pengguna dan Apoteker. Widget ini hanya menampilkan data
/// yang diberikan; sumber data dan aksi ketuk ditentukan pemakainya.
class ObatBrowser extends StatefulWidget {
  const ObatBrowser({
    required this.obatAsync,
    required this.onRetry,
    required this.onTapObat,
    this.bottomInset = 0,
    super.key,
  });

  final AsyncValue<List<Obat>> obatAsync;
  final VoidCallback onRetry;
  final ValueChanged<Obat> onTapObat;

  /// Ruang kosong di bawah daftar (mis. agar tidak tertutup tombol FAB).
  final double bottomInset;

  @override
  State<ObatBrowser> createState() => _ObatBrowserState();
}

class _ObatBrowserState extends State<ObatBrowser> {
  final _searchController = TextEditingController();
  String _query = '';
  ObatGolongan? _golongan;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  static String _subtitle(Obat obat) {
    final parts = <String>[
      if (obat.namaGenerik.isNotEmpty) obat.namaGenerik,
      obat.bentuk.label,
      if (!obat.isActive) 'Nonaktif',
    ];
    return parts.join(' • ');
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: TextField(
            controller: _searchController,
            onChanged: (value) => setState(() => _query = value),
            decoration: InputDecoration(
              hintText: 'Cari nama obat atau nama generik',
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
                selected: _golongan == null,
                onSelected: (_) => setState(() => _golongan = null),
              ),
              for (final golongan in ObatGolongan.values) ...[
                const SizedBox(width: 8),
                ChoiceChip(
                  label: Text(golongan.label),
                  selected: _golongan == golongan,
                  onSelected: (_) => setState(() => _golongan = golongan),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 8),
        Expanded(child: _buildList(context)),
      ],
    );
  }

  Widget _buildList(BuildContext context) {
    return widget.obatAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, _) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Gagal memuat data obat.'),
            TextButton(
              onPressed: widget.onRetry,
              child: const Text('Coba lagi'),
            ),
          ],
        ),
      ),
      data: (all) {
        if (all.isEmpty) {
          return const Center(child: Text('Belum ada data obat.'));
        }
        final filtered = ObatFilter.apply(
          all,
          query: _query,
          golongan: _golongan,
        );
        if (filtered.isEmpty) {
          return const Center(child: Text('Obat tidak ditemukan.'));
        }
        return ListView.separated(
          padding: EdgeInsets.only(bottom: widget.bottomInset),
          itemCount: filtered.length,
          separatorBuilder: (_, _) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final obat = filtered[index];
            return Opacity(
              opacity: obat.isActive ? 1 : 0.5,
              child: ListTile(
                leading: const CircleAvatar(
                  child: Icon(Icons.medication_outlined),
                ),
                title: Text(obat.displayName),
                subtitle: Text(_subtitle(obat)),
                trailing: GolonganBadge(golongan: obat.golongan),
                onTap: () => widget.onTapObat(obat),
              ),
            );
          },
        );
      },
    );
  }
}