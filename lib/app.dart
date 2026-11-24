import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'navigation/app_router.dart';
import 'theme/app_theme.dart';

/// Root widget. Navigasi sepenuhnya dikendalikan GoRouter.
class HalObatApp extends ConsumerWidget {
  const HalObatApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'HalObat',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      routerConfig: ref.watch(routerProvider),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';

// import 'models/app_user.dart';
// import 'models/auth_state.dart';
// import 'providers/auth_provider.dart';
// import 'screens/login_page.dart';
// import 'theme/app_theme.dart';

// /// SEMENTARA: memilih layar berdasarkan [AuthState]. Di Tahap 1D diganti
// /// GoRouter dengan redirect dan guard per role.
// class HalObatApp extends ConsumerWidget {
//   const HalObatApp({super.key});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final authState = ref.watch(authProvider);

//     return MaterialApp(
//       title: 'HalObat',
//       debugShowCheckedModeBanner: false,
//       theme: AppTheme.light,
//       darkTheme: AppTheme.dark,
//       themeMode: ThemeMode.system,
//       home: switch (authState) {
//         AuthInitial() || AuthLoading() => const _SplashScreen(),
//         AuthUnauthenticated() => const LoginPage(),
//         AuthAuthenticated(:final user) => _TemporaryHomeScreen(user: user),
//       },
//     );
//   }
// }

// class _SplashScreen extends StatelessWidget {
//   const _SplashScreen();

//   @override
//   Widget build(BuildContext context) {
//     return const Scaffold(body: Center(child: CircularProgressIndicator()));
//   }
// }

// /// SEMENTARA: bukti login berhasil, role terbaca, dan logout berfungsi.
// class _TemporaryHomeScreen extends ConsumerWidget {
//   const _TemporaryHomeScreen({required this.user});

//   final AppUser user;

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('HalObat – Cek Tahap 1C'),
//         actions: [
//           IconButton(
//             tooltip: 'Logout',
//             icon: const Icon(Icons.logout),
//             onPressed: () => ref.read(authProvider.notifier).signOut(),
//           ),
//         ],
//       ),
//       body: Center(
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Text('Halo, ${user.nama}'),
//             Text(user.email),
//             Text('Role: ${user.role.label}'),
//             Text('UID: ${user.uid}'),
//           ],
//         ),
//       ),
//     );
//   }
// }
// // import 'package:firebase_core/firebase_core.dart';
// // import 'package:flutter/material.dart';

// // import 'theme/app_theme.dart';

// // /// Root widget. Di Tahap 1D diganti menjadi `MaterialApp.router`.
// // class HalObatApp extends StatelessWidget {
// //   const HalObatApp({super.key});

// //   @override
// //   Widget build(BuildContext context) {
// //     return MaterialApp(
// //       title: 'HalObat',
// //       debugShowCheckedModeBanner: false,
// //       theme: AppTheme.light,
// //       darkTheme: AppTheme.dark,
// //       themeMode: ThemeMode.system,
// //       home: const _FirebaseCheckScreen(),
// //     );
// //   }
// // }

// // /// SEMENTARA: membuktikan Firebase sudah terinisialisasi.
// // class _FirebaseCheckScreen extends StatelessWidget {
// //   const _FirebaseCheckScreen();

// //   @override
// //   Widget build(BuildContext context) {
// //     final app = Firebase.app();
// //     return Scaffold(
// //       appBar: AppBar(title: const Text('HalObat – Cek Firebase')),
// //       body: Center(
// //         child: Text('Firebase terhubung ke project:\n${app.options.projectId}',
// //             textAlign: TextAlign.center),
// //       ),
// //     );
// //   }
// // }