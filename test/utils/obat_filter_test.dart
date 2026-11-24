import 'package:flutter_test/flutter_test.dart';
import 'package:halobat/models/bentuk_sediaan.dart';
import 'package:halobat/models/obat.dart';
import 'package:halobat/models/obat_golongan.dart';
import 'package:halobat/utils/obat_filter.dart';

Obat _obat(
  String nama, {
  String generik = '',
  ObatGolongan golongan = ObatGolongan.bebas,
}) {
  return Obat(
    id: nama,
    nama: nama,
    namaGenerik: generik,
    golongan: golongan,
    bentuk: BentukSediaan.tablet,
    kekuatan: '',
    produsen: '',
    deskripsi: '',
    indikasi: '',
    peringatan: '',
    isActive: true,
    createdAt: DateTime(2024),
    updatedAt: DateTime(2024),
  );
}

void main() {
  final list = [
    _obat('Panadol', generik: 'Paracetamol'),
    _obat('Amoxsan', generik: 'Amoxicillin', golongan: ObatGolongan.keras),
    _obat('Vitamin C'),
  ];

  test('tanpa filter mengembalikan semua', () {
    expect(ObatFilter.apply(list), hasLength(3));
  });

  test('pencarian tidak peka huruf besar/kecil dan mencakup nama generik', () {
    expect(ObatFilter.apply(list, query: 'PANA').single.nama, 'Panadol');
    expect(ObatFilter.apply(list, query: 'paracet').single.nama, 'Panadol');
    expect(ObatFilter.apply(list, query: '  amox ').single.nama, 'Amoxsan');
  });

  test('filter golongan', () {
    final result = ObatFilter.apply(list, golongan: ObatGolongan.keras);
    expect(result.single.nama, 'Amoxsan');
  });

  test('pencarian dan golongan digabung', () {
    expect(
      ObatFilter.apply(list, query: 'pana', golongan: ObatGolongan.keras),
      isEmpty,
    );
  });
}