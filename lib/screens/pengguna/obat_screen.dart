import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../navigation/route_paths.dart';
import '../../providers/obat_provider.dart';
import '../../widgets/obat_browser.dart';

class PenggunaObatScreen extends ConsumerWidget {
  const PenggunaObatScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Obat')),
      body: ObatBrowser(
        obatAsync: ref.watch(activeObatStreamProvider),
        onRetry: () => ref.invalidate(activeObatStreamProvider),
        onTapObat: (obat) =>
            context.go(RoutePaths.penggunaObatDetail(obat.id)),
      ),
    );
  }
}