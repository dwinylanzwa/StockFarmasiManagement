import 'package:firebase_core/firebase_core.dart' show FirebaseException;

/// Error pada aksi administrasi. [message] aman ditampilkan ke pengguna.
final class AdminActionException implements Exception {
  const AdminActionException(this.message);

  /// Mengubah error apa pun menjadi [AdminActionException].
  factory AdminActionException.from(Object error) {
    if (error is AdminActionException) return error;
    if (error is FirebaseException) {
      return switch (error.code) {
        'permission-denied' => const AdminActionException(
            'Anda tidak memiliki izin untuk tindakan ini.',
          ),
        'unavailable' => const AdminActionException(
            'Tidak ada koneksi. Periksa jaringan lalu coba lagi.',
          ),
        'not-found' => const AdminActionException(
            'Data tidak ditemukan. Mungkin sudah dihapus.',
          ),
        _ => const AdminActionException(
            'Terjadi kesalahan. Silakan coba lagi.',
          ),
      };
    }
    return const AdminActionException('Terjadi kesalahan. Silakan coba lagi.');
  }

  final String message;

  @override
  String toString() => 'AdminActionException: $message';
}