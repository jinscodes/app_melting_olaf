import 'dart:async';

import 'package:flutter/material.dart';

import 'models/sensor_data.dart';
import 'services/temperature_service.dart';
import 'services/notification_service.dart';
import 'pages/home_page.dart';
import 'pages/menu_page.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  final TemperatureService service = TemperatureService();
  final NotificationService notifications = NotificationService.instance;

  int selectedTab = 0;
  int modeVersion = 0;
  int? lastSequence;

  bool demoMode = false;
  bool connected = false;
  bool loading = false;
  FreezeRiskLevel notifiedRisk = FreezeRiskLevel.safe;

  String? error;
  SensorSnapshot? latest;
  DateTime? lastUpdated;

  Timer? timer;

  final List<TemperaturePoint> history1 = [];
  final List<TemperaturePoint> history2 = [];

  @override
  void initState() {
    super.initState();

    unawaited(notifications.initialize());
    loadData();

    timer = Timer.periodic(const Duration(seconds: 1), (_) => loadData());
  }

  Future<void> loadData() async {
    if (loading) return;

    loading = true;
    final currentVersion = modeVersion;

    try {
      final TemperatureBatch? batch = demoMode
          ? null
          : await service.fetchLatestData();
      final SensorSnapshot data = demoMode
          ? service.createDemoData()
          : batch!.latest;

      if (!mounted || currentVersion != modeVersion) {
        return;
      }

      final now = DateTime.now();

      setState(() {
        connected = true;
        error = null;
        latest = data;

        final isNew = data.sequence == null || data.sequence != lastSequence;

        if (!demoMode && batch != null) {
          history1
            ..clear()
            ..addAll(batch.sensor1History);
          history2
            ..clear()
            ..addAll(batch.sensor2History);
        } else if (isNew) {
          lastSequence = data.sequence;
          lastUpdated = data.measuredAt ?? now;

          if (data.sensor1.ok && data.sensor1.temperature != null) {
            history1.add(
              TemperaturePoint(
                data.measuredAt ?? now,
                data.sensor1.temperature!,
              ),
            );
          }

          if (data.sensor2.ok && data.sensor2.temperature != null) {
            history2.add(
              TemperaturePoint(
                data.measuredAt ?? now,
                data.sensor2.temperature!,
              ),
            );
          }
        }

        // Keep only 60 seconds of readings
        if (demoMode) {
          history1.removeWhere(
            (point) => now.difference(point.time) > const Duration(seconds: 60),
          );
          history2.removeWhere(
            (point) => now.difference(point.time) > const Duration(seconds: 60),
          );
        }
      });

      final risk = data.freezeRisk;
      if (risk.index > notifiedRisk.index) {
        notifiedRisk = risk;
        _showRiskAlarm(risk);
      } else if (risk.index < notifiedRisk.index) {
        notifiedRisk = risk;
      }
    } catch (e) {
      if (!mounted || currentVersion != modeVersion) {
        return;
      }

      setState(() {
        connected = false;
        error = e.toString();
      });
    } finally {
      loading = false;
    }
  }

  void _showRiskAlarm(FreezeRiskLevel risk) {
    if (risk == FreezeRiskLevel.safe) return;
    unawaited(notifications.showRisk(risk));
    final (message, color, icon) = switch (risk) {
      FreezeRiskLevel.caution => (
        '1단계 조심: 배관 온도가 낮아지고 있어요. 보온 상태를 확인하세요.',
        const Color(0xFFF2A900),
        Icons.info_outline,
      ),
      FreezeRiskLevel.warning => (
        '2단계 주의: 동파 가능성이 높아지고 있어요. 예방 조치를 시작하세요.',
        const Color(0xFFE66A00),
        Icons.warning_amber_rounded,
      ),
      FreezeRiskLevel.danger => (
        '3단계 위험: 동파 위험이 임박했어요. 즉시 배관을 확인하세요.',
        const Color(0xFFC62828),
        Icons.crisis_alert,
      ),
      FreezeRiskLevel.safe => throw StateError('안전 단계에는 알람이 없습니다.'),
    };
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(icon, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(child: Text(message)),
            ],
          ),
          backgroundColor: color,
          duration: const Duration(seconds: 6),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  void changeMode(bool value) {
    setState(() {
      modeVersion++;
      demoMode = value;

      connected = false;
      error = null;
      latest = null;
      lastUpdated = null;
      lastSequence = null;
      notifiedRisk = FreezeRiskLevel.safe;

      history1.clear();
      history2.clear();

      service.resetDemo();
    });

    loadData();
  }

  void openMenu() {
    setState(() {
      selectedTab = 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Melting Olaf',
          style: TextStyle(fontWeight: FontWeight.w600, letterSpacing: -0.2),
        ),
        centerTitle: false,
      ),

      body: SafeArea(
        child: IndexedStack(
          index: selectedTab,
          children: [
            HomePage(
              connected: connected,
              demoMode: demoMode,
              data: latest,
              lastUpdated: lastUpdated,
              error: error,
              onOpenMenu: openMenu,
            ),

            MenuPage(
              connected: connected,
              demoMode: demoMode,
              data: latest,
              error: error,
              history1: history1,
              history2: history2,
              onModeChanged: changeMode,
            ),
          ],
        ),
      ),

      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedTab,
        onDestinationSelected: (index) {
          setState(() {
            selectedTab = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: '홈',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_rounded),
            selectedIcon: Icon(Icons.sensors_rounded),
            label: '모니터링',
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }
}
