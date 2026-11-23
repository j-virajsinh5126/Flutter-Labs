import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product.dart';

class ApiService {
  ApiService({http.Client? client}) : _client = client ?? http.Client();
  final http.Client _client;
  static const String _baseUrl = 'https://fakestoreapi.com';

  Future<List<Product>> fetchProducts() async {
    final response = await _client.get(Uri.parse('$_baseUrl/products')).timeout(const Duration(seconds: 20));
    if (response.statusCode != 200) throw Exception('Product service returned ${response.statusCode}.');
    final decoded = jsonDecode(response.body);
    if (decoded is! List) throw const FormatException('Unexpected product response.');
    return decoded.map((item) => Product.fromJson(Map<String, dynamic>.from(item as Map))).toList();
  }

  Future<List<String>> fetchCategories() async {
    final response = await _client.get(Uri.parse('$_baseUrl/products/categories')).timeout(const Duration(seconds: 20));
    if (response.statusCode != 200) throw Exception('Could not load categories.');
    final decoded = jsonDecode(response.body);
    if (decoded is! List) return const [];
    return decoded.map((item) => item.toString()).toList();
  }
}
