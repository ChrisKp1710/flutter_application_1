import 'package:hive/hive.dart';

part 'shopping_item.g.dart'; // Questo sarà generato da Hive

@HiveType(typeId: 1) // Identificativo univoco per Hive
class ShoppingItem extends HiveObject {
  @HiveField(0)
  String id; // ID dell'elemento

  @HiveField(1)
  String name; // Nome del prodotto

  @HiveField(2)
  bool checked; // Se è stato preso o no

  ShoppingItem({required this.id, required this.name, this.checked = false});

  // Metodo per convertire da Firestore a Dart
  factory ShoppingItem.fromFirestore(Map<String, dynamic> data, String id) {
    return ShoppingItem(
      id: id,
      name: data["name"] ?? "Sconosciuto",
      checked: data["checked"] ?? false,
    );
  }

  // Metodo per convertire in Firestore
  Map<String, dynamic> toFirestore() {
    return {"name": name, "checked": checked};
  }
}
