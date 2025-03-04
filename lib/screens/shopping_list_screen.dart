import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart'; // ✅ Importato SharedPreferences
import '../models/shopping_list.dart';
import '../providers/shopping_list_provider.dart';
import '../providers/connection_provider.dart';
import 'shopping_list_detail_screen.dart';
import 'auth_screen.dart';

class ShoppingListScreen extends ConsumerStatefulWidget {
  const ShoppingListScreen({super.key});

  @override
  _ShoppingListScreenState createState() => _ShoppingListScreenState();
}

class _ShoppingListScreenState extends ConsumerState<ShoppingListScreen> {
  String? profileImage;

  @override
  void initState() {
    super.initState();
    _loadProfileImage(); // ✅ Carica immagine salvata all'avvio
  }

  Future<void> _loadProfileImage() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      profileImage = prefs.getString('profileImage');
    });
  }

  @override
  Widget build(BuildContext context) {
    final shoppingLists = ref.watch(shoppingListProvider);
    final user = FirebaseAuth.instance.currentUser;
    final bool isOnline = ref.watch(connectionStatusProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Le mie Liste della Spesa"),
        actions: [
          if (user != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Stack(
                children: [
                  CircleAvatar(
                    backgroundImage:
                        profileImage != null && profileImage!.isNotEmpty
                            ? NetworkImage(profileImage!)
                            : const AssetImage("assets/default_profile.png")
                                as ImageProvider,
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
                        color: isOnline ? Colors.green : Colors.orange,
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
              final prefs = await SharedPreferences.getInstance();
              await prefs.remove('profileImage');

              if (context.mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const AuthScreen()),
                );
              }
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

  /// 🔹 Funzione per aggiungere una nuova lista della spesa
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

                  if (context.mounted) {
                    Navigator.pop(context);
                  }
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
