import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../models/sensor_data.dart';

class NotificationService {
  NotificationService._();

  static final instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  Future<void>? _initialization;

  Future<void> initialize() => _initialization ??= _initialize();

  Future<void> _initialize() async {
    try {
      const settings = InitializationSettings(
        android: AndroidInitializationSettings('ic_notification'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      );
      await _plugin.initialize(settings: settings);

      await _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
      await _plugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(alert: true, badge: true, sound: true);
    } catch (_) {
      // Notifications are optional on unsupported platforms and in widget tests.
    }
  }

  Future<void> showRisk(FreezeRiskLevel risk) async {
    if (risk == FreezeRiskLevel.safe) return;
    await initialize();

    final (title, body) = switch (risk) {
      FreezeRiskLevel.caution => (
          'Caution · Melting Olaf',
          'Pipe temperature is falling. Check insulation.',
        ),
      FreezeRiskLevel.warning => (
          'Warning · Melting Olaf',
          'Low temperature or rapid cooling detected. Take preventive action.',
        ),
      FreezeRiskLevel.danger => (
          'Urgent · Melting Olaf',
          'Temperature alert threshold reached. Check your pipe now.',
        ),
      FreezeRiskLevel.safe => throw StateError(
          'No notification is needed when no threshold is triggered.'),
    };

    try {
      await _plugin.show(
        id: 9001,
        title: title,
        body: body,
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'freeze_risk_alerts',
            'Temperature alerts',
            channelDescription:
                'Notifications when the pipe temperature alert level increases.',
            importance: Importance.max,
            priority: Priority.high,
            category: AndroidNotificationCategory.alarm,
            visibility: NotificationVisibility.public,
            enableVibration: true,
            playSound: true,
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
            interruptionLevel: InterruptionLevel.timeSensitive,
          ),
        ),
        payload: risk.name,
      );
    } catch (_) {
      // The in-app alert remains available if notification permission is denied.
    }
  }
}
