/// Peran (role) pengguna di dalam sistem HalObat.
///
/// **Menambah role ke-4:** tambahkan satu entri enum, misalnya
/// `kasir('kasir', 'Kasir')`, lalu tambahkan nilainya di `validRole()`
/// pada `firestore.rules`. Setiap `switch` exhaustive atas enum ini akan
/// memunculkan error kompilasi di tempat yang belum menangani role baru.
enum UserRole {
  pengguna('pengguna', 'Pengguna', canSelfRegister: true),
  apoteker('apoteker', 'Apoteker'),
  superadmin('superadmin', 'Superadmin');

  const UserRole(this.value, this.label, {this.canSelfRegister = false});

  /// Nilai yang disimpan di Firestore. Jangan diubah setelah rilis.
  final String value;

  /// Nama yang ditampilkan di UI.
  final String label;

  /// Apakah role ini boleh didapat lewat pendaftaran mandiri.
  final bool canSelfRegister;

  /// Melempar [FormatException] jika [value] tidak dikenal (*fail closed*).
  static UserRole fromValue(String value) {
    for (final role in UserRole.values) {
      if (role.value == value) return role;
    }
    throw FormatException('Role tidak dikenal: "$value"');
  }

  /// Versi aman; `null` jika tidak dikenal.
  static UserRole? tryParse(String? value) {
    if (value == null) return null;
    for (final role in UserRole.values) {
      if (role.value == value) return role;
    }
    return null;
  }
}