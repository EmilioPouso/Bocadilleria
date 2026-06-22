class Order {
  final String id;
  final String userId;
  final String userEmail;
  final List<OrderItem> items;
  final double totalPrice;
  final int timestamp;
  final String status;
  final String serviceType; // 'recoger_aqui' | 'domicilio'
  final String deliveryAddress;
  final String deliveryComments;

  Order({
    required this.id,
    required this.userId,
    required this.userEmail,
    required this.items,
    required this.totalPrice,
    required this.timestamp,
    this.status = 'pendiente',
    this.serviceType = 'recoger_aqui',
    this.deliveryAddress = '',
    this.deliveryComments = '',
  });

  factory Order.fromMap(Map<dynamic, dynamic> map, String id) {
    return Order(
      id: id,
      userId: map['userId'] ?? '',
      userEmail: map['userEmail'] ?? '',
      items: map['items'] != null
          ? (map['items'] as List).map((i) => OrderItem.fromMap(i)).toList()
          : [],
      totalPrice: (map['totalPrice'] ?? 0.0).toDouble(),
      timestamp: map['timestamp'] ?? 0,
      status: map['status'] ?? 'pendiente',
      serviceType: map['serviceType'] ?? 'recoger_aqui',
      deliveryAddress: map['deliveryAddress'] ?? '',
      deliveryComments: map['deliveryComments'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userEmail': userEmail,
      'items': items.map((i) => i.toMap()).toList(),
      'totalPrice': totalPrice,
      'timestamp': timestamp,
      'status': status,
      'serviceType': serviceType,
      'deliveryAddress': deliveryAddress,
      'deliveryComments': deliveryComments,
    };
  }
}

class OrderItem {
  final String productId;
  final String productName;
  final String customizations;
  final int quantity;
  final double unitPrice;

  OrderItem({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    this.customizations = '',
  });

  factory OrderItem.fromMap(Map<dynamic, dynamic> map) {
    return OrderItem(
      productId: map['productId'] ?? '',
      productName: map['productName'] ?? '',
      quantity: map['quantity'] ?? 1,
      unitPrice: (map['unitPrice'] ?? 0.0).toDouble(),
      customizations: map['customizations'] ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
    'productId': productId,
    'productName': productName,
    'customizations': customizations,
    'quantity': quantity,
    'unitPrice': unitPrice,
  };
}
