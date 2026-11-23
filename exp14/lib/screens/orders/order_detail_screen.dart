import 'package:flutter/material.dart';

import '../../models/order_model.dart';

class OrderDetailScreen extends StatelessWidget {
  const OrderDetailScreen({super.key, required this.order});
  final ShopOrder order;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Order details')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Order #${order.id}',
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    Row(children: [
                      const Text('Status'),
                      const Spacer(),
                      Chip(label: Text(order.status)),
                    ]),
                    Text('Placed: ${_date(order.createdAt)}'),
                  ]),
            ),
          ),
          const SizedBox(height: 12),
          Text('Items', style: Theme.of(context).textTheme.titleLarge),
          ...order.items.map((item) => Card(
                child: ListTile(
                  leading: SizedBox(
                    width: 48,
                    height: 48,
                    child: Image.network(item.image,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) =>
                            const Icon(Icons.image_not_supported)),
                  ),
                  title: Text(item.title),
                  subtitle: Text(
                      '${item.quantity} × \$${item.unitPrice.toStringAsFixed(2)}'),
                  trailing: Text('\$${item.lineTotal.toStringAsFixed(2)}'),
                ),
              )),
          const SizedBox(height: 12),
          Text('Delivery address',
              style: Theme.of(context).textTheme.titleLarge),
          Card(
              child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(order.address))),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(children: [
                _row('Subtotal', order.subtotal),
                _row('Delivery', order.delivery),
                const Divider(height: 24),
                _row('Total', order.total, bold: true),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  String _date(DateTime? date) {
    if (date == null) return 'Processing';
    final d = date.toLocal();
    return '${d.day}/${d.month}/${d.year} ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  }

  Widget _row(String label, double value, {bool bold = false}) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(children: [
          Text(label,
              style: TextStyle(
                  fontWeight: bold ? FontWeight.bold : FontWeight.normal)),
          const Spacer(),
          Text('\$${value.toStringAsFixed(2)}',
              style: TextStyle(
                  fontWeight: bold ? FontWeight.bold : FontWeight.normal,
                  fontSize: bold ? 18 : 14)),
        ]),
      );
}
