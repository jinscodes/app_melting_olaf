import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:temp_alert_app/models/sensor_data.dart';
import 'package:temp_alert_app/pages/diagnosis_page.dart';
import 'package:temp_alert_app/pages/home_page.dart';
import 'package:temp_alert_app/pages/menu_page.dart';
import 'package:temp_alert_app/services/diagnosis_controller.dart';
import 'package:temp_alert_app/ui/app_design.dart';

void main() {
  const previewDir = String.fromEnvironment('UI_PREVIEW_DIR');
  setUpAll(() async {
    if (previewDir.isNotEmpty && Platform.isWindows) {
      for (final family in [
        '.SF Pro Text',
        '.SF Pro Display',
        'CupertinoSystemText',
        'CupertinoSystemDisplay',
        'Roboto',
        'sans-serif'
      ]) {
        final font = FontLoader(family)
          ..addFont(File(r'C:\Windows\Fonts\segoeui.ttf')
              .readAsBytes()
              .then((bytes) => ByteData.sublistView(bytes)));
        await font.load();
      }
      for (final entry in {
        'MaterialIcons': 'fonts/MaterialIcons-Regular.otf',
        'packages/cupertino_icons/CupertinoIcons':
            'packages/cupertino_icons/assets/CupertinoIcons.ttf',
      }.entries) {
        final font = FontLoader(entry.key)
          ..addFont(rootBundle.load(entry.value));
        await font.load();
      }
    }
  });
  for (final width in [320.0, 390.0]) {
    testWidgets('English screens fit width $width', (tester) async {
      tester.view.physicalSize = Size(width, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final controller = DiagnosisController();
      final now = DateTime.now();
      const sensor = SensorData(
          ok: true,
          temperature: 22.8,
          slope: -0.04,
          etaMinutes: null,
          danger: false);
      final snapshot =
          SensorSnapshot(sensor1: sensor, sensor2: sensor, measuredAt: now);
      final history = List.generate(
          60,
          (i) => TemperaturePoint(
              now.subtract(Duration(seconds: 59 - i)), 24.0 - i * 0.02));
      final boundaryKey = GlobalKey();
      Future<void> show(Widget page, String name) async {
        await tester.pumpWidget(MaterialApp(
          locale: const Locale('en', 'US'),
          theme: AppTheme.light,
          home: RepaintBoundary(
              key: boundaryKey,
              child: Scaffold(
                appBar: AppBar(
                    title: const Text('Melting Olaf'), centerTitle: false),
                body: SafeArea(child: page),
                bottomNavigationBar: NavigationBar(
                  selectedIndex: name == 'live-readings'
                      ? 1
                      : name == 'thermal-scan' || name.startsWith('scan-')
                          ? 2
                          : 0,
                  destinations: const [
                    NavigationDestination(
                        icon: Icon(Icons.home_outlined),
                        selectedIcon: Icon(Icons.home),
                        label: 'Home'),
                    NavigationDestination(
                        icon: Icon(Icons.menu_rounded),
                        selectedIcon: Icon(Icons.sensors_rounded),
                        label: 'Monitoring'),
                    NavigationDestination(
                        icon: Icon(Icons.analytics_outlined),
                        selectedIcon: Icon(Icons.analytics),
                        label: 'AI Scan'),
                  ],
                ),
              )),
        ));
        await tester.pump(const Duration(milliseconds: 300));
        expect(tester.takeException(), isNull, reason: name);
        final korean = RegExp(r'[\uAC00-\uD7AF]');
        for (final element in find.byType(Text).evaluate()) {
          final text = element.widget as Text;
          expect(
              korean.hasMatch(text.data ?? text.textSpan?.toPlainText() ?? ''),
              isFalse,
              reason: name);
        }
        if (previewDir.isNotEmpty && width == 390) {
          final boundary = boundaryKey.currentContext!.findRenderObject()!
              as RenderRepaintBoundary;
          await tester.runAsync(() async {
            final image = await boundary.toImage(pixelRatio: 2);
            final bytes =
                await image.toByteData(format: ui.ImageByteFormat.png);
            await Directory(previewDir).create(recursive: true);
            await File('$previewDir/$name.png')
                .writeAsBytes(bytes!.buffer.asUint8List());
            image.dispose();
          });
        }
      }

      await show(
          HomePage(
              connected: true,
              demoMode: true,
              data: snapshot,
              lastUpdated: now,
              error: null,
              onOpenMenu: () {},
              onOpenDiagnosis: () {}),
          'overview');
      for (final temperature in [9.2, 2.8, 0.8]) {
        final reading = SensorData(
            ok: true,
            temperature: temperature,
            slope: -0.04,
            etaMinutes: null,
            danger: temperature <= 1);
        final alert =
            SensorSnapshot(sensor1: reading, sensor2: sensor, measuredAt: now);
        await show(
            HomePage(
                connected: true,
                demoMode: true,
                data: alert,
                lastUpdated: now,
                error: null,
                onOpenMenu: () {},
                onOpenDiagnosis: () {}),
            'alert-level-${alert.freezeRisk.index}');
        expect(find.text(alert.freezeRisk.label), findsOneWidget);
      }
      final oldReading = SensorData(
          ok: true,
          temperature: 0.8,
          slope: -0.04,
          etaMinutes: null,
          danger: true);
      final oldSnapshot = SensorSnapshot(
          sensor1: oldReading,
          sensor2: sensor,
          measuredAt: now.subtract(const Duration(minutes: 1)));
      await show(
          HomePage(
              connected: true,
              demoMode: false,
              data: oldSnapshot,
              lastUpdated: oldSnapshot.measuredAt,
              error: null,
              onOpenMenu: () {}),
          'readings-paused');
      expect(find.text('Readings paused'), findsOneWidget);
      expect(
          tester
              .widget<Card>(
                  find.byKey(const ValueKey('temperature-status-card')))
              .color,
          isNull);
      await show(
          HomePage(
              connected: false,
              demoMode: false,
              data: oldSnapshot,
              lastUpdated: oldSnapshot.measuredAt,
              error: null,
              onOpenMenu: () {}),
          'readings-disconnected');
      expect(find.text('Connecting'), findsOneWidget);
      expect(
          tester
              .widget<Card>(
                  find.byKey(const ValueKey('temperature-status-card')))
              .color,
          isNull);
      await show(
          MenuPage(
              connected: true,
              demoMode: true,
              data: snapshot,
              error: null,
              history1: history,
              history2: history
                  .map((p) => TemperaturePoint(p.time, p.value + 0.8))
                  .toList(),
              onModeChanged: (_) {}),
          'live-readings');
      await show(DiagnosisPage(controller: controller), 'thermal-scan');
      controller.start();
      controller.recordBaseline();
      controller.startCooling();
      await tester.pump(const Duration(seconds: 5));
      expect(tester.takeException(), isNull);
      await show(DiagnosisPage(controller: controller), 'scan-in-progress');
      await tester.pump(const Duration(seconds: 7));
      expect(controller.stage, DiagnosisStage.complete);
      await show(
          ListView(padding: const EdgeInsets.all(20), children: [
            const Text('Scan result',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w600)),
            DiagnosisResultCard(result: controller.latestResult)
          ]),
          'scan-result');
      await tester.pumpWidget(const SizedBox());
      controller.dispose();
    });
  }
}
