import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

import 'user_role.dart';

/// Undangan role untuk sebuah email (Firestore: `invites/{email}`).
///
/// Dipakai saat orang itu pertama kali login: profilnya dibuat dengan
/// [role] dari undangan ini (khusus email yang sudah terverifikasi).
class Invite extends Equatable {
  const Invite({
    required this.email,
    required this.role,
    required this.invitedBy,
    required this.createdAt,
  });

  factory Invite.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    if (data == null) {
      throw FormatException('Dokumen undangan ${doc.id} kosong');
    }
    return Invite(
      email: doc.id,
      role: UserRole.fromValue(data['role'] as String? ?? ''),
      invitedBy: data['invitedBy'] as String? ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// ID dokumen = email (huruf kecil).
  final String email;
  final UserRole role;
  final String invitedBy;
  final DateTime createdAt;

  @override
  List<Object?> get props => [email, role, invitedBy, createdAt];
}