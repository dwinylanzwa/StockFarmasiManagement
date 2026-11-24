import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' show User;
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/app_user.dart';
import '../models/invite.dart';
import '../models/user_role.dart';

/// Akses data profil user dan undangan di Firestore.
///
/// UI tidak boleh memakai Firestore langsung; semua lewat service ini.
class UserService {
  UserService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection('users');

  CollectionReference<Map<String, dynamic>> get _invites =>
      _firestore.collection('invites');

  static String _normalizeEmail(String email) => email.trim().toLowerCase();

  /// Mengambil profil berdasarkan [uid]; `null` jika belum ada.
  Future<AppUser?> getUser(String uid) async {
    final doc = await _users.doc(uid).get();
    if (!doc.exists) return null;
    return AppUser.fromFirestore(doc);
  }

  /// Mencari profil berdasarkan [email]. Hanya berhasil untuk Superadmin
  /// (diatur Security Rules).
  Future<AppUser?> findByEmail(String email) async {
    final snapshot = await _users
        .where('email', isEqualTo: _normalizeEmail(email))
        .limit(1)
        .get();
    if (snapshot.docs.isEmpty) return null;
    return AppUser.fromFirestore(snapshot.docs.first);
  }

  /// Memantau profil secara realtime (mis. untuk mendeteksi akun yang
  /// dinonaktifkan Superadmin saat sedang login).
  Stream<AppUser?> watchUser(String uid) {
    return _users.doc(uid).snapshots().map(
          (doc) => doc.exists ? AppUser.fromFirestore(doc) : null,
        );
  }

  /// Memantau seluruh user (khusus Superadmin), urut nama.
  ///
  /// Dokumen dengan data rusak (mis. role tidak dikenal) dilewati agar
  /// satu dokumen buruk tidak merusak seluruh daftar.
  Stream<List<AppUser>> watchUsers() {
    return _users.snapshots().map((snapshot) {
      final users = <AppUser>[];
      for (final doc in snapshot.docs) {
        try {
          users.add(AppUser.fromFirestore(doc));
        } on FormatException catch (e) {
          debugPrint('[UserService] Dokumen user dilewati (${doc.id}): $e');
        }
      }
      users.sort(
        (a, b) => a.nama.toLowerCase().compareTo(b.nama.toLowerCase()),
      );
      return users;
    });
  }

  /// Memantau seluruh undangan (khusus Superadmin), terbaru di atas.
  Stream<List<Invite>> watchInvites() {
    return _invites.snapshots().map((snapshot) {
      final invites = <Invite>[];
      for (final doc in snapshot.docs) {
        try {
          invites.add(Invite.fromFirestore(doc));
        } on FormatException catch (e) {
          debugPrint('[UserService] Undangan dilewati (${doc.id}): $e');
        }
      }
      invites.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return invites;
    });
  }

  /// Memastikan profil untuk [firebaseUser] ada; membuatnya jika belum.
  ///
  /// Role ditentukan di sini dengan aturan ketat:
  /// - default: [UserRole.pengguna];
  /// - jika ada undangan untuk email ini DAN email sudah terverifikasi
  ///   (mis. login Google), pakai role dari undangan.
  ///
  /// Aturan yang sama ditegakkan lagi oleh `firestore.rules`, jadi
  /// memodifikasi kode ini tidak akan memberi hak akses lebih.
  Future<AppUser> ensureProfile(User firebaseUser, {String? nama}) async {
    final existing = await getUser(firebaseUser.uid);
    if (existing != null) return existing;

    final email = firebaseUser.email;
    if (email == null || email.isEmpty) {
      throw StateError('Akun Firebase tidak memiliki email.');
    }

    final role = firebaseUser.emailVerified
        ? await _invitedRole(email) ?? UserRole.pengguna
        : UserRole.pengguna;

    final displayName = (nama ?? firebaseUser.displayName ?? '').trim();

    await _users.doc(firebaseUser.uid).set({
      'nama': displayName.isEmpty ? email.split('@').first : displayName,
      'email': email,
      'role': role.value,
      'isActive': true,
      'createdAt': FieldValue.serverTimestamp(),
    });

    final created = await getUser(firebaseUser.uid);
    if (created == null) {
      throw StateError('Profil gagal dibuat.');
    }
    return created;
  }

  /// Membaca role dari undangan untuk [email]; `null` jika tidak ada atau
  /// role-nya tidak dikenal.
  Future<UserRole?> _invitedRole(String email) async {
    final doc = await _invites.doc(_normalizeEmail(email)).get();
    if (!doc.exists) return null;
    return UserRole.tryParse(doc.data()?['role'] as String?);
  }

  // ---- Khusus Superadmin ----

