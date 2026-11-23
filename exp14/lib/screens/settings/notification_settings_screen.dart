import 'package:flutter/material.dart';

import '../../services/notification_service.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  bool _sending = false;

  Future<void> _sendTest() async {
    setState(() => _sending = true);
    try {
      await NotificationService.instance.showTestNotification();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Test notification sent.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Notification failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          const ListTile(
            leading: Icon(Icons.notifications_active_outlined),
            title: Text('Order notifications'),
            subtitle: Text(
              'ShopEase can show a local notification after you place an order.',
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _sending ? null : _sendTest,
            icon: const Icon(Icons.notifications),
            label: Text(_sending ? 'Sending...' : 'Send test notification'),
          ),
          const SizedBox(height: 12),
          const Text(
            'If no notification appears, check that notifications are allowed '
            'for ShopEase in your Android app settings.',
          ),
        ],
      ),
    );
  }
}
