import 'package:flutter_test/flutter_test.dart';
import 'package:exp14/models/product.dart';

void main() {
  group('Product model', () {
    test('parses Fake Store API JSON', () {
      final product = Product.fromJson({
        'id': 12,
        'title': 'Test product',
        'price': 19.5,
        'description': 'Sample description',
        'category': 'electronics',
        'image': 'https://example.com/image.png',
        'rating': {'rate': 4.4, 'count': 20},
      });

      expect(product.id, 12);
      expect(product.title, 'Test product');
      expect(product.price, 19.5);
      expect(product.rating, 4.4);
      expect(product.ratingCount, 20);
    });

    test('serializes and restores a product', () {
      final original = Product(
        id: 4,
        title: 'Round trip',
        price: 7.25,
        description: 'Product description',
        category: 'test',
        image: 'https://example.com/p.png',
        rating: 3.8,
        ratingCount: 8,
      );

      final restored = Product.fromJson(original.toJson());

      expect(restored.id, original.id);
      expect(restored.title, original.title);
      expect(restored.price, original.price);
      expect(restored.ratingCount, original.ratingCount);
    });
  });
}
