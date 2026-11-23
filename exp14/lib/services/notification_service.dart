
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');

    const darwin = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const settings = InitializationSettings(
      android: android,
      iOS: darwin,
    );

    await _plugin.initialize(settings: settings);

    final androidImplementation = _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    await androidImplementation?.requestNotificationsPermission();
  }

  Future<void> showOrderPlaced({
    required String orderId,
    required String total,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'shopease_orders',
      'Order updates',
      channelDescription: 'Notifications about ShopEase orders',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
    );

    await _plugin.show(
      id: orderId.hashCode,
      title: 'Order placed successfully',
      body: 'Your ShopEase order is confirmed. Total: $total',
      notificationDetails: details,
    );
  }

  Future<void> showTestNotification() async {
    const androidDetails = AndroidNotificationDetails(
      'shopease_general',
      'ShopEase notifications',
      channelDescription: 'General ShopEase notifications',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
    );

    await _plugin.show(
      id: 7001,
      title: 'ShopEase notifications are working',
      body: 'You will receive order updates here.',
      notificationDetails: details,
    );
  }
}
