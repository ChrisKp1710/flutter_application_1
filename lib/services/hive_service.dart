import 'package:hive/hive.dart';
import '../models/shopping_list.dart';

class HiveService {
  static const String shoppingListsBox = 'shopping_lists';

  // Inizializza Hive
  Future<void> initHive() async {
    await Hive.openBox<ShoppingList>(shoppingListsBox);
  }

  // Recupera tutte le liste salvate in locale
  List<ShoppingList> getShoppingLists() {
    final box = Hive.box<ShoppingList>(shoppingListsBox);
    return box.values.toList();
  }

  // Salva una nuova lista della spesa
  Future<void> saveShoppingList(ShoppingList list) async {
    final box = Hive.box<ShoppingList>(shoppingListsBox);
    await box.put(list.id, list);
  }

  // Cancella una lista
  Future<void> deleteShoppingList(String listId) async {
    final box = Hive.box<ShoppingList>(shoppingListsBox);
    await box.delete(listId);
  }
}
