/// Kumpulan validator untuk `TextFormField`.
///
/// Setiap fungsi mengembalikan `null` jika valid, atau pesan error
/// berbahasa Indonesia jika tidak valid.
/// 
import '../models/apotek_draft.dart';
import '../models/obat_draft.dart'; 
abstract final class Validators {
  static final RegExp _emailRegex =
      RegExp(r'^[\w.+\-]+@([\w\-]+\.)+[A-Za-z]{2,}$');

  static String? nama(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Nama wajib diisi.';
    if (text.length < 2) return 'Nama minimal 2 karakter.';
    if (text.length > 50) return 'Nama maksimal 50 karakter.';
    return null;
  }
  static String? namaObat(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Nama obat wajib diisi.';
    if (text.length < 2) return 'Nama obat minimal 2 karakter.';
    if (text.length > ObatLimits.nama) {
      return 'Nama obat maksimal ${ObatLimits.nama} karakter.';
    }
    return null;
  }
    static String? namaApotek(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Nama apotek wajib diisi.';
    if (text.length < 2) return 'Nama apotek minimal 2 karakter.';
    if (text.length > ApotekLimits.nama) {
      return 'Nama apotek maksimal ${ApotekLimits.nama} karakter.';
    }
    return null;
  }

  static String? alamatApotek(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Alamat wajib diisi.';
    if (text.length < 5) return 'Alamat minimal 5 karakter.';
    if (text.length > ApotekLimits.alamat) {
      return 'Alamat maksimal ${ApotekLimits.alamat} karakter.';
    }
    return null;
  }

  /// Validator untuk field opsional yang hanya dibatasi panjangnya.
  static String? Function(String?) optionalMaxLength(int max, String label) {
    return (value) {
      if ((value?.trim().length ?? 0) > max) {
        return '$label maksimal $max karakter.';
      }
      return null;
    };
  }
  static String? email(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Email wajib diisi.';
    if (!_emailRegex.hasMatch(text)) return 'Format email tidak valid.';
    return null;
  }

  /// Untuk halaman login: hanya memastikan tidak kosong, agar akun lama
  /// dengan aturan password berbeda tetap bisa masuk.
  static String? loginPassword(String? value) {
    if (value == null || value.isEmpty) return 'Password wajib diisi.';
    return null;
  }

  /// Untuk password baru (register): min. 8 karakter, ada huruf dan angka.
  static String? newPassword(String? value) {
    if (value == null || value.isEmpty) return 'Password wajib diisi.';
    if (value.length < 8) return 'Password minimal 8 karakter.';
    if (!RegExp('[A-Za-z]').hasMatch(value)) {
      return 'Password harus mengandung huruf.';
    }
    if (!RegExp('[0-9]').hasMatch(value)) {
      return 'Password harus mengandung angka.';
    }
    return null;
  }

  /// Membuat validator konfirmasi password. [original] dipanggil saat
  /// validasi agar selalu membandingkan dengan isi terbaru.
  static String? Function(String?) confirmPassword(String Function() original) {
    return (value) {
      if (value == null || value.isEmpty) {
        return 'Konfirmasi password wajib diisi.';
      }
      if (value != original()) return 'Konfirmasi password tidak sama.';
      return null;
    };
  }
}