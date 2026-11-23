import 'package:flutter/foundation.dart';
import '../models/product.dart';
import '../services/api_service.dart';
import '../services/local_storage.dart';

enum ProductSort { recommended, priceLowHigh, priceHighLow, rating }

class ProductProvider extends ChangeNotifier {
  ProductProvider({ApiService? apiService}) : _api = apiService ?? ApiService();
  final ApiService _api;
  List<Product> _products = [];
  List<String> _categories = [];
  bool _isLoading = false;
  bool _isOfflineData = false;
  String? _error;
  String _query = '';
  String _category = 'All';
  double _minPrice = 0;
  double _maxPrice = 1000;
  double _minimumRating = 0;
  ProductSort _sort = ProductSort.recommended;

  List<Product> get products => List.unmodifiable(_products);
  List<String> get categories => ['All', ..._categories];
  bool get isLoading => _isLoading;
  bool get isOfflineData => _isOfflineData;
  String? get error => _error;
  String get query => _query;
  String get selectedCategory => _category;
  double get minPrice => _minPrice;
  double get maxPrice => _maxPrice;
  double get minimumRating => _minimumRating;
  ProductSort get sort => _sort;

  List<Product> get filteredProducts {
    final normalized = _query.trim().toLowerCase();
    final result = _products.where((p) {
      final matchesQuery = normalized.isEmpty || p.title.toLowerCase().contains(normalized) || p.description.toLowerCase().contains(normalized) || p.category.toLowerCase().contains(normalized);
      final matchesCategory = _category == 'All' || p.category == _category;
      return matchesQuery && matchesCategory && p.price >= _minPrice && p.price <= _maxPrice && p.rating >= _minimumRating;
    }).toList();
    switch (_sort) {
      case ProductSort.priceLowHigh: result.sort((a,b) => a.price.compareTo(b.price));
      case ProductSort.priceHighLow: result.sort((a,b) => b.price.compareTo(a.price));
      case ProductSort.rating: result.sort((a,b) => b.rating.compareTo(a.rating));
      case ProductSort.recommended: break;
    }
    return result;
  }

  Future<void> loadProducts({bool forceRefresh = false}) async {
    if (_isLoading) return;
    _isLoading = true; _error = null; notifyListeners();
    if (!forceRefresh && _products.isEmpty) {
      final cached = LocalStorage.readProducts();
      if (cached.isNotEmpty) { _products = cached; _isOfflineData = true; }
    }
    try {
      final fresh = await _api.fetchProducts();
      _products = fresh; _isOfflineData = false;
      await LocalStorage.saveProducts(fresh);
      try { _categories = await _api.fetchCategories(); } catch (_) { _categories = fresh.map((p) => p.category).toSet().toList()..sort(); }
    } catch (e) {
      if (_products.isNotEmpty) { _isOfflineData = true; }
      else { _error = e.toString().replaceFirst('Exception: ', ''); }
    } finally { _isLoading = false; notifyListeners(); }
  }

  void setQuery(String value) { _query = value; notifyListeners(); }
  void setCategory(String value) { _category = value; notifyListeners(); }
  void setFilters({required double minPrice, required double maxPrice, required double minimumRating, required ProductSort sort}) {
    _minPrice = minPrice; _maxPrice = maxPrice; _minimumRating = minimumRating; _sort = sort; notifyListeners();
  }
  void resetFilters() { _minPrice = 0; _maxPrice = 1000; _minimumRating = 0; _sort = ProductSort.recommended; _category = 'All'; _query = ''; notifyListeners(); }
}
