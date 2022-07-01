import 'package:flutter/material.dart';
import 'package:shop/models/cart_item.dart';

class CartItemWidget extends StatelessWidget {
  final CartItem cartItem;
  const CartItemWidget({required this.cartItem, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final total = cartItem.price * cartItem.quantity;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          child: Padding(
            padding: const EdgeInsets.all(2),
            child: FittedBox(
              child: Text(
                cartItem.price.toStringAsFixed(2),
              ),
            ),
          ),
        ),
        title: Text(cartItem.name),
        subtitle: Text('Total: R\$ $total'),
        trailing: Text('${cartItem.quantity}x'),
      ),
    );
  }
}
