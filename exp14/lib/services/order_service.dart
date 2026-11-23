import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/order_model.dart';
import '../models/product.dart';

class OrderService {
  OrderService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  CollectionReference<Map<String, dynamic>> get _orders =>
      _firestore.collection('orders');

  Stream<List<ShopOrder>> watchMyOrders() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value(const []);
    return _orders
        .where('userId', isEqualTo: user.uid)
        .snapshots()
        .map((snapshot) {
      final result = snapshot.docs
          .map(ShopOrder.fromDocument)
          .toList()
        ..sort((a, b) =>
            (b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0))
                .compareTo(a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0)));
      return result;
    });
  }

  Future<ShopOrder> placeOrder({
    required List<Product> products,
    required Map<int, int> quantities,
    required String address,
    required double delivery,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Please sign in again.');
    final items = products
        .where((product) => (quantities[product.id] ?? 0) > 0)
        .map((product) => OrderItem(
              productId: product.id,
              title: product.title,
              image: product.image,
              unitPrice: product.price,
              quantity: quantities[product.id]!,
            ))
        .toList();
    if (items.isEmpty) throw Exception('Your cart is empty.');

    final subtotal = items.fold<double>(
        0, (sum, item) => sum + item.lineTotal);
    final doc = _orders.doc();
    final data = {
      'userId': user.uid,
      'items': items.map((item) => item.toMap()).toList(),
      'address': address.trim(),
      'subtotal': subtotal,
      'delivery': delivery,
      'total': subtotal + delivery,
      'status': 'Placed',
      'createdAt': FieldValue.serverTimestamp(),
    };

    await doc.set(data);
    return ShopOrder(
      id: doc.id,
      userId: user.uid,
      items: items,
      address: address.trim(),
      subtotal: subtotal,
      delivery: delivery,
      total: subtotal + delivery,
      status: 'Placed',
      createdAt: DateTime.now(),
    );
  }

  Future<ShopOrder?> getOrder(String orderId) async {
    final user = _auth.currentUser;
    if (user == null) return null;
    final snapshot = await _orders.doc(orderId).get();
    if (!snapshot.exists) return null;
    final order = ShopOrder.fromDocument(snapshot);
    if (order.userId != user.uid) return null;
    return order;
  }
}
