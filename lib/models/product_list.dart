import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shop/models/product.dart';

class ProductList with ChangeNotifier {
  final _baseUrl =
      'https://shop-curso-dd940-default-rtdb.firebaseio.com/products';

  final List<Product> _items = [];

  List<Product> get items => [..._items];
  List<Product> get favoriteItems =>
      _items.where((element) => element.isFavorite).toList();

  int get intemsCount {
    return _items.length;
  }

  Future<void> saveProduct(Map<String, Object> data) {
    bool hasId = data['id'] != null;

    final product = Product(
        id: hasId ? data['id'].toString() : Random().nextDouble().toString(),
        name: data['name'].toString(),
        description: data['description'].toString(),
        imageUrl: data['imageUrl'].toString(),
        price: data['price'] as double);

    if (hasId) {
      return updateProduct(product);
    } else {
      return addProduct(product);
    }
  }

  Future<void> loadProducts() async {
    _items.clear();

    final response = await http.get(
      Uri.parse('$_baseUrl.json'),
    );

    if (response.body == 'null') return;

    Map<String, dynamic> data = jsonDecode(response.body);

    data.forEach(
      (productId, productData) {
        _items.add(
          Product(
            id: productId,
            name: productData['name'],
            description: productData['description'],
            imageUrl: productData['imageUrl'],
            price: productData['price'],
            isFavorite: productData['isFavorite'],
          ),
        );
      },
    );
    notifyListeners();
  }

  Future<void> addProduct(Product product) async {
    final response = await http.post(
      Uri.parse('$_baseUrl.json'),
      body: jsonEncode(
        {
          'name': product.name,
          'description': product.description,
          'price': product.price,
          'imageUrl': product.imageUrl,
          'isFavorite': product.isFavorite,
        },
      ),
    );

    final id = jsonDecode(response.body)['name'];
    _items.add(Product(
      id: id,
      name: product.name,
      description: product.description,
      imageUrl: product.imageUrl,
      price: product.price,
      isFavorite: product.isFavorite,
    ));
    notifyListeners();
  }

  Future<void> updateProduct(Product product) async {
    int index = _items.indexWhere((element) => element.id == product.id);

    if (index >= 0) {
      await http.patch(
        Uri.parse('$_baseUrl/${product.id}.json'),
        body: jsonEncode(
          {
            'name': product.name,
            'description': product.description,
            'price': product.price,
            'imageUrl': product.imageUrl,
          },
        ),
      );

      _items[index] = product;
      notifyListeners();
    }
  }

  void removeProduct(Product product) {
    int index = _items.indexWhere((element) => element.id == product.id);

    if (index >= 0) {
      _items.removeWhere((element) => element.id == product.id);
      notifyListeners();
    }
  }
}
// class ProductList with ChangeNotifier {
//   final List<Product> _items = dummyProducts;
//   bool _showFavoritesOnly = false;

//   List<Product> get items {
//     if (_showFavoritesOnly) {
//       return _items.where((element) => element.isFavorite).toList();
//     }
//     return [..._items];
//   }

//   void showFavoriteOnly() {
//     _showFavoritesOnly = true;
//     notifyListeners();
//   }

//   void showAll() {
//     _showFavoritesOnly = false;
//     notifyListeners();
//   }

//   void addProduct(Product product) {
//     _items.add(product);
//     notifyListeners();
//   }
// }
