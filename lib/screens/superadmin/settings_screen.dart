import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../navigation/route_paths.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.local_pharmacy_outlined),
            title: const Text('Kelola Apotek'),
            subtitle: const Text('Tambah apotek dan tentukan lokasinya di peta'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.go(RoutePaths.superadminApotek),
          ),
        ],
      ),
    );
  }
}