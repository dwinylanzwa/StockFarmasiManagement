import 'package:flutter/material.dart';

import '../../widgets/profile_content.dart';

class PenggunaProfileScreen extends StatelessWidget {
  const PenggunaProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: const ProfileContent(),
    );
  }
}