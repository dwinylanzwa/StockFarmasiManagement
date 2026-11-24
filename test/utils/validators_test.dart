import 'package:flutter_test/flutter_test.dart';
import 'package:halobat/utils/validators.dart';

void main() {
  group('Validators.email', () {
    test('menolak kosong dan format salah', () {
      expect(Validators.email(''), isNotNull);
      expect(Validators.email('abc'), isNotNull);
      expect(Validators.email('abc@'), isNotNull);
      expect(Validators.email('abc@domain'), isNotNull);
    });

    test('menerima email valid', () {
      expect(Validators.email('pengguna@halobat.com'), isNull);
      expect(Validators.email(' nama.baru+tag@mail.co.id '), isNull);
    });
  });

  group('Validators.newPassword', () {
    test('menolak yang terlalu pendek, tanpa huruf, atau tanpa angka', () {
      expect(Validators.newPassword('Ab1'), isNotNull);
      expect(Validators.newPassword('12345678'), isNotNull);
      expect(Validators.newPassword('abcdefgh'), isNotNull);
    });

    test('menerima kombinasi huruf dan angka minimal 8 karakter', () {
      expect(Validators.newPassword('Obat1234'), isNull);
    });
  });

  group('Validators.confirmPassword', () {
    test('cocok dan tidak cocok', () {
      final validator = Validators.confirmPassword(() => 'Obat1234');
      expect(validator('Obat1234'), isNull);
      expect(validator('Obat12345'), isNotNull);
      expect(validator(''), isNotNull);
    });
  });

  group('Validators.nama', () {
    test('validasi panjang', () {
      expect(Validators.nama(' '), isNotNull);
      expect(Validators.nama('A'), isNotNull);
      expect(Validators.nama('Budi'), isNull);
    });
  });
}