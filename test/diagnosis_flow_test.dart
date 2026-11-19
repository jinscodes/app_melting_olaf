import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:temp_alert_app/pages/diagnosis_page.dart';
import 'package:temp_alert_app/services/diagnosis_controller.dart';

void main() {
  testWidgets('small screen supports buttons and cancellation', (tester) async {
    tester.view.physicalSize = const Size(320, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final c = DiagnosisController();
    await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: DiagnosisPage(controller: c))));
    final start = find.text('데모 검사 시작');
    await tester.ensureVisible(start);
    await tester.tap(start);
    await tester.pumpAndSettle();
    final baseline = find.text('기준온도 기록 · 데모');
    await tester.ensureVisible(baseline);
    await tester.tap(baseline);
    await tester.pumpAndSettle();
    final cooling = find.text('열선 제거 · 냉각 측정 시작');
    await tester.ensureVisible(cooling);
    await tester.tap(cooling);
    await tester.pump(const Duration(seconds: 1));
    expect(c.elapsed, 18);
    final cancel = find.text('검사 취소');
    await tester.ensureVisible(cancel);
    await tester.tap(cancel);
    await tester.pump(const Duration(seconds: 3));
    expect(c.stage, DiagnosisStage.idle);
    expect(c.latestResult, isNull);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
    c.dispose();
  });
  test(
      'cancel stops collection, preserves last result, and retry resets samples',
      () async {
    final c = DiagnosisController();
    c.start();
    c.recordBaseline();
    c.startCooling();
    expect(c.historyA.length, 1);
    c.cancel();
    expect(c.stage, DiagnosisStage.idle);
    expect(c.historyA, isEmpty);
    c.start();
    expect(c.elapsed, 0);
    c.dispose();
  });

  for (final outcome in DemoOutcome.values) {
    testWidgets('demo flow: ${outcome.name}', (tester) async {
      final c = DiagnosisController()..configure(result: outcome);
      await tester.pumpWidget(
          MaterialApp(home: Scaffold(body: DiagnosisPage(controller: c))));
      expect(find.textContaining('실제 센서 기록이나 AI 분석 결과가 아닙니다'), findsOneWidget);
      c.start();
      await tester.pump();
      expect(find.text('가열 전 기준온도 기록'), findsOneWidget);
      c.recordBaseline();
      await tester.pump();
      expect(find.text('열선 제거 · 냉각 측정 시작'), findsOneWidget);
      c.startCooling();
      await tester.pump(const Duration(seconds: 10));
      expect(c.stage, DiagnosisStage.analyzing);
      expect(c.historyA.length, 181);
      expect(c.historyB.length, 181);
      await tester.pump(const Duration(seconds: 2));
      expect(
          c.stage,
          outcome == DemoOutcome.failure
              ? DiagnosisStage.failed
              : DiagnosisStage.complete);
      if (outcome != DemoOutcome.failure) {
        expect(c.latestResult!.outcome, outcome);
        final saved = c.latestResult;
        c.start();
        c.cancel();
        expect(c.latestResult, same(saved));
      } else {
        expect(c.latestResult, isNull);
      }
      await tester.pumpWidget(const SizedBox());
      c.dispose();
    });
  }
}
