import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Ditampilkan untuk path yang tidak dikenal.
class NotFoundPage extends StatelessWidget {
  const NotFoundPage({required this.homePath, super.key});

  /// Tujuan tombol kembali (dashboard role atau login).
  final String homePath;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tidak ditemukan')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Halaman tidak ditemukan.'),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => context.go(homePath),
              child: const Text('Kembali'),
            ),
          ],
        ),
      ),
    );
  }
}