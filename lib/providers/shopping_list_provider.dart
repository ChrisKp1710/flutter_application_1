import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/shopping_list.dart';
import '../services/firestore_service.dart';
import '../services/hive_service.dart';

final shoppingListProvider =
    StateNotifierProvider<ShoppingListNotifier, List<ShoppingList>>((ref) {
      return ShoppingListNotifier();
    });

class ShoppingListNotifier extends StateNotifier<List<ShoppingList>> {
  final FirestoreService _firestoreService = FirestoreService();
  final HiveService _hiveService = HiveService();

  ShoppingListNotifier() : super([]) {
    fetchShoppingLists();
  }

  // Recupera le liste della spesa da Firestore e Hive
  Future<void> fetchShoppingLists() async {
    final localLists = _hiveService.getShoppingLists();
    state = localLists;

    _firestoreService.getShoppingLists().listen((cloudLists) {
      state = cloudLists;
      for (var list in cloudLists) {
        _hiveService.saveShoppingList(list);
      }
    });
  }

  // Aggiunge una nuova lista
  Future<void> addShoppingList(ShoppingList list) async {
    state = [...state, list]; // Aggiorna lo stato con la nuova lista
    await _hiveService.saveShoppingList(list);
    await _firestoreService.createShoppingList(list);
  }

  // Elimina una lista
  Future<void> removeShoppingList(String listId) async {
    state = state.where((list) => list.id != listId).toList();
    await _hiveService.deleteShoppingList(listId);
    await _firestoreService.deleteShoppingList(listId);
  }
}
