import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/shopping_list.dart';
import '../providers/shopping_list_provider.dart';
import '../providers/connection_provider.dart'; // 🔥 Aggiunto per lo stato connessione
import 'shopping_list_detail_screen.dart';
import 'auth_screen.dart';

class ShoppingListScreen extends ConsumerWidget {
  const ShoppingListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shoppingLists = ref.watch(shoppingListProvider);
    final user = FirebaseAuth.instance.currentUser; // Ottieni l'utente attuale
    final bool isOnline = ref.watch(
      connectionStatusProvider,
    ); // 🔥 Controllo connessione

    return Scaffold(
      appBar: AppBar(
        title: const Text("Le mie Liste della Spesa"),
        actions: [
          if (user != null) // Mostra l'immagine solo se l'utente è loggato
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Stack(
                children: [
                  CircleAvatar(
                    backgroundImage:
                        user.photoURL != null
                            ? NetworkImage(user.photoURL!)
                            : null,
                    backgroundColor: Colors.grey[300],
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color:
                            isOnline
                                ? Colors.green
                                : Colors.orange, // ✅ Stato connessione
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const AuthScreen()),
              );
            },
          ),
        ],
      ),
      body:
          shoppingLists.isEmpty
              ? const Center(child: Text("Nessuna lista disponibile"))
              : ListView.builder(
                itemCount: shoppingLists.length,
                itemBuilder: (context, index) {
                  final list = shoppingLists[index];
                  return ListTile(
                    title: Text(list.name),
                    subtitle: Text("Completamento: ${list.progress.toInt()}%"),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => ShoppingListDetailScreen(list: list),
                        ),
                      );
                    },
                  );
                },
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addShoppingList(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _addShoppingList(BuildContext context, WidgetRef ref) {
    TextEditingController controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Nuova Lista della Spesa"),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: "Inserisci un nome"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Annulla"),
            ),
            ElevatedButton(
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  final newList = ShoppingList(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    name: controller.text,
                    progress: 0.0,
                    items: [],
                  );
                  ref
                      .read(shoppingListProvider.notifier)
                      .addShoppingList(newList);
                  Navigator.pop(context);
                }
              },
              child: const Text("Crea"),
            ),
          ],
        );
      },
    );
  }
}
