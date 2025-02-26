import 'package:flutter/material.dart';

class ShoppingListScreen extends StatelessWidget {
  const ShoppingListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("La Mia Lista della Spesa")),
      body: Center(child: Text("Qui puoi aggiungere i tuoi prodotti!")),
    );
  }
}
