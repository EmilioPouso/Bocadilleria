import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import '../models/product.dart';
import '../models/order.dart';
import '../utils/default_products.dart';

class FirebaseService {
  final DatabaseReference _db = FirebaseDatabase.instance.ref();

  /// Carga los 10 bocadillos por defecto en `/products`.
  /// Sustituye toda la coleccion de productos (PUT).
  /// Devuelve true si tuvo exito, false si fallo (por ejemplo, sin permisos).
  Future<bool> seedDefaultProducts() async {
    try {
      await _db.child('products').set(DefaultProducts.asMap());
      return true;
    } catch (e) {
      debugPrint('SEED_PRODUCTS_ERROR: $e');
      return false;
    }
  }

  /// Carga los 10 bocadillos por defecto solo si en la base de datos hay
  /// menos productos que los esperados. Idempotente: si ya estan, no hace nada.
  Future<bool> seedDefaultProductsIfNeeded() async {
    try {
      final snapshot = await _db.child('products').get();
      final count = snapshot.exists && snapshot.value is Map
          ? (snapshot.value as Map).length
          : 0;
      if (count >= DefaultProducts.bocadillos.length) {
        return false;
      }
      return await seedDefaultProducts();
    } catch (e) {
      debugPrint('SEED_PRODUCTS_CHECK_ERROR: $e');
      return false;
    }
  }

  // Expose ref for one-shot reads (avoids streaming threads on Windows)
  DatabaseReference get db => _db;

  // Productos
  Stream<List<Product>> getProducts() {
    return _db.child('products').onValue.map((event) {
      final Map<dynamic, dynamic>? data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data == null) return [];
      return data.entries.map((e) => Product.fromMap(Map<String, dynamic>.from(e.value), e.key)).toList();
    });
  }

  Stream<List<Product>> getProductsByCategory(String category) {
    return _db.child('products').orderByChild('category').equalTo(category).onValue.map((event) {
      final Map<dynamic, dynamic>? data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data == null) return [];
      return data.entries.map((e) => Product.fromMap(Map<String, dynamic>.from(e.value), e.key)).toList();
    });
  }

  Future<Product?> getProduct(String id) async {
    final snapshot = await _db.child('products').child(id).get();
    if (!snapshot.exists) return null;
    return Product.fromMap(Map<String, dynamic>.from(snapshot.value as Map), snapshot.key!);
  }

  /// Precios extra por ingrediente, por id de producto (para mostrar líneas como en el carrito).
  Future<Map<String, Map<String, double>>> getIngredientExtraPricesByProductIds(Set<String> ids) async {
    final unique = ids.where((id) => id.isNotEmpty).toSet();
    if (unique.isEmpty) return {};
    final out = <String, Map<String, double>>{};
    await Future.wait(unique.map((id) async {
      final p = await getProduct(id);
      out[id] = p == null ? <String, double>{} : Map<String, double>.from(p.ingredientExtraPrices);
    }));
    return out;
  }

  // Pedidos
  Future<void> createOrder(Map<String, dynamic> orderData) async {
    await _db.child('orders').push().set(orderData);
  }

  Stream<List<Order>> getUserOrders(String userId) {
    return _db.child('orders').orderByChild('userId').equalTo(userId).onValue.map((event) {
      final Map<dynamic, dynamic>? data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data == null) return [];
      return data.entries.map((e) => Order.fromMap(Map<String, dynamic>.from(e.value), e.key)).toList();
    });
  }

  // Admin - Productos
  Future<void> addProduct(Product product) async {
    await _db.child('products').push().set(product.toMap());
  }

  Future<void> updateProduct(String id, Map<String, dynamic> data) async {
    await _db.child('products').child(id).update(data);
  }

  Future<void> deleteProduct(String id) async {
    await _db.child('products').child(id).remove();
  }

  /// Carga un catálogo por defecto en /products. Si [replaceAll] es true,
  /// borra primero los productos existentes; si es false, los conserva.
  /// Devuelve el número de productos creados.
  Future<int> seedProducts(
    List<Map<String, dynamic>> products, {
    bool replaceAll = true,
  }) async {
    final productsRef = _db.child('products');
    if (replaceAll) {
      await productsRef.remove();
    }
    var created = 0;
    for (final product in products) {
      await productsRef.push().set(product);
      created++;
    }
    return created;
  }

  // Admin - Pedidos
  Stream<List<Order>> getAllOrders() {
    return _db.child('orders').onValue.map((event) {
      final Map<dynamic, dynamic>? data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data == null) return [];
      return data.entries.map((e) => Order.fromMap(Map<String, dynamic>.from(e.value), e.key)).toList();
    });
  }

  Future<void> updateOrderStatus(String orderId, String status) async {
    await _db.child('orders').child(orderId).update({'status': status});
  }

  // Admin - Usuarios
  Stream<List<Map<String, dynamic>>> getUsers() {
    return _db.child('users').onValue.map((event) {
      final Map<dynamic, dynamic>? data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data == null) return [];
      return data.entries.map((e) => {
        'id': e.key,
        ...Map<String, dynamic>.from(e.value),
      }).toList();
    });
  }

  Future<void> updateUserRole(String userId, String role) async {
    await _db.child('users').child(userId).update({'role': role});
  }

  Future<void> deleteUser(String userId) async {
    await _db.child('users').child(userId).remove();
    // Limpieza opcional: también borramos sus favoritos
    await _db.child('favorites').child(userId).remove();
  }

  // Favoritos
  static String favoriteKey(String productId, String customizations) =>
      '${productId}_${customizations.hashCode}';

  Future<bool> toggleFavorite(
    String userId,
    String productId, {
    String customizations = '',
    double customExtraPrice = 0,
  }) async {
    try {
      final favKey = favoriteKey(productId, customizations);
      final ref = _db.child('favorites').child(userId).child(favKey);
      final snapshot = await ref.get();

      if (snapshot.exists) {
        await ref.remove();
        return false; // ya no es favorito
      } else {
        await ref.set({
          'productId': productId,
          'customizations': customizations,
          'customExtraPrice': customExtraPrice,
          'timestamp': ServerValue.timestamp,
        });
        return true; // ahora es favorito
      }
    } catch (e) {
      throw Exception('Error al actualizar favoritos: $e');
    }
  }

  Future<bool> isFavoriteSaved(
    String userId,
    String productId, {
    String customizations = '',
  }) async {
    final favKey = favoriteKey(productId, customizations);
    final snapshot = await _db.child('favorites').child(userId).child(favKey).get();
    return snapshot.exists;
  }

  Stream<bool> isFavorite(String userId, String productId, {String customizations = ''}) {
    final favKey = favoriteKey(productId, customizations);
    return _db
        .child('favorites')
        .child(userId)
        .child(favKey)
        .onValue
        .map((event) => event.snapshot.exists)
        .handleError((_) => false);
  }

  Stream<List<Map<String, dynamic>>> getFavorites(String userId) {
    return _db.child('favorites').child(userId).onValue.map((event) {
      final Map<dynamic, dynamic>? data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data == null) return [];
      return data.entries.map((e) {
        final value = Map<String, dynamic>.from(e.value);
        // Incluimos la clave para poder borrar huérfanos directamente
        value['_favKey'] = e.key.toString();
        return value;
      }).toList();
    });
  }

  /// Borra un favorito por su clave dentro de /favorites/{uid}.
  Future<void> removeFavoriteByKey(String userId, String favKey) async {
    if (favKey.isEmpty) return;
    await _db.child('favorites').child(userId).child(favKey).remove();
  }
}
