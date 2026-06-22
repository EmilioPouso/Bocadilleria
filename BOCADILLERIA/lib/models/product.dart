class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final String category;
  final List<String> ingredients;
  final Map<String, double> ingredientExtraPrices;
  final bool available;
  final bool glutenFreeBread;
  bool isFavorite;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.category,
    this.ingredients = const [],
    this.ingredientExtraPrices = const {},
    this.available = true,
    this.glutenFreeBread = false,
    this.isFavorite = false,
  });

  static List<String> _ingredientsFromDynamic(dynamic raw) {
    if (raw == null) return [];
    if (raw is List) {
      return raw.map((e) => e.toString()).toList();
    }
    if (raw is Map) {
      final entries = raw.entries.toList()
        ..sort((a, b) {
          final ka = int.tryParse(a.key.toString()) ?? 0;
          final kb = int.tryParse(b.key.toString()) ?? 0;
          return ka.compareTo(kb);
        });
      return entries.map((e) => e.value.toString()).toList();
    }
    return [];
  }

  static Map<String, double> _extraPricesFromDynamic(dynamic raw) {
    if (raw is! Map) return {};
    final result = <String, double>{};
    for (final entry in raw.entries) {
      final key = entry.key.toString();
      final value = (entry.value is num)
          ? (entry.value as num).toDouble()
          : double.tryParse(entry.value.toString()) ?? 0.0;
      if (value > 0) result[key] = value;
    }
    return result;
  }

  factory Product.fromMap(Map<dynamic, dynamic> map, String id) {
    return Product(
      id: id,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      price: (map['price'] ?? 0.0).toDouble(),
      imageUrl: map['imageUrl'] ?? '',
      category: map['category'] ?? 'bocadillos',
      ingredients: _ingredientsFromDynamic(map['ingredients']),
      ingredientExtraPrices: _extraPricesFromDynamic(map['ingredientExtraPrices']),
      available: map['available'] ?? true,
      glutenFreeBread: map['glutenFreeBread'] ?? false,
      isFavorite: map['isFavorite'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'category': category,
      'ingredients': ingredients,
      'ingredientExtraPrices': ingredientExtraPrices,
      'available': available,
      'glutenFreeBread': glutenFreeBread,
      'isFavorite': isFavorite,
    };
  }
}
