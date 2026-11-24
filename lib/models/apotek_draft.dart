import 'package:cloud_firestore/cloud_firestore.dart';

import 'jadwal_operasional.dart';

/// Batas panjang field apotek. Harus sama dengan `firestore.rules`.
abstract final class ApotekLimits {
  static const int nama = 100;
  static const int alamat = 300;
  static const int telepon = 30;
}

/// Input form apotek (tanpa id, status, dan timestamp).
class ApotekDraft {
  const ApotekDraft({
    required this.nama,
    required this.alamat,
    required this.latitude,
    required this.longitude,
    required this.jadwal,
    this.telepon = '',
  });

  final String nama;
  final String alamat;
  final double latitude;
  final double longitude;
  final JadwalOperasional jadwal;
  final String telepon;

  /// Map siap tulis ke Firestore. Semua field selalu ada agar Security
  /// Rules bisa memvalidasi bentuk data.
  Map<String, Object?> toMap() {
    return {
      'nama': nama.trim(),
      'alamat': alamat.trim(),
      'telepon': telepon.trim(),
      'lokasi': GeoPoint(latitude, longitude),
      ...jadwal.toMap(),
    };
  }
}