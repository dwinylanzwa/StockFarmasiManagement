import '../models/auth_state.dart';
import 'route_paths.dart';

/// Aturan redirect untuk autentikasi dan RBAC.
///
/// Mengembalikan path tujuan jika user harus dialihkan, atau `null` jika
/// boleh tetap di [location]. Fungsi murni, jadi mudah diuji.
///
/// PENTING: ini mengatur navigasi di klien. Data sebenarnya dilindungi
/// oleh Firestore Security Rules di server.
abstract final class RouteGuard {
  static String? redirect({
    required AuthState authState,
    required String location,
  }) {
    switch (authState) {
      // Session sedang diperiksa: tahan di splash.
      case AuthInitial() || AuthLoading():
        return location == RoutePaths.splash ? null : RoutePaths.splash;

      // Belum login: hanya Login dan Register yang boleh dibuka.
      case AuthUnauthenticated():
        return RoutePaths.isPublic(location) ? null : RoutePaths.login;

      case AuthAuthenticated(:final role):
        final home = RoutePaths.homeFor(role);

        // Sudah login: jangan kembali ke splash/login/register.
        if (RoutePaths.isEntryPoint(location)) return home;

        // Area milik role lain: alihkan ke dashboard role sendiri.
        final owner = RoutePaths.ownerOf(location);
        if (owner != null && owner != role) return home;

        return null;
    }
  }
}