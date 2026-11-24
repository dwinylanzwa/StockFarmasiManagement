import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'jadwal_operasional.dart';

/// Data apotek (Firestore: koleksi `apotek`).
class Apotek extends Equatable {
  const Apotek({
    required this.id,
    required this.nama,
    required this.alamat,
    required this.telepon,
    required this.latitude,
    required this.longitude,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    required this.jadwal,
  });

  /// Membaca dokumen Firestore. Melempar [FormatException] jika lokasi
  /// tidak ada atau bukan `GeoPoint`.
  factory Apotek.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    if (data == null) {
      throw FormatException('Dokumen apotek ${doc.id} kosong');
    }
    final lokasi = data['lokasi'];
    if (lokasi is! GeoPoint) {
      throw FormatException('Apotek ${doc.id} tidak memiliki lokasi valid');
    }

    String text(String key) => data[key] as String? ?? '';

    final createdAt =
        (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now();

    return Apotek(
      id: doc.id,
      nama: text('nama'),
      alamat: text('alamat'),
      telepon: text('telepon'),
      jadwal: JadwalOperasional.fromMap(data),
      latitude: lokasi.latitude,
      longitude: lokasi.longitude,
      isActive: data['isActive'] as bool? ?? false,
      createdAt: createdAt,
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? createdAt,
    );
  }

  final String id;
  final String nama;
  final String alamat;
  final String telepon;
  final JadwalOperasional jadwal;
  final double latitude;
  final double longitude;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  @override
  List<Object?> get props => [
        id,
        nama,
        alamat,
        telepon,
        jadwal,
        latitude,
        longitude,
        isActive,
        createdAt,
        updatedAt,
      ];
}