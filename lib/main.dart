import 'firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter_application_1/screens/auth_screen.dart';
import 'package:flutter_application_1/screens/shopping_list_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Aggiunto per Riverpod
import 'package:firebase_auth/firebase_auth.dart';
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

  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AuthWrapper(), // 🔥 Controlla se l'utente è già loggato
      navigatorObservers: [FirebaseAnalyticsObserver(analytics: analytics)],
    );
  }
}

// 🔥 Questa classe decide se mostrare la schermata di login o la lista della spesa
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasData) {
          return const ShoppingListScreen(); // 🔥 Se l'utente è loggato, va alla lista
        } else {
          return const AuthScreen(); // 🔥 Se non è loggato, mostra la schermata di login
        }
      },
    );
  }
}
