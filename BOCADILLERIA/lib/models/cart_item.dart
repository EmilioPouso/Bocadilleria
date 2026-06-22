import 'product.dart';

class CartItem {
  final Product product;
  int quantity;
  final String customizations;
  final double customExtraPrice;

  CartItem({
    required this.product,
    this.quantity = 1,
    this.customizations = '',
    this.customExtraPrice = 0,
  });

  double get unitPrice => product.price + customExtraPrice;
  double get totalPrice => unitPrice * quantity;
}
