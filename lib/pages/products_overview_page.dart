import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/components/badge.dart';
import 'package:shop/models/cart.dart';
import 'package:shop/utils/app_routes.dart';

import '../components/product_grid.dart';

enum FilterOptions { Favorite, All }

class ProductOverviewPage extends StatefulWidget {
  const ProductOverviewPage({Key? key}) : super(key: key);

  @override
  State<ProductOverviewPage> createState() => _ProductOverviewPageState();
}

class _ProductOverviewPageState extends State<ProductOverviewPage> {
  bool _showFavoriteOnly = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text('Minha Loja'),
        ),
        actions: [
          PopupMenuButton(
              initialValue: FilterOptions.Favorite,
              icon: const Icon(Icons.more_vert),
              itemBuilder: (_) => [
                    const PopupMenuItem(
                      value: FilterOptions.Favorite,
                      child: Text('Somente Favoritos'),
                    ),
                    const PopupMenuItem(
                      value: FilterOptions.All,
                      child: Text('Todos'),
                    ),
                  ],
              onSelected: (FilterOptions value) {
                setState(() {
                  if (value == FilterOptions.Favorite) {
                    _showFavoriteOnly = true;
                  } else {
                    _showFavoriteOnly = false;
                  }
                });
              }),
          Consumer<Cart>(
            child: IconButton(
              onPressed: () {
                Navigator.of(context).pushNamed(AppRoutes.CART_PAGE);
              },
              icon: const Icon(
                Icons.shopping_cart,
              ),
            ),
            builder: (context, cart, child) => Badge(
              value: cart.itemsCount.toString(),
              child: child!,
            ),
          )
        ],
      ),
      body: ProductGrid(_showFavoriteOnly),
    );
  }
}
