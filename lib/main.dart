import 'package:custom_quick_alert/custom_quick_alert.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'firebase_options.dart';

// Pages
import 'package:inventify/pages/splash.dart';

// ✅ 1. Deklarasi navigatorKey secara global
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await initializeDateFormatting('id_ID', null);

  // ✅ 2. Inisialisasi CustomQuickAlert sebelum runApp
  CustomQuickAlert.initialize(navigatorKey);

  runApp(const MyApp());
}

////////////////////////////////////////////////////////////
/// APP ROOT
////////////////////////////////////////////////////////////
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
    );
  }
}
