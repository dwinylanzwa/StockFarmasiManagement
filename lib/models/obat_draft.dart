import 'bentuk_sediaan.dart';
import 'obat_golongan.dart';

/// Batas panjang field obat. Harus sama dengan `firestore.rules`.
abstract final class ObatLimits {
  static const int nama = 100;
  static const int namaGenerik = 100;
  static const int kekuatan = 50;
  static const int produsen = 100;
  static const int deskripsi = 2000;
  static const int indikasi = 1000;
  static const int peringatan = 1000;
}

/// Input form obat (tanpa id, status, dan timestamp).
class ObatDraft {
  const ObatDraft({
    required this.nama,
    required this.golongan,
    required this.bentuk,
    this.namaGenerik = '',
    this.kekuatan = '',
    this.produsen = '',
    this.deskripsi = '',
    this.indikasi = '',
    this.peringatan = '',
  });

  final String nama;
  final String namaGenerik;
  final ObatGolongan golongan;
  final BentukSediaan bentuk;
  final String kekuatan;
  final String produsen;
  final String deskripsi;
  final String indikasi;
  final String peringatan;

  /// Map siap tulis ke Firestore. Semua field selalu ada (string kosong
  /// jika tidak diisi) agar Security Rules bisa memvalidasi bentuk data.
  Map<String, Object?> toMap() {
    return {
      'nama': nama.trim(),
      'namaGenerik': namaGenerik.trim(),
      'golongan': golongan.value,
      'bentuk': bentuk.value,
      'kekuatan': kekuatan.trim(),
      'produsen': produsen.trim(),
      'deskripsi': deskripsi.trim(),
      'indikasi': indikasi.trim(),
      'peringatan': peringatan.trim(),
    };
  }
}