import 'package:cloud_firestore/cloud_firestore.dart';

class OrderItem {
  const OrderItem({
    required this.productId,
    required this.title,
    required this.image,
    required this.unitPrice,
    required this.quantity,
  });

  final int productId;
  final String title;
  final String image;
  final double unitPrice;
  final int quantity;

  double get lineTotal => unitPrice * quantity;

  Map<String, dynamic> toMap() => {
        'productId': productId,
        'title': title,
        'image': image,
        'unitPrice': unitPrice,
        'quantity': quantity,
      };

  factory OrderItem.fromMap(Map<String, dynamic> map) => OrderItem(
        productId: (map['productId'] as num).toInt(),
        title: (map['title'] ?? '').toString(),
        image: (map['image'] ?? '').toString(),
        unitPrice: (map['unitPrice'] as num).toDouble(),
        quantity: (map['quantity'] as num).toInt(),
      );
}

class ShopOrder {
  const ShopOrder({
    required this.id,
    required this.userId,
    required this.items,
    required this.address,
    required this.subtotal,
    required this.delivery,
    required this.total,
    required this.status,
    this.createdAt,
  });

  final String id;
  final String userId;
  final List<OrderItem> items;
  final String address;
  final double subtotal;
  final double delivery;
  final double total;
  final String status;
  final DateTime? createdAt;

  factory ShopOrder.fromDocument(
      DocumentSnapshot<Map<String, dynamic>> document) {
    final data = document.data() ?? {};
    final rawItems = (data['items'] as List?) ?? [];
    final timestamp = data['createdAt'];
    return ShopOrder(
      id: document.id,
      userId: (data['userId'] ?? '').toString(),
      items: rawItems
          .whereType<Map>()
          .map((item) => OrderItem.fromMap(Map<String, dynamic>.from(item)))
          .toList(),
      address: (data['address'] ?? '').toString(),
      subtotal: ((data['subtotal'] ?? 0) as num).toDouble(),
      delivery: ((data['delivery'] ?? 0) as num).toDouble(),
      total: ((data['total'] ?? 0) as num).toDouble(),
      status: (data['status'] ?? 'Placed').toString(),
      createdAt: timestamp is Timestamp ? timestamp.toDate() : null,
    );
  }
}
