import 'package:flutter/material.dart';

import '../../models/user_role.dart';
import '../../widgets/dashboard_welcome.dart';

class UserDashboardScreen extends StatelessWidget {
  const UserDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard Pengguna')),
      body: const DashboardWelcome(role: UserRole.pengguna),
    );
  }
}