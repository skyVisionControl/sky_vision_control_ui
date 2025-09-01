// Bu dosya, uygulamanın başlangıç noktasıdır.
// Uygulama yapılandırmasını, tema ayarlarını ve ana provider'ları başlatır.

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kapadokya_balon_app/core/themes/app_theme.dart';
import 'package:kapadokya_balon_app/presentation/routes/app_router.dart';
import 'package:firebase_database/firebase_database.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
/*
  // Ekranın yönünü sadece yatay moda kilitle (tablet için)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

 */

  // Uygulama başlangıç yapılandırmaları burada yapılabilir
  // Örneğin: Hive, SharedPreferences, Firebase başlatma
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // ✅ RTDB doğru region’da açılıyor
  final europeDb = FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL: 'https://sky-vision-control-5ca1b-default-rtdb.europe-west1.firebasedatabase.app',
  );

  runApp(
    const ProviderScope(
      child: KapadokyaBalonApp(),
    ),
  );
}

class KapadokyaBalonApp extends ConsumerWidget {
  const KapadokyaBalonApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'Sky Vision Control',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light, // İleride bir provider ile değiştirilebilir
      routerDelegate: router.routerDelegate,
      routeInformationParser: router.routeInformationParser,
      routeInformationProvider: router.routeInformationProvider,
    );
  }
}