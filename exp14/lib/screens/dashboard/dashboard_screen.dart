import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/order_model.dart';
import '../../providers/order_provider.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Shopping dashboard')),
      body: StreamBuilder<List<ShopOrder>>(
        stream: context.read<OrderProvider>().watchMyOrders(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const _DashboardMessage(
              icon: Icons.error_outline,
              title: 'Dashboard unavailable',
              message: 'Unable to load your order statistics. Try again later.',
            );
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final orders = snapshot.data ?? [];
          final totalSpent =
              orders.fold<double>(0, (sum, order) => sum + order.total);
          final totalItems = orders.fold<int>(
            0,
            (sum, order) =>
                sum + order.items.fold<int>(0, (s, item) => s + item.quantity),
          );
          final average = orders.isEmpty ? 0.0 : totalSpent / orders.length;
          final statusCounts = <String, int>{};
          for (final order in orders) {
            statusCounts[order.status] = (statusCounts[order.status] ?? 0) + 1;
          }

          return RefreshIndicator(
            onRefresh: () async {
              // The Firestore stream refreshes automatically; this allows pull-to-refresh UX.
              await Future<void>.delayed(const Duration(milliseconds: 250));
            },
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  'Your shopping at a glance',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 14),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.55,
                  children: [
                    _StatCard(
                      title: 'Total orders',
                      value: '${orders.length}',
                      icon: Icons.receipt_long_outlined,
                    ),
                    _StatCard(
                      title: 'Items purchased',
                      value: '$totalItems',
                      icon: Icons.shopping_bag_outlined,
                    ),
                    _StatCard(
                      title: 'Total spending',
                      value: '\$${totalSpent.toStringAsFixed(2)}',
                      icon: Icons.payments_outlined,
                    ),
                    _StatCard(
                      title: 'Average order',
                      value: '\$${average.toStringAsFixed(2)}',
                      icon: Icons.insights_outlined,
                    ),
                  ],
                ),
                const SizedBox(height: 26),
                Text(
                  'Orders by status',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 14),
                if (statusCounts.isEmpty)
                  const _DashboardMessage(
                    icon: Icons.bar_chart,
                    title: 'No statistics yet',
                    message: 'Place your first order to see your dashboard.',
                  )
                else
                  SizedBox(
                    height: 250,
                    child: BarChart(
                      BarChartData(
                        barGroups: statusCounts.entries
                            .toList()
                            .asMap()
                            .entries
                            .map(
                              (entry) => BarChartGroupData(
                                x: entry.key,
                                barRods: [
                                  BarChartRodData(
                                    toY: entry.value.value.toDouble(),
                                    width: 30,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                ],
                              ),
                            )
                            .toList(),
                        titlesData: FlTitlesData(
                          topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                final labels = statusCounts.keys.toList();
                                final index = value.toInt();
                                if (index < 0 || index >= labels.length) {
                                  return const SizedBox.shrink();
                                }
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(
                                    labels[index],
                                    style: const TextStyle(fontSize: 10),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 18),
                Text(
                  'Recent orders',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                if (orders.isEmpty)
                  const Text('Your recent orders will appear here.')
                else
                  ...orders.take(5).map(
                        (order) => Card(
                          child: ListTile(
                            leading: const Icon(Icons.shopping_bag_outlined),
                            title: Text('Order #${order.id.substring(0, 7)}'),
                            subtitle: Text(
                              '${order.status} • ${order.items.length} product lines',
                            ),
                            trailing: Text(
                              '\$${order.total.toStringAsFixed(2)}',
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  final String title;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary),
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            Text(title, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

class _DashboardMessage extends StatelessWidget {
  const _DashboardMessage({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 42, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 8),
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(message, textAlign: TextAlign.center),
          ],
        ),
      );
}
