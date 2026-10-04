import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/item.dart';

class ItemProvider extends ChangeNotifier {
  List<Item> _items = [];

  List<Item> get items => _items;

  Future<void> loadItems() async {
    final prefs = await SharedPreferences.getInstance();

    final savedItems = prefs.getStringList('items');

    if (savedItems == null) {
      _items = [];
      return;
    }

    _items = savedItems.map((item) {
      final data = jsonDecode(item);

      return Item(
        id: data['id'] ?? '',
        name: data['name'] ?? '',
        category: data['category'] ?? '',
        location: data['location'] ?? '',
        date: DateTime.parse(data['date']),
        color: data['color'] ?? '',
        brand: data['brand'] ?? '',
        description: data['description'] ?? '',
        isLost: data['isLost'] ?? false,

        // Important:
        // Old items may not have ownerEmail.
        ownerEmail: data['ownerEmail'] ?? '',
      );
    }).toList();

    notifyListeners();
  }

  Future<void> addItem({
    required String name,
    required String category,
    required String location,
    required DateTime date,
    required String color,
    required String brand,
    required String description,
    required bool isLost,
    required String ownerEmail,
  }) async {
    final newItem = Item(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      category: category,
      location: location,
      date: date,
      color: color,
      brand: brand,
      description: description,
      isLost: isLost,
      ownerEmail: ownerEmail,
    );

    _items.insert(0, newItem);

    await _saveItems();

    notifyListeners();
  }

  Future<void> deleteItem(String id) async {
    _items.removeWhere((item) => item.id == id);

    await _saveItems();

    notifyListeners();
  }

  Future<void> _saveItems() async {
    final prefs = await SharedPreferences.getInstance();

    final savedItems = _items.map((item) {
      return jsonEncode({
        'id': item.id,
        'name': item.name,
        'category': item.category,
        'location': item.location,
        'date': item.date.toIso8601String(),
        'color': item.color,
        'brand': item.brand,
        'description': item.description,
        'isLost': item.isLost,
        'ownerEmail': item.ownerEmail,
      });
    }).toList();

    await prefs.setStringList('items', savedItems);
  }
}