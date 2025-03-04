import 'firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter_application_1/screens/auth_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Aggiunto per Riverpod
import 'hive_boxes.dart';
import 'services/hive_service.dart';

final FirebaseAnalytics analytics = FirebaseAnalytics.instance;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inizializza Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Inizializza Hive
  await Hive.initFlutter();
  registerHiveAdapters();
  await HiveService().initHive();

  runApp(
    ProviderScope(
      // 🔥 Avvolge l'app con ProviderScope per abilitare Riverpod
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AuthScreen(),
      // Aggiungi il NavigatorObserver per tracciare i passaggi di schermata
      navigatorObservers: [FirebaseAnalyticsObserver(analytics: analytics)],
    );
  }
}
