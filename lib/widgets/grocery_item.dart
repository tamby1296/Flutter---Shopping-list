import 'package:demo5/models/grocery_item.dart';
import 'package:flutter/material.dart';

const double kBoxSize = 24;

class GroceryItemWidget extends StatelessWidget {
  final GroceryItem item;
  final Function(String)? onDismissed;

  const GroceryItemWidget(this.item, {super.key, this.onDismissed});

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(item.id),
      onDismissed: (direction) {
        if(onDismissed != null) onDismissed!(item.id);
      },
      child: ListTile(
        leading: Container(
          width: kBoxSize,
          height: kBoxSize,
          color: item.category.color,
        ),
        title: Text(item.name),
        trailing: Text(
          item.quantity.toString(),
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ),
    );
  }
}
