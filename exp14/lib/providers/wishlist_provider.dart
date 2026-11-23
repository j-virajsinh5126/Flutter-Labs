import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/product.dart';

class WishlistProvider extends ChangeNotifier {
  static const _name = 'shopease_wishlist';
  Box<bool>? _box;
  Future<void> init() async {
    _box = Hive.isBoxOpen(_name) ? Hive.box<bool>(_name) : await Hive.openBox<bool>(_name);
    notifyListeners();
  }
  Set<int> get productIds => (_box?.keys ?? const []).map((k)=>int.tryParse(k.toString())).whereType<int>().toSet();
  bool contains(Product p) => productIds.contains(p.id);
  Future<void> toggle(Product p) async {
    final b=_box; if(b==null)return; final k=p.id.toString();
    if(b.containsKey(k)){await b.delete(k);}else{await b.put(k,true);} notifyListeners();
  }
  Future<void> remove(Product p) async {await _box?.delete(p.id.toString());notifyListeners();}
  Future<void> clear() async {await _box?.clear();notifyListeners();}
}
