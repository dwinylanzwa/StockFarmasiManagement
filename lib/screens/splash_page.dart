import 'package:flutter/material.dart';

/// Ditampilkan saat session sedang diperiksa.
class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}