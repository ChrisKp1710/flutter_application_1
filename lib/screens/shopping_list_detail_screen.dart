import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/shopping_list.dart';
import '../models/shopping_item.dart';
import '../services/firestore_service.dart';
import '../services/hive_service.dart';

class ShoppingListDetailScreen extends ConsumerStatefulWidget {
  final ShoppingList list;

  const ShoppingListDetailScreen({Key? key, required this.list})
    : super(key: key);

  @override
  _ShoppingListDetailScreenState createState() =>
      _ShoppingListDetailScreenState();
}

class _ShoppingListDetailScreenState
    extends ConsumerState<ShoppingListDetailScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final HiveService _hiveService = HiveService();

  List<ShoppingItem> items = [];

  @override
  void initState() {
    super.initState();
    _loadItems();
    _syncWithFirebase(); // 🔥 Aggiunto per sincronizzare Firebase con Hive
  }

  // 🔄 Carica gli elementi dalla lista locale Hive
  void _loadItems() {
    items = widget.list.items;
  }

  // 🔄 Sincronizza Firebase con Hive
  void _syncWithFirebase() {
    _firestoreService.getShoppingListItems(widget.list.id).listen((
      firebaseItems,
    ) {
      setState(() {
        items = firebaseItems;
      });
      widget.list.items = firebaseItems;
      _hiveService.saveShoppingList(widget.list); // Aggiorna Hive con Firebase
    });
  }

  // ✅ Toggle dello stato della checkbox
  void _toggleItem(ShoppingItem item) {
    setState(() {
      item.checked = !item.checked;
    });

    _firestoreService.updateItemStatus(widget.list.id, item.id, item.checked);
    _hiveService.saveShoppingList(widget.list);
  }

  // ➕ Aggiunta di un nuovo elemento alla lista
  void _addItem() {
    TextEditingController controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Aggiungi un elemento"),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: "Nome dell'elemento"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Annulla"),
            ),
            ElevatedButton(
              onPressed: () async {
                if (controller.text.isNotEmpty) {
                  String itemName = controller.text.trim();

                  // Controlla se l’elemento esiste già
                  bool alreadyExists = items.any(
                    (item) => item.name == itemName,
                  );
                  if (alreadyExists) {
                    Navigator.pop(context);
                    return;
                  }

                  final newItem = ShoppingItem(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    name: itemName,
                    checked: false,
                  );

                  setState(() {
                    items.add(newItem);
                  });

                  // 🔥 Salva SUBITO in Hive per la modalità offline
                  widget.list.items.add(newItem);
                  _hiveService.saveShoppingList(widget.list);

                  // 🔥 CHIUDI LA MODALE IMMEDIATAMENTE
                  if (mounted) {
                    Navigator.pop(context);
                  }

                  // 🔄 Tenta di salvare su Firestore in background
                  try {
                    await _firestoreService.addItemToList(
                      widget.list.id,
                      newItem,
                    );
                  } catch (e) {
                    if (kDebugMode) {
                      print("⚠️ Errore nel salvataggio su Firebase: $e");
                    }

                    // 🔥 Mostra un messaggio di avviso solo se il salvataggio fallisce
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            "Elemento salvato solo offline. Si sincronizzerà appena disponibile.",
                          ),
                          backgroundColor: Colors.orange,
                        ),
                      );
                    }
                  }
                }
              },
              child: const Text("Aggiungi"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.list.name)),
      body:
          items.isEmpty
              ? const Center(
                child: Text("Qui puoi aggiungere i tuoi prodotti!"),
              )
              : ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  return CheckboxListTile(
                    title: Text(
                      item.name,
                      style: TextStyle(
                        decoration:
                            item.checked
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                      ),
                    ),
                    value: item.checked,
                    onChanged: (value) => _toggleItem(item),
                  );
                },
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addItem,
        child: const Icon(Icons.add),
      ),
    );
  }
}
