import 'package:flutter/material.dart';

/// Halaman sementara: Scaffold dengan judul dan satu teks.
/// Diganti halaman sungguhan saat fiturnya dikerjakan.
class PlaceholderScreen extends StatelessWidget {
  const PlaceholderScreen({
    required this.title,
    required this.message,
    super.key,
  });

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(child: Text(message)),
    );
  }
}