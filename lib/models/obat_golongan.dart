/// Golongan obat menurut klasifikasi yang berlaku di Indonesia.
///
/// Nilai [value] disimpan di Firestore. Jangan diubah setelah rilis.
enum ObatGolongan {
  bebas('bebas', 'Obat Bebas'),
  bebasTerbatas(
    'bebas_terbatas',
    'Obat Bebas Terbatas',
    warning: 'Perhatikan tanda peringatan pada kemasan dan baca aturan pakai '
        'sebelum menggunakan.',
  ),
  keras(
    'keras',
    'Obat Keras',
    requiresPrescription: true,
    warning: 'Obat ini hanya boleh diperoleh dengan resep dokter.',
  ),
  narkotika(
    'narkotika',
    'Narkotika',
    requiresPrescription: true,
    isControlled: true,
    warning: 'Obat ini diawasi ketat dan hanya boleh diperoleh dengan resep '
        'dokter. Penggunaan tanpa resep berbahaya dan melanggar hukum.',
  ),
  psikotropika(
    'psikotropika',
    'Psikotropika',
    requiresPrescription: true,
    isControlled: true,
    warning: 'Obat ini diawasi ketat dan hanya boleh diperoleh dengan resep '
        'dokter. Penggunaan tanpa resep berbahaya dan melanggar hukum.',
  );

  const ObatGolongan(
    this.value,
    this.label, {
    this.requiresPrescription = false,
    this.isControlled = false,
    this.warning,
  });

  final String value;
  final String label;

  /// Wajib resep dokter.
  final bool requiresPrescription;

  /// Diawasi ketat (narkotika dan psikotropika).
  final bool isControlled;

  /// Pesan peringatan untuk pengguna; `null` jika tidak ada.
  final String? warning;

  /// Melempar [FormatException] jika [value] tidak dikenal (*fail closed*).
  static ObatGolongan fromValue(String value) {
    for (final golongan in ObatGolongan.values) {
      if (golongan.value == value) return golongan;
    }
    throw FormatException('Golongan obat tidak dikenal: "$value"');
  }
}