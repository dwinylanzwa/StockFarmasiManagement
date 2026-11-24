import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/auth_state.dart';
import '../models/user_role.dart';
import '../providers/auth_provider.dart';
import '../screens/apoteker/apoteker_dashboard_screen.dart';
import '../screens/apoteker/konsultasi_screen.dart';
import '../screens/apoteker/obat_form_screen.dart';
import '../screens/apoteker/obat_screen.dart';
import '../screens/apoteker/profile_screen.dart';
import '../screens/apoteker/stok_screen.dart';
import '../screens/login_page.dart';
import '../screens/not_found_page.dart';
import '../screens/pengguna/edukasi_screen.dart';
import '../screens/pengguna/konsultasi_screen.dart';
import '../screens/pengguna/obat_detail_screen.dart';
import '../screens/pengguna/obat_screen.dart';
import '../screens/pengguna/profile_screen.dart';
import '../screens/pengguna/user_dashboard_screen.dart';
import '../screens/register_page.dart';
import '../screens/splash_page.dart';
import '../screens/superadmin/apoteker_screen.dart';
import '../screens/superadmin/profile_screen.dart';
import '../screens/superadmin/settings_screen.dart';
import '../screens/superadmin/superadmin_dashboard_screen.dart';
import '../screens/superadmin/users_screen.dart';
import '../screens/superadmin/apotek_form_screen.dart';
import '../screens/superadmin/apotek_list_screen.dart';
import 'main_navigation.dart';
import 'role_navigation.dart';
import 'route_guard.dart';
import 'route_paths.dart';

/// Menyediakan [GoRouter] tunggal untuk aplikasi.
final routerProvider = Provider<GoRouter>((ref) {
  // Setiap AuthState berubah, router diminta mengevaluasi ulang redirect.
  final refresh = ValueNotifier<int>(0);
  ref
    ..listen<AuthState>(authProvider, (_, _) => refresh.value++)
    ..onDispose(refresh.dispose);

  final router = GoRouter(
    initialLocation: RoutePaths.splash,
    refreshListenable: refresh,
    redirect: (context, state) => RouteGuard.redirect(
      authState: ref.read(authProvider),
      location: state.uri.path,
    ),
    errorBuilder: (context, state) {
      final authState = ref.read(authProvider);
      final home = authState is AuthAuthenticated
          ? RoutePaths.homeFor(authState.role)
          : RoutePaths.login;
      return NotFoundPage(homePath: home);
    },
    routes: [
      GoRoute(
        path: RoutePaths.splash,
        builder: (_, _) => const SplashPage(),
      ),
      GoRoute(
        path: RoutePaths.login,
        builder: (_, _) => const LoginPage(),
      ),
      GoRoute(
        path: RoutePaths.register,
        builder: (_, _) => const RegisterPage(),
      ),

      // Urutan screen HARUS sama dengan urutan menu di RoleNavigation.
      _roleShell(
        UserRole.pengguna,
        const [
          UserDashboardScreen(),
          PenggunaObatScreen(),
          PenggunaEdukasiScreen(),
          PenggunaKonsultasiScreen(),
          PenggunaProfileScreen(),
        ],
        subRoutes: {
          RoutePaths.penggunaObat: [
            GoRoute(
              path: ':id',
              builder: (_, state) =>
                  ObatDetailScreen(obatId: state.pathParameters['id']!),
            ),
          ],
        },
      ),
      _roleShell(
        UserRole.apoteker,
        const [
          ApotekerDashboardScreen(),
          ApotekerObatScreen(),
          StokScreen(),
          ApotekerKonsultasiScreen(),
          ApotekerProfileScreen(),
        ],
        subRoutes: {
          RoutePaths.apotekerObat: [
            // 'tambah' harus didaftarkan SEBELUM ':id'.
            GoRoute(
              path: 'tambah',
              builder: (_, _) => const ObatFormScreen(),
            ),
            GoRoute(
              path: ':id',
              builder: (_, state) =>
                  ObatFormScreen(obatId: state.pathParameters['id']),
            ),
          ],
        },
      ),
      _roleShell(
        UserRole.superadmin,
        const [
          SuperAdminDashboardScreen(),
          UsersScreen(),
          SuperadminApotekerScreen(),
          SettingsScreen(),
          SuperadminProfileScreen(),
        ],
        subRoutes: {
          RoutePaths.superadminSettings: [
            GoRoute(
              path: 'apotek',
              builder: (_, _) => const ApotekListScreen(),
              routes: [
                // 'tambah' harus didaftarkan SEBELUM ':id'.
                GoRoute(
                  path: 'tambah',
                  builder: (_, _) => const ApotekFormScreen(),
                ),
                GoRoute(
                  path: ':id',
                  builder: (_, state) =>
                      ApotekFormScreen(apotekId: state.pathParameters['id']),
                ),
              ],
            ),
          ],
        },
      ),
    ],
  );

  ref.onDispose(router.dispose);
  return router;
});

