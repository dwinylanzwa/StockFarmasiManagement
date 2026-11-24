/// Bentuk sediaan obat. Nilai [value] disimpan di Firestore.
enum BentukSediaan {
  tablet('tablet', 'Tablet'),
  kapsul('kapsul', 'Kapsul'),
  sirup('sirup', 'Sirup'),
  salep('salep', 'Salep'),
  tetes('tetes', 'Tetes'),
  injeksi('injeksi', 'Injeksi'),
  lainnya('lainnya', 'Lainnya');

  const BentukSediaan(this.value, this.label);

  final String value;
  final String label;

  /// Melempar [FormatException] jika [value] tidak dikenal (*fail closed*).
  static BentukSediaan fromValue(String value) {
    for (final bentuk in BentukSediaan.values) {
      if (bentuk.value == value) return bentuk;
    }
    throw FormatException('Bentuk sediaan tidak dikenal: "$value"');
  }
}