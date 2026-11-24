import 'package:flutter_test/flutter_test.dart';
import 'package:halobat/models/hari.dart';
import 'package:halobat/models/jadwal_operasional.dart';

void main() {
  group('validate', () {
    test('jadwal standar valid', () {
      expect(JadwalOperasional.standar.validate(), isNull);
    });

    test('tanpa hari ditolak', () {
      expect(const JadwalOperasional(hari: {}).validate(), isNotNull);
    });

    test('jam tutup harus setelah jam buka', () {
      const sama = JadwalOperasional(
        hari: {Hari.senin},
        bukaMenit: 600,
        tutupMenit: 600,
      );
      const terbalik = JadwalOperasional(
        hari: {Hari.senin},
        bukaMenit: 900,
        tutupMenit: 600,
      );
      expect(sama.validate(), isNotNull);
      expect(terbalik.validate(), isNotNull);
    });

    test('24 jam mengabaikan jam buka dan tutup', () {
      const jadwal = JadwalOperasional(
        hari: {Hari.senin},
        buka24Jam: true,
        bukaMenit: 900,
        tutupMenit: 600,
      );
      expect(jadwal.validate(), isNull);
      expect(jadwal.toMap()['jamBuka'], 0);
      expect(jadwal.toMap()['jamTutup'], 0);
    });
  });

  group('ringkas', () {
    test('hari berurutan diringkas', () {
      expect(JadwalOperasional.standar.ringkas, 'Senin–Sabtu, 08.00–21.00');
    });

    test('hari tidak berurutan dan setiap hari', () {
      const sebagian = JadwalOperasional(hari: {Hari.senin, Hari.rabu});
      expect(sebagian.ringkasHari, 'Senin, Rabu');
      expect(JadwalOperasional(hari: {...Hari.values}).ringkasHari, 'Setiap hari');
    });
  });

  test('toMap dan fromMap saling kembali', () {
    final map = JadwalOperasional.standar.toMap();
    expect(map['hariBuka'], [1, 2, 3, 4, 5, 6]);
    expect(JadwalOperasional.fromMap(map), JadwalOperasional.standar);
  });

  test('fromMap menolak data rusak', () {
    expect(
      () => JadwalOperasional.fromMap({'hariBuka': [9]}),
      throwsFormatException,
    );
    expect(() => JadwalOperasional.fromMap({}), throwsFormatException);
  });
}