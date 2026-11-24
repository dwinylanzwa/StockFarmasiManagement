import 'package:flutter/material.dart';

import '../../widgets/placeholder_screen.dart';

class StokScreen extends StatelessWidget {
  const StokScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(
      title: 'Stok',
      message: 'Ini Halaman Stok (Apoteker)',
    );
  }
}