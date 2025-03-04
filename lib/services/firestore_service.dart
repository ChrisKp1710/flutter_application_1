import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/shopping_list.dart';
import '../models/shopping_item.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // 🔥 Crea una nuova lista della spesa in Firestore
  Future<void> createShoppingList(ShoppingList list) async {
    try {
      await _db
          .collection("shopping_lists")
          .doc(list.id)
          .set(list.toFirestore());
    } catch (e) {
      if (kDebugMode) {
        print("❌ Errore nella creazione della lista: $e");
      }
    }
  }

  // 🔄 Recupera tutte le liste della spesa in tempo reale
  Stream<List<ShoppingList>> getShoppingLists() {
    return _db.collection("shopping_lists").snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => ShoppingList.fromFirestore(doc.data(), doc.id))
          .toList();
    });
  }

  // 🔄 Recupera gli elementi della lista della spesa in tempo reale
  Stream<List<ShoppingItem>> getShoppingListItems(String listId) {
    return _db
        .collection("shopping_lists")
        .doc(listId)
        .collection("items")
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();
            return ShoppingItem(
              id: doc.id,
              name: data['name'] ?? '',
              checked: data['checked'] ?? false,
            );
          }).toList();
        });
  }

  // ➕ Aggiunge un nuovo elemento a una lista della spesa
  Future<void> addItemToList(String listId, ShoppingItem item) async {
    try {
      await _db
          .collection("shopping_lists")
          .doc(listId)
          .collection("items")
          .doc(item.id)
          .set(item.toFirestore());
    } catch (e) {
      if (kDebugMode) {
        print("❌ Errore nell'aggiunta dell'elemento: $e");
      }
    }
  }

  // ✅ Aggiorna lo stato della checkbox (se l’elemento è stato preso o no)
  Future<void> updateItemStatus(
    String listId,
    String itemId,
    bool checked,
  ) async {
    try {
      await _db
          .collection("shopping_lists")
          .doc(listId)
          .collection("items")
          .doc(itemId)
          .update({"checked": checked});
    } catch (e) {
      if (kDebugMode) {
        print("❌ Errore nell'aggiornamento dell'elemento: $e");
      }
    }
  }

  // ❌ Elimina una lista della spesa
  Future<void> deleteShoppingList(String listId) async {
    try {
      await _db.collection("shopping_lists").doc(listId).delete();
    } catch (e) {
      if (kDebugMode) {
        print("❌ Errore nell'eliminazione della lista: $e");
      }
    }
  }
}
