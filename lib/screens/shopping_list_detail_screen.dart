import 'package:flutter/material.dart';
import '../models/shopping_list.dart';
import '../models/shopping_item.dart';
import '../services/firestore_service.dart';

class ShoppingListDetailScreen extends StatefulWidget {
  final ShoppingList list;

  const ShoppingListDetailScreen({super.key, required this.list});

  @override
  _ShoppingListDetailScreenState createState() =>
      _ShoppingListDetailScreenState();
}

class _ShoppingListDetailScreenState extends State<ShoppingListDetailScreen> {
  final FirestoreService _firestoreService = FirestoreService();

  void _toggleItem(ShoppingItem item) {
    setState(() {
      item.checked = !item.checked;
    });
    _firestoreService.updateItemStatus(widget.list.id, item.id, item.checked);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.list.name)),
      body: ListView(
        children:
            widget.list.items.map((item) {
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
            }).toList(),
      ),
    );
  }
}
