import 'package:flutter/material.dart';

import '../../models/user_role.dart';
import '../../widgets/dashboard_welcome.dart';
import '../../widgets/my_apotek_card.dart';

class ApotekerDashboardScreen extends StatelessWidget {
  const ApotekerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard Apoteker')),
      body: const Column(
        children: [
          MyApotekCard(),
          Expanded(child: DashboardWelcome(role: UserRole.apoteker)),
        ],
      ),
    );
  }
}