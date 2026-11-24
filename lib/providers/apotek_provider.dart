import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/apotek.dart';
import '../services/apotek_controller.dart';
import '../services/apotek_service.dart';
import 'current_user_provider.dart';

/// Apotek aktif saja (dipakai Pengguna di Tahap 4C).
final activeApotekStreamProvider =
    StreamProvider.autoDispose<List<Apotek>>((ref) {
  return ref.watch(apotekServiceProvider).watchApotek(activeOnly: true);
});

/// Semua apotek termasuk yang nonaktif (Superadmin dan Apoteker).
final allApotekStreamProvider = StreamProvider.autoDispose<List<Apotek>>((ref) {
  return ref.watch(apotekServiceProvider).watchApotek(activeOnly: false);
});

final apotekByIdProvider =
    StreamProvider.autoDispose.family<Apotek?, String>((ref, id) {
  return ref.watch(apotekServiceProvider).watchById(id);
});

/// Apotek tempat user yang sedang login bertugas (`null` jika belum
/// ditugaskan). Dipakai Apoteker.
final myApotekProvider = Provider.autoDispose<AsyncValue<Apotek?>>((ref) {
  final apotekId = ref.watch(currentUserProvider.select((u) => u?.apotekId));
  if (apotekId == null) return const AsyncData<Apotek?>(null);
  return ref.watch(apotekByIdProvider(apotekId));
});

final apotekControllerProvider = Provider<ApotekController>((ref) {
  return ApotekController(
    apotekService: ref.watch(apotekServiceProvider),
    currentUser: () => ref.read(currentUserProvider),
  );
});