import '../models/obat.dart';
import '../models/obat_golongan.dart';

/// Penyaringan daftar obat di sisi klien.
abstract final class ObatFilter {
  /// Menyaring [list] berdasarkan [query] (nama atau nama generik, tidak
  /// peka huruf besar/kecil) dan [golongan] (`null` = semua).
  static List<Obat> apply(
    List<Obat> list, {
    String query = '',
    ObatGolongan? golongan,
  }) {
    final q = query.trim().toLowerCase();
    return list.where((obat) {
      final matchesGolongan = golongan == null || obat.golongan == golongan;
      final matchesQuery = q.isEmpty ||
          obat.nama.toLowerCase().contains(q) ||
          obat.namaGenerik.toLowerCase().contains(q);
      return matchesGolongan && matchesQuery;
    }).toList();
  }
}