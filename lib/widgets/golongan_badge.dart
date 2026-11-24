import 'package:flutter/material.dart';

import '../models/obat_golongan.dart';

/// Lencana berwarna untuk golongan obat.
///
/// `switch` exhaustive: golongan baru wajib diberi warna di sini.
class GolonganBadge extends StatelessWidget {
  const GolonganBadge({required this.golongan, super.key});

  final ObatGolongan golongan;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final (background, foreground) = switch (golongan) {
      ObatGolongan.bebas => (
          scheme.primaryContainer,
          scheme.onPrimaryContainer,
        ),
      ObatGolongan.bebasTerbatas => (
          scheme.secondaryContainer,
          scheme.onSecondaryContainer,
        ),
      ObatGolongan.keras => (
          scheme.tertiaryContainer,
          scheme.onTertiaryContainer,
        ),
      ObatGolongan.narkotika || ObatGolongan.psikotropika => (
          scheme.errorContainer,
          scheme.onErrorContainer,
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        golongan.label,
        style: Theme.of(context)
            .textTheme
            .labelSmall
            ?.copyWith(color: foreground),
      ),
    );
  }
}