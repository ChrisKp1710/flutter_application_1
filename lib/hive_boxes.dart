import 'package:hive/hive.dart';
import 'models/shopping_list.dart';
import 'models/shopping_item.dart';

void registerHiveAdapters() {
  Hive.registerAdapter(ShoppingListAdapter()); // Registriamo ShoppingList
  Hive.registerAdapter(ShoppingItemAdapter()); // Registriamo ShoppingItem
}
