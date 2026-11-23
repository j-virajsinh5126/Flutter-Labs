import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/cart_provider.dart';
import '../../providers/order_provider.dart';
import '../../providers/product_provider.dart';
import 'order_history_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _address = TextEditingController();
  final _city = TextEditingController();
  final _postalCode = TextEditingController();
  String _paymentMethod = 'Cash on delivery';

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _address.dispose();
    _city.dispose();
    _postalCode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final products = context.watch<ProductProvider>().products;
    final items =
        products.where((p) => cart.quantities.containsKey(p.id)).toList();
    final subtotal = cart.subtotal(items);
    final delivery = items.isEmpty || subtotal >= 50 ? 0.0 : 4.99;
    final orderProvider = context.watch<OrderProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: items.isEmpty
          ? const Center(child: Text('Your cart is empty.'))
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Text('Delivery details',
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 14),
                  _field(_name, 'Full name',
                      validator: (v) => _required(v, 'Enter your name')),
                  const SizedBox(height: 12),
                  _field(_phone, 'Phone number',
                      keyboardType: TextInputType.phone,
                      validator: (v) => v == null ||
                              v.trim().replaceAll(RegExp(r'\D'), '').length < 10
                          ? 'Enter a valid phone number'
                          : null),
                  const SizedBox(height: 12),
                  _field(_address, 'House / street / area',
                      maxLines: 2,
                      validator: (v) => _required(v, 'Enter your address')),
                  const SizedBox(height: 12),
                  _field(_city, 'City',
                      validator: (v) => _required(v, 'Enter your city')),
                  const SizedBox(height: 12),
                  _field(_postalCode, 'Postal / PIN code',
                      keyboardType: TextInputType.number,
                      validator: (v) => v == null ||
                              !RegExp(r'^\d{5,6}$').hasMatch(v.trim())
                          ? 'Enter a valid postal / PIN code'
                          : null),
                  const SizedBox(height: 24),
                  Text('Payment method',
                      style: Theme.of(context).textTheme.titleLarge),
                  RadioListTile<String>(
                    value: 'Cash on delivery',
                    groupValue: _paymentMethod,
                    onChanged: (v) =>
                        setState(() => _paymentMethod = v ?? _paymentMethod),
                    title: const Text('Cash on delivery'),
                    subtitle: const Text('Demo checkout option'),
                  ),
                  RadioListTile<String>(
                    value: 'Demo card payment',
                    groupValue: _paymentMethod,
                    onChanged: (v) =>
                        setState(() => _paymentMethod = v ?? _paymentMethod),
                    title: const Text('Demo card payment'),
                    subtitle: const Text('No real payment is processed'),
                  ),
                  const SizedBox(height: 12),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(children: [
                        _summary('Subtotal', subtotal),
                        _summary('Delivery', delivery),
                        const Divider(height: 24),
                        _summary('Total', subtotal + delivery, bold: true),
                      ]),
                    ),
                  ),
                  const SizedBox(height: 18),
                  FilledButton(
                    onPressed: orderProvider.isPlacingOrder
                        ? null
                        : () => _submit(items, cart.quantities, delivery),
                    child: orderProvider.isPlacingOrder
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2))
                        : const Text('Place order'),
                  ),
                  if (orderProvider.error != null) ...[
                    const SizedBox(height: 10),
                    Text(orderProvider.error!,
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.error)),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _field(
    TextEditingController controller,
    String label, {
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) =>
      TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(labelText: label),
        validator: validator,
      );

  String? _required(String? value, String message) =>
      value == null || value.trim().isEmpty ? message : null;

  Widget _summary(String label, double value, {bool bold = false}) => Padding(
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

  Future<void> _submit(
      List<dynamic> items, Map<int, int> quantities, double delivery) async {
    if (!_formKey.currentState!.validate()) return;
    final fullAddress =
        '${_name.text.trim()} | ${_phone.text.trim()} | ${_address.text.trim()}, ${_city.text.trim()} - ${_postalCode.text.trim()} | Payment: $_paymentMethod';

    final order = await context.read<OrderProvider>().placeOrder(
          products: items.cast(),
          quantities: quantities,
          address: fullAddress,
          delivery: delivery,
        );
    if (!mounted) return;
    if (order == null) return;

    // Clear the local cart only after Firestore confirms the order write.
    await context.read<CartProvider>().clear();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Order placed successfully.')),
    );
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const OrderHistoryScreen()),
      (route) => route.isFirst,
    );
  }
}
