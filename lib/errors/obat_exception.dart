import 'admin_exception.dart';

/// Error pada aksi katalog obat. [message] aman ditampilkan ke pengguna.
final class ObatActionException implements Exception {
  const ObatActionException(this.message);

  /// Mengubah error apa pun menjadi [ObatActionException]. Pemetaan error
  /// Firestore memakai ulang [AdminActionException] agar tidak duplikat.
  factory ObatActionException.from(Object error) {
    if (error is ObatActionException) return error;
    return ObatActionException(AdminActionException.from(error).message);
  }

  final String message;

  @override
  String toString() => 'ObatActionException: $message';
}