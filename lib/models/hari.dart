/// Hari dalam seminggu. [isoValue] mengikuti ISO-8601 (1 = Senin … 7 = Minggu)
/// dan itulah yang disimpan di Firestore. Jangan diubah setelah rilis.
enum Hari {
  senin(1, 'Senin'),
  selasa(2, 'Selasa'),
  rabu(3, 'Rabu'),
  kamis(4, 'Kamis'),
  jumat(5, 'Jumat'),
  sabtu(6, 'Sabtu'),
  minggu(7, 'Minggu');

  const Hari(this.isoValue, this.label);

  final int isoValue;
  final String label;

  /// Melempar [FormatException] jika [value] di luar 1..7 (*fail closed*).
  static Hari fromIso(int value) {
    for (final hari in Hari.values) {
      if (hari.isoValue == value) return hari;
    }
    throw FormatException('Nilai hari tidak valid: $value');
  }
}