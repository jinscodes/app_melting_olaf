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
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.requestNotificationsPermission();
      await _plugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >()
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
        '1단계 조심 · Melting Olaf',
        '배관 온도가 낮아지고 있어요. 보온 상태를 확인하세요.',
      ),
      FreezeRiskLevel.warning => (
        '2단계 주의 · Melting Olaf',
        '동파 가능성이 높아지고 있어요. 예방 조치를 시작하세요.',
      ),
      FreezeRiskLevel.danger => (
        '3단계 위험 · Melting Olaf',
        '동파 위험이 임박했어요. 즉시 배관을 확인하세요.',
      ),
      FreezeRiskLevel.safe => throw StateError('안전 단계에는 알림이 없습니다.'),
    };

    try {
      await _plugin.show(
        id: 9001,
        title: title,
        body: body,
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'freeze_risk_alerts',
            '동파 위험 알림',
            channelDescription: '배관의 동파 위험 단계가 올라갈 때 알려줍니다.',
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
