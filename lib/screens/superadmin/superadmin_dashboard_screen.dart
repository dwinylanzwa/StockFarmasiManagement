import 'package:flutter/material.dart';

import '../../models/user_role.dart';
import '../../widgets/dashboard_welcome.dart';

class SuperAdminDashboardScreen extends StatelessWidget {
  const SuperAdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard Superadmin')),
      body: const DashboardWelcome(role: UserRole.superadmin),
    );
  }
}