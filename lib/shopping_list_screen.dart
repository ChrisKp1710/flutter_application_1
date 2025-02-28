import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1/auth_screen.dart';

class ShoppingListScreen extends StatelessWidget {
  const ShoppingListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text("La Mia Lista della Spesa"),
        actions: [
          if (user != null) ...[
            CircleAvatar(
              backgroundImage:
                  user.photoURL != null
                      ? NetworkImage(user.photoURL!)
                      : AssetImage('assets/default_user.png') as ImageProvider,
            ),
            SizedBox(width: 10),
            IconButton(
              icon: Icon(Icons.logout),
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => AuthScreen()),
                );
              },
            ),
          ],
        ],
      ),
      body: Center(child: Text("Qui puoi aggiungere i tuoi prodotti!")),
    );
  }
}
