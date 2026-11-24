import '../models/user_role.dart';

/// Semua path rute aplikasi di satu tempat (tanpa magic string).
abstract final class RoutePaths {
  // Umum
  static const String splash = '/splash';
  static const String login = '/login';
  static const String register = '/register';

  // Pengguna
  static const String pengguna = '/pengguna';
  static const String penggunaObat = '/pengguna/obat';
  static const String penggunaEdukasi = '/pengguna/edukasi';
  static const String penggunaKonsultasi = '/pengguna/konsultasi';
  static const String penggunaProfile = '/pengguna/profile';

  // Apoteker
  static const String apoteker = '/apoteker';
  static const String apotekerObat = '/apoteker/obat';
  static const String apotekerStok = '/apoteker/stok';
  static const String apotekerKonsultasi = '/apoteker/konsultasi';
  static const String apotekerProfile = '/apoteker/profile';

  // Superadmin
  static const String superadmin = '/superadmin';
  static const String superadminUsers = '/superadmin/users';
  static const String superadminApoteker = '/superadmin/apoteker';
  static const String superadminSettings = '/superadmin/settings';
  static const String superadminProfile = '/superadmin/profile';

  // Kelola apotek (Superadmin)
  static const String superadminApotek = '/superadmin/settings/apotek';
  static const String superadminApotekTambah =
      '/superadmin/settings/apotek/tambah';
  static String superadminApotekDetail(String id) => '$superadminApotek/$id';

  /// Path induk (area) milik sebuah [role].
  ///
  /// `switch` ini exhaustive: menambah role baru di [UserRole] akan
  /// menimbulkan error kompilasi di sini sampai base path-nya didaftarkan.
  static String basePath(UserRole role) => switch (role) {
        UserRole.pengguna => pengguna,
        UserRole.apoteker => apoteker,
        UserRole.superadmin => superadmin,
      };

  /// Halaman utama (dashboard) untuk [role].
  static String homeFor(UserRole role) => basePath(role);

  /// Halaman yang hanya masuk akal untuk user yang BELUM login.
  static bool isPublic(String location) =>
      location == login || location == register;

  /// Halaman yang tidak boleh dibuka lagi oleh user yang SUDAH login.
  static bool isEntryPoint(String location) =>
      location == '/' || location == splash || isPublic(location);

  /// Mengembalikan role pemilik area dari [location], atau `null` jika
  /// bukan area role mana pun.
  static UserRole? ownerOf(String location) {
    for (final role in UserRole.values) {
      final base = basePath(role);
      if (location == base || location.startsWith('$base/')) return role;
    }
    return null;
  }
    // Detail obat (Pengguna) dan form obat (Apoteker)
  static String penggunaObatDetail(String id) => '$penggunaObat/$id';
  static const String apotekerObatTambah = '/apoteker/obat/tambah';
  static String apotekerObatDetail(String id) => '$apotekerObat/$id';
}