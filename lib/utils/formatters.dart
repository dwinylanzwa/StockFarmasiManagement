/// Format tampilan bersama.
abstract final class Formatters {
  /// Contoh: `05/03/2026`.
  static String date(DateTime value) {
    final d = value.day.toString().padLeft(2, '0');
    final m = value.month.toString().padLeft(2, '0');
    return '$d/$m/${value.year}';
  }
}