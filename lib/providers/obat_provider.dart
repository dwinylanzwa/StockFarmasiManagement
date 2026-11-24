import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/obat.dart';
import '../services/obat_controller.dart';
import '../services/obat_service.dart';
import 'current_user_provider.dart';

/// Obat aktif saja (untuk Pengguna).
final activeObatStreamProvider = StreamProvider.autoDispose<List<Obat>>((ref) {
  return ref.watch(obatServiceProvider).watchObat(activeOnly: true);
});

/// Semua obat termasuk yang nonaktif (untuk Apoteker).
final allObatStreamProvider = StreamProvider.autoDispose<List<Obat>>((ref) {
  return ref.watch(obatServiceProvider).watchObat(activeOnly: false);
});

/// Satu obat berdasarkan id (realtime).
final obatByIdProvider =
    StreamProvider.autoDispose.family<Obat?, String>((ref, id) {
  return ref.watch(obatServiceProvider).watchById(id);
});

final obatControllerProvider = Provider<ObatController>((ref) {
  return ObatController(
    obatService: ref.watch(obatServiceProvider),
    currentUser: () => ref.read(currentUserProvider),
  );
});