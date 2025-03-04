import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1/screens/email_signin_screen.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:flutter_application_1/screens/shopping_list_screen.dart'; // Schermata della lista della spesa

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});
  Future<void> _signInWithGoogle(BuildContext context) async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    if (googleUser == null) return; // Utente ha annullato l'accesso

    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    await FirebaseAuth.instance.signInWithCredential(credential);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => ShoppingListScreen()),
    );
  }

  Future<void> _signInWithApple(BuildContext context) async {
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
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => ShoppingListScreen()),
    );
  }

  Future<void> _signInWithEmail(BuildContext context) async {
    // Naviga alla schermata di registrazione con email e password
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EmailSignInScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Accedi o Registrati")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              icon: Icon(Icons.email),
              label: Text("Accedi con Email"),
              onPressed: () => _signInWithEmail(context),
            ),
            SizedBox(height: 10),
            ElevatedButton.icon(
              icon: Icon(Icons.g_mobiledata),
              label: Text("Accedi con Google"),
              onPressed: () => _signInWithGoogle(context),
            ),
            SizedBox(height: 10),
            ElevatedButton.icon(
              icon: Icon(Icons.apple),
              label: Text("Accedi con Apple"),
              onPressed: () => _signInWithApple(context),
            ),
          ],
        ),
      ),
    );
  }
}
