import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1/screens/email_signin_screen.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:flutter_application_1/screens/shopping_list_screen.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 🔥 Se l'utente è già loggato, reindirizzalo direttamente alla ShoppingListScreen
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

      await FirebaseAuth.instance.signInWithCredential(credential);
      _navigateToShoppingList(context);
    } catch (e) {
      if (kDebugMode) {
        print("❌ Errore accesso Google: $e");
      }
    }
  }

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

  Future<void> _signInWithEmail(BuildContext context) async {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const EmailSignInScreen()),
    );
  }

  void _navigateToShoppingList(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const ShoppingListScreen()),
    );
  }
}
