import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

import 'bentuk_sediaan.dart';
import 'obat_golongan.dart';

/// Data obat di katalog (Firestore: koleksi `obat`).
class Obat extends Equatable {
  const Obat({
    required this.id,
    required this.nama,
    required this.namaGenerik,
    required this.golongan,
    required this.bentuk,
    required this.kekuatan,
    required this.produsen,
    required this.deskripsi,
    required this.indikasi,
    required this.peringatan,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Membaca dokumen Firestore. Melempar [FormatException] jika golongan
  /// atau bentuk sediaan tidak valid.
  factory Obat.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    if (data == null) {
      throw FormatException('Dokumen obat ${doc.id} kosong');
    }

    String text(String key) => data[key] as String? ?? '';

    // Timestamp bernilai null sesaat setelah ditulis (server timestamp
    // belum terisi), maka diberi fallback.
    final createdAt =
        (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now();

    return Obat(
      id: doc.id,
      nama: text('nama'),
      namaGenerik: text('namaGenerik'),
      golongan: ObatGolongan.fromValue(text('golongan')),
      bentuk: BentukSediaan.fromValue(text('bentuk')),
      kekuatan: text('kekuatan'),
      produsen: text('produsen'),
      deskripsi: text('deskripsi'),
      indikasi: text('indikasi'),
      peringatan: text('peringatan'),
      isActive: data['isActive'] as bool? ?? false,
      createdAt: createdAt,
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? createdAt,
    );
  }

  final String id;
  final String nama;
  final String namaGenerik;
  final ObatGolongan golongan;
  final BentukSediaan bentuk;

  /// Contoh: "500 mg".
  final String kekuatan;
  final String produsen;
  final String deskripsi;
  final String indikasi;
  final String peringatan;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// Nama beserta kekuatan, contoh: "Paracetamol 500 mg".
  String get displayName => kekuatan.isEmpty ? nama : '$nama $kekuatan';

  @override
  List<Object?> get props => [
        id,
        nama,
        namaGenerik,
        golongan,
        bentuk,
        kekuatan,
        produsen,
        deskripsi,
        indikasi,
        peringatan,
        isActive,
        createdAt,
        updatedAt,
      ];
}