import 'dart:io'; // ✅ Import necessario per controllare il sistema operativo
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1/screens/email_signin_screen.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:flutter_application_1/screens/shopping_list_screen.dart';
import 'package:shared_preferences/shared_preferences.dart'; // ✅ Importato SharedPreferences

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 🔥 Se l'utente è già loggato, lo reindirizziamo direttamente
    if (FirebaseAuth.instance.currentUser != null) {
      Future.microtask(() {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ShoppingListScreen()),
        );
      });
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Accedi o Registrati")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.email),
              label: const Text("Accedi con Email"),
              onPressed: () => _signInWithEmail(context),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              icon: const Icon(Icons.g_mobiledata),
              label: const Text("Accedi con Google"),
              onPressed: () => _signInWithGoogle(context),
            ),
            const SizedBox(height: 10),

            // 🔥 Mostra il pulsante Apple SOLO su iOS/macOS
            if (Platform.isIOS || Platform.isMacOS)
              ElevatedButton.icon(
                icon: const Icon(Icons.apple),
                label: const Text("Accedi con Apple"),
                onPressed: () => _signInWithApple(context),
              ),
          ],
        ),
      ),
    );
  }

  /// 🔹 Login con Google e salvataggio dell'immagine profilo
  Future<void> _signInWithGoogle(BuildContext context) async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await FirebaseAuth.instance.signInWithCredential(
        credential,
      );
      final user = userCredential.user;

      if (user != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(
          'profileImage',
          user.photoURL ?? "",
        ); // ✅ Salva immagine profilo

        _navigateToShoppingList(context);
      }
    } catch (e) {
      if (kDebugMode) {
        print("❌ Errore accesso Google: $e");
      }
    }
  }

  /// 🔹 Login con Apple
  Future<void> _signInWithApple(BuildContext context) async {
    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final oauthCredential = OAuthProvider(
        "apple.com",
      ).credential(idToken: credential.identityToken);
      await FirebaseAuth.instance.signInWithCredential(oauthCredential);

      _navigateToShoppingList(context);
    } catch (e) {
      if (kDebugMode) {
        print("❌ Errore accesso Apple: $e");
      }
    }
  }

  /// 🔹 Login con Email e Password
  Future<void> _signInWithEmail(BuildContext context) async {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const EmailSignInScreen()),
    );
  }

  /// 🔹 Naviga alla schermata principale dopo il login
  void _navigateToShoppingList(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const ShoppingListScreen()),
    );
  }
}
