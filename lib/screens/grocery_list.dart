import 'dart:convert';

import 'package:demo5/data/categories.dart';
import 'package:http/http.dart' as http;
import 'package:demo5/models/grocery_item.dart';
import 'package:demo5/screens/new_item.dart';
import 'package:demo5/widgets/grocery_item.dart';
import 'package:flutter/material.dart';

class GroceryList extends StatefulWidget {
  const GroceryList({super.key});

  @override
  State<GroceryList> createState() => _GroceryListState();
}

class _GroceryListState extends State<GroceryList> {
  final List<GroceryItem> _groceryItems = [];
  late Future<List<GroceryItem>> _loadedItems;

  @override
  void initState() {
    super.initState();
    _loadedItems = _loadItems();
  }

  Future<List<GroceryItem>> _loadItems() async {
    final url = Uri.https(
      'flutter-api-fa6f7-default-rtdb.firebaseio.com',
      'shopping-list.json',
    );

    final response = await http.get(url);
    if (response.statusCode >= 400) {
      throw Exception('An error has occured. Please try again later');
    }

    if (response.body == 'null') {
      return [];
    }

    final Map<String, dynamic> listData = json.decode(response.body);
    final List<GroceryItem> loadedItems = [];
    for (var item in listData.entries) {
      final category =
          categories.entries
              .firstWhere((cat) => cat.value.name == item.value['category'])
              .value;
      loadedItems.add(
        GroceryItem(
          id: item.key,
          name: item.value['name'],
          quantity: item.value['quantity'],
          category: category,
        ),
      );
    }

    return loadedItems;
  }

  void _addItem() async {
    final newGroceryItem = await Navigator.of(
      context,
    ).push<GroceryItem>(MaterialPageRoute(builder: (ctx) => NewItem()));
    if (newGroceryItem == null) return;

    setState(() {
      _groceryItems.add(newGroceryItem);
    });
  }

  void removeItem(String id) async {
    final item = _groceryItems.firstWhere((item) => item.id == id);
    setState(() {
      _groceryItems.remove(item);
    });
    final url = Uri.https(
      'flutter-api-fa6f7-default-rtdb.firebaseio.com',
      'shopping-list/$id.json',
    );

    final response = await http.delete(url);

    if (response.statusCode >= 400) {
      setState(() {
        _groceryItems.add(item);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Your Groceries"),
        actions: [IconButton(onPressed: _addItem, icon: const Icon(Icons.add))],
      ),
      body: FutureBuilder(
        future: _loadedItems,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          }

          if (snapshot.data!.isEmpty) {
            return Center(child: Text('No grocery items yet'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder:
                (context, index) => GroceryItemWidget(
                  snapshot.data![index],
                  onDismissed: removeItem,
                ),
          );
        },
      ),
    );
  }
}
