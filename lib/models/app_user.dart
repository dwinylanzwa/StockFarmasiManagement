import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

import 'user_role.dart';

/// Profil user aplikasi (data di Firestore, koleksi `users`).
///
/// Tidak menyimpan password: kredensial sepenuhnya dikelola Firebase Auth.
class AppUser extends Equatable {
  const AppUser({
    required this.uid,
    required this.nama,
    required this.email,
    required this.role,
    required this.createdAt,
    this.isActive = true,
    this.apotekId,
  });

  /// Membaca dokumen Firestore. Melempar [FormatException] jika role rusak.
  factory AppUser.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    if (data == null) {
      throw FormatException('Dokumen user ${doc.id} kosong');
    }
    return AppUser(
      uid: doc.id,
      nama: data['nama'] as String? ?? '',
      email: data['email'] as String? ?? '',
      role: UserRole.fromValue(data['role'] as String? ?? ''),
      isActive: data['isActive'] as bool? ?? false,
      apotekId: data['apotekId'] as String?,
      // Bernilai null sesaat setelah ditulis (server timestamp belum
      // terisi), maka diberi fallback.
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// ID user = UID Firebase Auth.
  final String uid;
  final String nama;
  final String email;
  final UserRole role;
  final DateTime createdAt;
  final bool isActive;

  /// Apotek tempat Apoteker bertugas; `null` untuk role lain atau jika
  /// belum ditugaskan. Hanya Superadmin yang boleh mengubahnya.
  final String? apotekId;

  AppUser copyWith({
    String? nama,
    UserRole? role,
    bool? isActive,
  }) {
    return AppUser(
      uid: uid,
      nama: nama ?? this.nama,
      email: email,
      role: role ?? this.role,
      createdAt: createdAt,
      isActive: isActive ?? this.isActive,
      apotekId: apotekId,
    );
  }

  @override
  List<Object?> get props =>
      [uid, nama, email, role, createdAt, isActive, apotekId];
}