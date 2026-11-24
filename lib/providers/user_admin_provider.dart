import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/app_user.dart';
import '../models/invite.dart';
import '../services/user_admin_controller.dart';
import '../services/user_service.dart';
import 'current_user_provider.dart';

/// Daftar semua user (realtime). Hanya dipakai di area Superadmin.
final usersStreamProvider = StreamProvider.autoDispose<List<AppUser>>((ref) {
  return ref.watch(userServiceProvider).watchUsers();
});

/// Daftar undangan (realtime). Hanya dipakai di area Superadmin.
final invitesStreamProvider = StreamProvider.autoDispose<List<Invite>>((ref) {
  return ref.watch(userServiceProvider).watchInvites();
});

final userAdminControllerProvider = Provider<UserAdminController>((ref) {
  return UserAdminController(
    userService: ref.watch(userServiceProvider),
    currentUser: () => ref.read(currentUserProvider),
  );
});