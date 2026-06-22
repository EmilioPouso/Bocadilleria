import 'package:flutter/material.dart';
import '../models/product.dart';
import '../models/cart_item.dart';

class CartProvider with ChangeNotifier {
  final Map<String, CartItem> _items = {};
  final List<Product> _favorites = [];

  Map<String, CartItem> get items => {..._items};

  List<Product> get favorites => [..._favorites];

  int get totalItems {
    int total = 0;
    _items.forEach((_, item) => total += item.quantity);
    return total;
  }

  double get totalPrice {
    double total = 0;
    _items.forEach((_, item) => total += item.totalPrice);
    return total;
  }

  bool get isEmpty => _items.isEmpty;

  void addProduct(Product product, {String customizations = '', double customExtraPrice = 0}) {
    final key = "${product.id}$customizations${customExtraPrice.toStringAsFixed(2)}";
    if (_items.containsKey(key)) {
      _items[key]!.quantity++;
    } else {
      _items[key] = CartItem(product: product, customizations: customizations, customExtraPrice: customExtraPrice);
    }
    notifyListeners();
  }

  void removeProduct(String key) {
    if (_items.containsKey(key)) {
      if (_items[key]!.quantity > 1) {
        _items[key]!.quantity--;
      } else {
        _items.remove(key);
      }
      notifyListeners();
    }
  }

  void deleteProduct(String key) {
    _items.remove(key);
    notifyListeners();
  }

  int getQuantity(String productId) {
    int count = 0;
    _items.forEach((key, item) {
      if (item.product.id == productId) count += item.quantity;
    });
    return count;
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }

  List<CartItem> get cartItems => _items.values.toList();

  void toggleFavorite(Product product) {
    if (_favorites.contains(product)) {
      _favorites.remove(product);
      product.isFavorite = false;
    } else {
      _favorites.add(product);
      product.isFavorite = true;
    }
    notifyListeners();
  }
}
