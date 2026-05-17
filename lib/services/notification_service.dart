import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz.initializeTimeZones();

    const AndroidInitializationSettings androidSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings =
    DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _flutterLocalNotificationsPlugin.initialize(settings);
  }

  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidDetails =
    AndroidNotificationDetails(
      'grosir_channel',
      'Notifikasi Grosir Tiga Bersaudara',
      channelDescription: 'Notifikasi untuk aplikasi Grosir Tiga Bersaudara',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const DarwinNotificationDetails iosDetails =
    DarwinNotificationDetails();

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      details,
      payload: payload,
    );
  }

  Future<void> showScheduledNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    final tz.TZDateTime scheduledTzDate =
    tz.TZDateTime.from(scheduledDate, tz.local);

    const AndroidNotificationDetails androidDetails =
    AndroidNotificationDetails(
      'grosir_scheduled_channel',
      'Notifikasi Terjadwal',
      channelDescription: 'Notifikasi terjadwal Grosir Tiga Bersaudara',
      importance: Importance.high,
      priority: Priority.high,
    );

    const DarwinNotificationDetails iosDetails =
    DarwinNotificationDetails();

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      scheduledTzDate,
      details,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
      payload: payload,
    );
  }

  Future<void> cancelNotification(int id) async {
    await _flutterLocalNotificationsPlugin.cancel(id);
  }

  Future<void> cancelAllNotifications() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
  }

  // Low Stock Notification
  Future<void> notifyLowStock(String productName, int stock) async {
    await showNotification(
      id: DateTime.now().millisecondsSinceEpoch % 100000,
      title: '⚠️ Stok Menipis',
      body: 'Stok $productName tersisa $stock kg. Segera lakukan pemesanan!',
      payload: 'low_stock',
    );
  }

  // Receivable Due Notification
  Future<void> notifyReceivableDue(String customerName, double amount, DateTime dueDate) async {
    await showNotification(
      id: DateTime.now().millisecondsSinceEpoch % 100000,
      title: '📢 Piutang Jatuh Tempo',
      body: 'Piutang $customerName sebesar Rp ${_formatAmount(amount)} akan jatuh tempo pada ${_formatDate(dueDate)}',
      payload: 'receivable_due',
    );
  }

  // Transaction Success Notification
  Future<void> notifyTransactionSuccess(String invoiceNumber, double total) async {
    await showNotification(
      id: DateTime.now().millisecondsSinceEpoch % 100000,
      title: '✅ Transaksi Berhasil',
      body: 'Transaksi $invoiceNumber senilai Rp ${_formatAmount(total)} berhasil',
      payload: 'transaction_success',
    );
  }

  String _formatAmount(double amount) {
    return amount.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}