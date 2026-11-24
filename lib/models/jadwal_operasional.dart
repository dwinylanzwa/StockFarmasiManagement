import 'package:equatable/equatable.dart';

import 'hari.dart';

/// Jadwal operasional apotek: hari buka dan jam buka/tutup.
///
/// Jam disimpan sebagai menit sejak 00.00 (0..1439). Jam tutup harus
/// setelah jam buka (apotek yang buka melewati tengah malam memakai
/// [buka24Jam]).
class JadwalOperasional extends Equatable {
  const JadwalOperasional({
    required this.hari,
    this.buka24Jam = false,
    this.bukaMenit = 480,
    this.tutupMenit = 1260,
  });

  /// Membaca field jadwal dari data dokumen apotek. Melempar
  /// [FormatException] jika `hariBuka` rusak.
  factory JadwalOperasional.fromMap(Map<String, dynamic> data) {
    final raw = data['hariBuka'];
    if (raw is! List<dynamic>) {
      throw const FormatException('hariBuka tidak valid');
    }
    final hari = <Hari>{};
    for (final value in raw) {
      if (value is! int) {
        throw const FormatException('hariBuka harus berisi angka');
      }
      hari.add(Hari.fromIso(value));
    }
    return JadwalOperasional(
      hari: hari,
      buka24Jam: data['buka24Jam'] as bool? ?? false,
      bukaMenit: data['jamBuka'] as int? ?? 0,
      tutupMenit: data['jamTutup'] as int? ?? 0,
    );
  }

  /// Nilai awal untuk apotek baru: Senin–Sabtu, 08.00–21.00.
  static const JadwalOperasional standar = JadwalOperasional(
    hari: {
      Hari.senin,
      Hari.selasa,
      Hari.rabu,
      Hari.kamis,
      Hari.jumat,
      Hari.sabtu,
    },
  );

  static const int menitPerHari = 1440;

  final Set<Hari> hari;
  final bool buka24Jam;
  final int bukaMenit;
  final int tutupMenit;

  /// Hari buka, berurutan Senin sampai Minggu.
  List<Hari> get hariTerurut => Hari.values.where(hari.contains).toList();

  /// `null` jika valid, atau pesan error berbahasa Indonesia.
  String? validate() {
    if (hari.isEmpty) return 'Pilih minimal satu hari buka.';
    if (buka24Jam) return null;

    final inRange = bukaMenit >= 0 &&
        bukaMenit < menitPerHari &&
        tutupMenit >= 0 &&
        tutupMenit < menitPerHari;
    if (!inRange) return 'Jam operasional tidak valid.';
    if (tutupMenit <= bukaMenit) return 'Jam tutup harus setelah jam buka.';
    return null;
  }

  /// Field siap tulis ke dokumen apotek. Saat 24 jam, jam diisi 0.
  Map<String, Object?> toMap() {
    return {
      'hariBuka': hariTerurut.map((h) => h.isoValue).toList(),
      'buka24Jam': buka24Jam,
      'jamBuka': buka24Jam ? 0 : bukaMenit,
      'jamTutup': buka24Jam ? 0 : tutupMenit,
    };
  }

  /// Contoh: `08.00`.
  static String formatMenit(int menit) {
    final jam = (menit ~/ 60).toString().padLeft(2, '0');
    final mnt = (menit % 60).toString().padLeft(2, '0');
    return '$jam.$mnt';
  }

  /// Contoh: `Senin–Sabtu`, `Senin, Rabu`, atau `Setiap hari`.
  String get ringkasHari {
    final days = hariTerurut.map((h) => h.isoValue).toList();
    if (days.length == Hari.values.length) return 'Setiap hari';

    final parts = <String>[];
    var i = 0;
    while (i < days.length) {
      var j = i;
      while (j + 1 < days.length && days[j + 1] == days[j] + 1) {
        j++;
      }
      if (j - i >= 2) {
        parts.add('${Hari.fromIso(days[i]).label}–${Hari.fromIso(days[j]).label}');
      } else {
        for (var k = i; k <= j; k++) {
          parts.add(Hari.fromIso(days[k]).label);
        }
      }
      i = j + 1;
    }
    return parts.join(', ');
  }

  /// Contoh: `08.00–21.00` atau `24 jam`.
  String get ringkasJam => buka24Jam
      ? '24 jam'
      : '${formatMenit(bukaMenit)}–${formatMenit(tutupMenit)}';

  /// Contoh: `Senin–Sabtu, 08.00–21.00`.
  String get ringkas => '$ringkasHari, $ringkasJam';

  @override
  List<Object?> get props => [hariTerurut, buka24Jam, bukaMenit, tutupMenit];
}