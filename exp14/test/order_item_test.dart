import 'package:flutter_test/flutter_test.dart';
import 'package:exp14/models/order_model.dart';

void main() {
  test('OrderItem calculates line total and round-trips map data', () {
    const item = OrderItem(
      productId: 3,
      title: 'Sample',
      image: 'https://example.com/sample.png',
      unitPrice: 12.5,
      quantity: 4,
    );

    expect(item.lineTotal, 50);

    final restored = OrderItem.fromMap(item.toMap());
    expect(restored.productId, 3);
    expect(restored.quantity, 4);
    expect(restored.lineTotal, 50);
  });
}
