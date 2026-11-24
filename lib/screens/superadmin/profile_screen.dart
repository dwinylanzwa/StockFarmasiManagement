import 'package:flutter/material.dart';

import '../../widgets/profile_content.dart';

class SuperadminProfileScreen extends StatelessWidget {
  const SuperadminProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: const ProfileContent(),
    );
  }
}