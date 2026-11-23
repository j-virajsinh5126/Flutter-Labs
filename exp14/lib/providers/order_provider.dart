import 'package:flutter/foundation.dart';

import '../models/order_model.dart';
import '../models/product.dart';
import '../services/order_service.dart';

class OrderProvider extends ChangeNotifier {
  OrderProvider({OrderService? service})
      : _service = service ?? OrderService();

  final OrderService _service;
  bool _isPlacingOrder = false;
  String? _error;

  bool get isPlacingOrder => _isPlacingOrder;
  String? get error => _error;

  Stream<List<ShopOrder>> watchMyOrders() => _service.watchMyOrders();

  Future<ShopOrder?> placeOrder({
    required List<Product> products,
    required Map<int, int> quantities,
    required String address,
    required double delivery,
  }) async {
    _isPlacingOrder = true;
    _error = null;
    notifyListeners();
    try {
      return await _service.placeOrder(
        products: products,
        quantities: quantities,
        address: address,
        delivery: delivery,
      );
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      return null;
    } finally {
      _isPlacingOrder = false;
      notifyListeners();
    }
  }

  Future<ShopOrder?> getOrder(String orderId) async {
    try {
      return await _service.getOrder(orderId);
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return null;
    }
  }
}
