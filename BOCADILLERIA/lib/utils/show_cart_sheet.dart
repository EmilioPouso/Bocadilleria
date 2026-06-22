import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/cart_provider.dart';
import '../screens/cart_screen.dart';
import '../services/firebase_service.dart';

void showCartSheet(BuildContext context) {
  final cart = Provider.of<CartProvider>(context, listen: false);
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => CartScreen(
      onOrder: (serviceType, {address, comments, deliveryFee = 0}) async {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        if (!authProvider.isLoggedIn) return;
        final firebaseService = FirebaseService();
        final orderData = {
          'userId': authProvider.user!.uid,
          'userEmail': authProvider.user!.email,
          'items': cart.cartItems.map((item) => {
                'productId': item.product.id,
                'productName': item.product.name,
                'quantity': item.quantity,
                'unitPrice': item.unitPrice,
                'customizations': item.customizations,
              }).toList(),
          'totalPrice': cart.totalPrice + deliveryFee,
          'deliveryFee': deliveryFee,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
          'status': 'pendiente',
          'serviceType': serviceType,
          'deliveryAddress': address ?? '',
          'deliveryComments': comments ?? '',
        };
        await firebaseService.createOrder(orderData);
        cart.clear();
        if (context.mounted) Navigator.pop(context);
      },
    ),
  );
}
