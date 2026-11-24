import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/obat.dart';
import '../models/obat_draft.dart';

/// Akses data katalog obat di Firestore. UI tidak boleh memakai Firestore
/// langsung.
class ObatService {
  ObatService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _obat =>
      _firestore.collection('obat');

  /// Memantau daftar obat secara realtime, urut nama.
  ///
  /// [activeOnly] `true` untuk Pengguna: query WAJIB memfilter `isActive`
  /// agar sesuai dengan Security Rules. Dokumen dengan data rusak dilewati
  /// agar satu dokumen buruk tidak merusak seluruh daftar.
  Stream<List<Obat>> watchObat({required bool activeOnly}) {
    final Query<Map<String, dynamic>> query =
        activeOnly ? _obat.where('isActive', isEqualTo: true) : _obat;

    return query.snapshots().map((snapshot) {
      final list = <Obat>[];
      for (final doc in snapshot.docs) {
        try {
          list.add(Obat.fromFirestore(doc));
        } on FormatException catch (e) {
          debugPrint('[ObatService] Dokumen obat dilewati (${doc.id}): $e');
        }
      }
      list.sort((a, b) => a.nama.toLowerCase().compareTo(b.nama.toLowerCase()));
      return list;
    });
  }

  /// Memantau satu obat; `null` jika tidak ada.
  Stream<Obat?> watchById(String id) {
    return _obat.doc(id).snapshots().map(
          (doc) => doc.exists ? Obat.fromFirestore(doc) : null,
        );
  }

  /// Membuat obat baru (selalu aktif) dan mengembalikan id-nya.
  Future<String> create(ObatDraft draft, {required String createdByUid}) async {
    final ref = _obat.doc();
    await ref.set({
      ...draft.toMap(),
      'isActive': true,
      'createdBy': createdByUid,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    return ref.id;
  }

  Future<void> update(String id, ObatDraft draft) {
    return _obat.doc(id).update({
      ...draft.toMap(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> setActive(String id, {required bool isActive}) {
    return _obat.doc(id).update({
      'isActive': isActive,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}

final obatServiceProvider = Provider<ObatService>((ref) => ObatService());