import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../navigation/route_paths.dart';
import '../../providers/obat_provider.dart';
import '../../widgets/obat_browser.dart';

class ApotekerObatScreen extends ConsumerWidget {
  const ApotekerObatScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Obat')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go(RoutePaths.apotekerObatTambah),
        icon: const Icon(Icons.add),
        label: const Text('Tambah Obat'),
      ),
      body: ObatBrowser(
        obatAsync: ref.watch(allObatStreamProvider),
        onRetry: () => ref.invalidate(allObatStreamProvider),
        onTapObat: (obat) =>
            context.go(RoutePaths.apotekerObatDetail(obat.id)),
        bottomInset: 96,
      ),
    );
  }
}