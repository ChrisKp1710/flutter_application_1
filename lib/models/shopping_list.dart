import 'package:hive/hive.dart';
import 'shopping_item.dart'; // Assicurati di importarlo correttamente
part 'shopping_list.g.dart'; // Questo è necessario per Hive

@HiveType(typeId: 0) // Identificativo univoco per Hive
class ShoppingList extends HiveObject {
  @HiveField(0)
  String id; // ID della lista (generato da Firestore)

  @HiveField(1)
  String name; // Nome della lista

  @HiveField(2)
  double progress; // Percentuale di completamento

  @HiveField(3)
  List<ShoppingItem> items; // Lista degli elementi

  ShoppingList({
    required this.id,
    required this.name,
    this.progress = 0.0,
    this.items = const [],
  });

  // Metodo per convertire da Firestore a Dart
  factory ShoppingList.fromFirestore(Map<String, dynamic> data, String id) {
    return ShoppingList(
      id: id,
      name: data["name"] ?? "Lista senza nome",
      progress: (data["progress"] as num).toDouble(),
      items: [], // Popoliamo in seguito gli item
    );
  }

  // Metodo per convertire in Firestore
  Map<String, dynamic> toFirestore() {
    return {"name": name, "progress": progress};
  }
}