/// Membuat shell (NavigationBar + tab) untuk satu [role].
///
/// Path tiap tab diambil dari [RoleNavigation], jadi menu dan rute
/// selalu sinkron. [subRoutes] memetakan path tab ke rute anak
/// (mis. detail atau form). Akses ke shell ini dibatasi oleh [RouteGuard].
StatefulShellRoute _roleShell(
  UserRole role,
  List<Widget> screens, {
  Map<String, List<RouteBase>> subRoutes = const {},
}) {
  final items = RoleNavigation.itemsFor(role);
  assert(
    items.length == screens.length,
    'Jumlah screen untuk ${role.value} harus sama dengan jumlah menu.',
  );

  return StatefulShellRoute.indexedStack(
    builder: (context, state, navigationShell) =>
        MainNavigation(role: role, navigationShell: navigationShell),
    branches: [
      for (var i = 0; i < items.length; i++)
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: items[i].path,
              builder: (_, _) => screens[i],
              routes: subRoutes[items[i].path] ?? const <RouteBase>[],
            ),
          ],
        ),
    ],
  );
}



// import 'package:flutter/foundation.dart';
// import 'package:flutter/widgets.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:go_router/go_router.dart';

// import '../models/auth_state.dart';
// import '../models/user_role.dart';
// import '../providers/auth_provider.dart';
// import '../screens/apoteker/apoteker_dashboard_screen.dart';
// import '../screens/apoteker/konsultasi_screen.dart';
// import '../screens/apoteker/obat_screen.dart';
// import '../screens/apoteker/profile_screen.dart';
// import '../screens/apoteker/stok_screen.dart';
// import '../screens/login_page.dart';
// import '../screens/not_found_page.dart';
// import '../screens/pengguna/edukasi_screen.dart';
// import '../screens/pengguna/konsultasi_screen.dart';
// import '../screens/pengguna/obat_screen.dart';
// import '../screens/pengguna/profile_screen.dart';
// import '../screens/pengguna/user_dashboard_screen.dart';
// import '../screens/register_page.dart';
// import '../screens/splash_page.dart';
// import '../screens/superadmin/apoteker_screen.dart';
// import '../screens/superadmin/settings_screen.dart';
// import '../screens/superadmin/superadmin_dashboard_screen.dart';
// import '../screens/superadmin/users_screen.dart';
// import '../screens/superadmin/profile_screen.dart';
// import 'main_navigation.dart';
// import 'role_navigation.dart';
// import 'route_guard.dart';
// import 'route_paths.dart';

// /// Menyediakan [GoRouter] tunggal untuk aplikasi.
// final routerProvider = Provider<GoRouter>((ref) {
//   // Setiap AuthState berubah, router diminta mengevaluasi ulang redirect.
//   final refresh = ValueNotifier<int>(0);
//   ref
//     ..listen<AuthState>(authProvider, (_, _) => refresh.value++)
//     ..onDispose(refresh.dispose);

//   final router = GoRouter(
//     initialLocation: RoutePaths.splash,
//     refreshListenable: refresh,
//     redirect: (context, state) => RouteGuard.redirect(
//       authState: ref.read(authProvider),
//       location: state.uri.path,
//     ),
//     errorBuilder: (context, state) {
//       final authState = ref.read(authProvider);
//       final home = authState is AuthAuthenticated
//           ? RoutePaths.homeFor(authState.role)
//           : RoutePaths.login;
//       return NotFoundPage(homePath: home);
//     },
//     routes: [
//       GoRoute(
//         path: RoutePaths.splash,
//         builder: (_, _) => const SplashPage(),
//       ),
//       GoRoute(
//         path: RoutePaths.login,
//         builder: (_, _) => const LoginPage(),
//       ),
//       GoRoute(
//         path: RoutePaths.register,
//         builder: (_, _) => const RegisterPage(),
//       ),

//       // Urutan screen HARUS sama dengan urutan menu di RoleNavigation.
//       _roleShell(UserRole.pengguna, const [
//         UserDashboardScreen(),
//         PenggunaObatScreen(),
//         PenggunaEdukasiScreen(),
//         PenggunaKonsultasiScreen(),
//         PenggunaProfileScreen(),
//       ]),
//       _roleShell(UserRole.apoteker, const [
//         ApotekerDashboardScreen(),
//         ApotekerObatScreen(),
//         StokScreen(),
//         ApotekerKonsultasiScreen(),
//         ApotekerProfileScreen(),
//       ]),
//       _roleShell(UserRole.superadmin, const [
//         SuperAdminDashboardScreen(),
//         UsersScreen(),
//         SuperadminApotekerScreen(),
//         SettingsScreen(),
//         SuperadminProfileScreen(),
//       ]),
//     ],
//   );

//   ref.onDispose(router.dispose);
//   return router;
// });

// /// Membuat shell (NavigationBar + tab) untuk satu [role].
// ///
// /// Path tiap tab diambil dari [RoleNavigation], jadi menu dan rute
// /// selalu sinkron. Akses ke shell ini dibatasi oleh [RouteGuard].
// StatefulShellRoute _roleShell(UserRole role, List<Widget> screens) {
//   final items = RoleNavigation.itemsFor(role);
//   assert(
//     items.length == screens.length,
//     'Jumlah screen untuk ${role.value} harus sama dengan jumlah menu.',
//   );

//   return StatefulShellRoute.indexedStack(
//     builder: (context, state, navigationShell) =>
//         MainNavigation(role: role, navigationShell: navigationShell),
//     branches: [
//       for (var i = 0; i < items.length; i++)
//         StatefulShellBranch(
//           routes: [
//             GoRoute(
//               path: items[i].path,
//               builder: (_, _) => screens[i],
//             ),
//           ],
//         ),
//     ],
//   );
// }
