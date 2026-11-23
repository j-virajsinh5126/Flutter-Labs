import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/product.dart';

class LocalStorage {
  LocalStorage._();
  static const String _boxName = 'shopease_cache';
  static const String _productsKey = 'products_json';
  static Future<void> init() async { await Hive.initFlutter(); await Hive.openBox<String>(_boxName); }
  static Box<String> get _box => Hive.box<String>(_boxName);

  static Future<void> saveProducts(List<Product> products) async {
    final payload = jsonEncode(products.map((product) => product.toJson()).toList());
    await _box.put(_productsKey, payload);
  }

  static List<Product> readProducts() {
    final raw = _box.get(_productsKey);
    if (raw == null || raw.isEmpty) return const [];
    try {
      final decoded = jsonDecode(raw) as List;
      return decoded.map((item) => Product.fromJson(Map<String, dynamic>.from(item as Map))).toList();
    } catch (_) { return const []; }
  }
}