  /// Membuat undangan agar [email] mendapat [role] saat pertama kali
  /// login. Role yang boleh daftar mandiri tidak perlu undangan.
  Future<void> createInvite({
    required String email,
    required UserRole role,
    required String invitedByUid,
  }) {
    if (role.canSelfRegister) {
      throw ArgumentError.value(role, 'role', 'Tidak memerlukan undangan');
    }
    return _invites.doc(_normalizeEmail(email)).set({
      'role': role.value,
      'invitedBy': invitedByUid,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteInvite(String email) {
    return _invites.doc(_normalizeEmail(email)).delete();
  }

  Future<void> setActive(String uid, {required bool isActive}) {
    return _users.doc(uid).update({'isActive': isActive});
  }

  Future<void> updateRole(String uid, UserRole role) {
    return _users.doc(uid).update({'role': role.value});
  }
    /// Mengubah role dan penugasan apotek dalam SATU update, karena Rules
  /// mewajibkan `apotekId` hanya ada jika role-nya `apoteker`.
  Future<void> updateAccess(
    String uid, {
    required UserRole role,
    String? apotekId,
  }) {
    return _users.doc(uid).update({'role': role.value, 'apotekId': apotekId});
  }
}

/// Menyediakan [UserService] ke seluruh aplikasi.
final userServiceProvider = Provider<UserService>((ref) => UserService());

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart' show User;
// import 'package:flutter_riverpod/flutter_riverpod.dart';

// import '../models/app_user.dart';
// import '../models/user_role.dart';

// /// Akses data profil user dan undangan di Firestore.
// ///
// /// UI tidak boleh memakai Firestore langsung; semua lewat service ini.
// class UserService {
//   UserService({FirebaseFirestore? firestore})
//       : _firestore = firestore ?? FirebaseFirestore.instance;

//   final FirebaseFirestore _firestore;

//   CollectionReference<Map<String, dynamic>> get _users =>
//       _firestore.collection('users');

//   CollectionReference<Map<String, dynamic>> get _invites =>
//       _firestore.collection('invites');

//   static String _normalizeEmail(String email) => email.trim().toLowerCase();

//   /// Mengambil profil berdasarkan [uid]; `null` jika belum ada.
//   Future<AppUser?> getUser(String uid) async {
//     final doc = await _users.doc(uid).get();
//     if (!doc.exists) return null;
//     return AppUser.fromFirestore(doc);
//   }

//   /// Memantau profil secara realtime (mis. untuk mendeteksi akun yang
//   /// dinonaktifkan Superadmin saat sedang login).
//   Stream<AppUser?> watchUser(String uid) {
//     return _users.doc(uid).snapshots().map(
//           (doc) => doc.exists ? AppUser.fromFirestore(doc) : null,
//         );
//   }

//   /// Memastikan profil untuk [firebaseUser] ada; membuatnya jika belum.
//   ///
//   /// Role ditentukan di sini dengan aturan ketat:
//   /// - default: [UserRole.pengguna];
//   /// - jika ada undangan untuk email ini DAN email sudah terverifikasi
//   ///   (mis. login Google), pakai role dari undangan.
//   ///
//   /// Aturan yang sama ditegakkan lagi oleh `firestore.rules`, jadi
//   /// memodifikasi kode ini tidak akan memberi hak akses lebih.
//   Future<AppUser> ensureProfile(User firebaseUser, {String? nama}) async {
//     final existing = await getUser(firebaseUser.uid);
//     if (existing != null) return existing;

//     final email = firebaseUser.email;
//     if (email == null || email.isEmpty) {
//       throw StateError('Akun Firebase tidak memiliki email.');
//     }

//     final role = firebaseUser.emailVerified
//         ? await _invitedRole(email) ?? UserRole.pengguna
//         : UserRole.pengguna;

//     final displayName = (nama ?? firebaseUser.displayName ?? '').trim();

//     await _users.doc(firebaseUser.uid).set({
//       'nama': displayName.isEmpty ? email.split('@').first : displayName,
//       'email': email,
//       'role': role.value,
//       'isActive': true,
//       'createdAt': FieldValue.serverTimestamp(),
//     });

//     final created = await getUser(firebaseUser.uid);
//     if (created == null) {
//       throw StateError('Profil gagal dibuat.');
//     }
//     return created;
//   }

//   /// Membaca role dari undangan untuk [email]; `null` jika tidak ada atau
//   /// role-nya tidak dikenal.
//   Future<UserRole?> _invitedRole(String email) async {
//     final doc = await _invites.doc(_normalizeEmail(email)).get();
//     if (!doc.exists) return null;
//     return UserRole.tryParse(doc.data()?['role'] as String?);
//   }

//   // ---- Khusus Superadmin (dipakai di tahap manajemen user) ----

//   /// Superadmin membuat undangan agar [email] mendapat [role] saat
//   /// pertama kali login.
//   Future<void> createInvite({
//     required String email,
//     required UserRole role,
//     required String invitedByUid,
//   }) {
//     return _invites.doc(_normalizeEmail(email)).set({
//       'role': role.value,
//       'invitedBy': invitedByUid,
//       'createdAt': FieldValue.serverTimestamp(),
//     });
//   }

//   Future<void> setActive(String uid, {required bool isActive}) {
//     return _users.doc(uid).update({'isActive': isActive});
//   }

//   Future<void> updateRole(String uid, UserRole role) {
//     return _users.doc(uid).update({'role': role.value});
//   }
// }

// /// Menyediakan [UserService] ke seluruh aplikasi.
// final userServiceProvider = Provider<UserService>((ref) => UserService());