import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/order_model.dart';
import '../../providers/order_provider.dart';
import 'order_detail_screen.dart';

class OrderHistoryScreen extends StatelessWidget {
  const OrderHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My orders')),
      body: StreamBuilder<List<ShopOrder>>(
        stream: context.read<OrderProvider>().watchMyOrders(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const _OrderMessage(
                icon: Icons.error_outline,
                title: 'Unable to load orders',
                message: 'Check your internet connection and try again.');
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final orders = snapshot.data ?? [];
          if (orders.isEmpty) {
            return const _OrderMessage(
                icon: Icons.receipt_long_outlined,
                title: 'No orders yet',
                message: 'Orders you place will appear here.');
          }
          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: orders.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final order = orders[index];
              return Card(
                child: ListTile(
                  leading: const CircleAvatar(
                      child: Icon(Icons.shopping_bag_outlined)),
                  title: Text('Order #${order.id.substring(0, 7)}'),
                  subtitle: Text(
                    '${order.status} • ${order.items.length} product lines\n${_date(order.createdAt)}',
                  ),
                  isThreeLine: true,
                  trailing: Text('\$${order.total.toStringAsFixed(2)}',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => OrderDetailScreen(order: order),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  static String _date(DateTime? date) {
    if (date == null) return 'Date pending';
    final d = date.toLocal();
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
  }
}

class _OrderMessage extends StatelessWidget {
  const _OrderMessage(
      {required this.icon, required this.title, required this.message});
  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(icon, size: 58, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 12),
            Text(title,
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center),
          ]),
        ),
      );
}
