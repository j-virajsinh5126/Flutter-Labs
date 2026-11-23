import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/product.dart';

class CartProvider extends ChangeNotifier {
  static const _name = 'shopease_cart';
  Box<int>? _box;
  Future<void> init() async {
    _box = Hive.isBoxOpen(_name) ? Hive.box<int>(_name) : await Hive.openBox<int>(_name);
    notifyListeners();
  }
  Map<int,int> get quantities {
    final b = _box;
    if (b == null) return {};
    return {for (final k in b.keys) int.parse(k.toString()): (b.get(k) ?? 0)};
  }
  int get itemCount => quantities.values.fold(0, (a,b) => a+b);
  bool get isEmpty => quantities.isEmpty;
  int quantityFor(Product p) => quantities[p.id] ?? 0;
  Future<void> add(Product p) async {
    final b = _box; if (b == null) return;
    final k = p.id.toString(); await b.put(k, (b.get(k) ?? 0)+1); notifyListeners();
  }
  Future<void> setQuantity(Product p, int qty) async {
    final b = _box; if (b == null) return;
    final k = p.id.toString();
    if (qty <= 0) { await b.delete(k); } else { await b.put(k, qty); }
    notifyListeners();
  }
  Future<void> remove(Product p) async { await _box?.delete(p.id.toString()); notifyListeners(); }
  Future<void> clear() async { await _box?.clear(); notifyListeners(); }
  double subtotal(List<Product> products) => products.fold(0, (sum,p) => sum + p.price * (quantities[p.id] ?? 0));
}
