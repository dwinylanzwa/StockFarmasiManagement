import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const ProviderScope(child: HalObatApp()));
}
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';

// import 'app.dart';
// import 'core/database/dummy_data_seeder.dart';
// import 'features/auth/presentation/providers/user_repository_provider.dart';

// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();

//   // Container dibuat manual agar bisa dipakai sebelum runApp (seeding),
//   // lalu diteruskan ke UncontrolledProviderScope supaya instance
//   // database/repository yang sama dipakai oleh seluruh aplikasi.
//   final container = ProviderContainer();

//   // Hanya berjalan di debug mode. Lihat dummy_data_seeder.dart.
//   await DummyDataSeeder(container.read(userRepositoryProvider)).seed();

//   runApp(
//     UncontrolledProviderScope(
//       container: container,
//       child: const HalObatApp(),
//     ),
//   );
// }
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';

// import 'app.dart';

// Future<void> main() async {
//   // Wajib dipanggil sebelum memakai plugin (sqflite, secure storage, dll.)
//   // yang berjalan sebelum runApp.
//   WidgetsFlutterBinding.ensureInitialized();

//   runApp(const ProviderScope(child: HalObatApp()));
// }