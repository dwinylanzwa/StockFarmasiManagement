import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/apotek.dart';
import '../models/apotek_draft.dart';

/// Akses data apotek di Firestore. UI tidak boleh memakai Firestore
/// langsung.
class ApotekService {
  ApotekService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _apotek =>
      _firestore.collection('apotek');

  /// Memantau daftar apotek secara realtime, urut nama.
  ///
  /// [activeOnly] `true` untuk Pengguna: query WAJIB memfilter `isActive`
  /// agar sesuai Security Rules. Dokumen rusak dilewati.
  Stream<List<Apotek>> watchApotek({required bool activeOnly}) {
    final Query<Map<String, dynamic>> query =
        activeOnly ? _apotek.where('isActive', isEqualTo: true) : _apotek;

    return query.snapshots().map((snapshot) {
      final list = <Apotek>[];
      for (final doc in snapshot.docs) {
        try {
          list.add(Apotek.fromFirestore(doc));
        } on FormatException catch (e) {
          debugPrint('[ApotekService] Dokumen apotek dilewati (${doc.id}): $e');
        }
      }
      list.sort((a, b) => a.nama.toLowerCase().compareTo(b.nama.toLowerCase()));
      return list;
    });
  }

  /// Memantau satu apotek; `null` jika tidak ada.
  Stream<Apotek?> watchById(String id) {
    return _apotek.doc(id).snapshots().map(
          (doc) => doc.exists ? Apotek.fromFirestore(doc) : null,
        );
  }

  /// Membuat apotek baru (selalu aktif) dan mengembalikan id-nya.
  Future<String> create(
    ApotekDraft draft, {
    required String createdByUid,
  }) async {
    final ref = _apotek.doc();
    await ref.set({
      ...draft.toMap(),
      'isActive': true,
      'createdBy': createdByUid,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    return ref.id;
  }

  Future<void> update(String id, ApotekDraft draft) {
    return _apotek.doc(id).update({
      ...draft.toMap(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> setActive(String id, {required bool isActive}) {
    return _apotek.doc(id).update({
      'isActive': isActive,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}

final apotekServiceProvider = Provider<ApotekService>((ref) {
  return ApotekService();
});