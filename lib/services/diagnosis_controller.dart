import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';

import '../models/sensor_data.dart';

enum DiagnosisStage {
  idle,
  baseline,
  heating,
  cooling,
  analyzing,
  complete,
  failed
}

enum DemoOutcome { sensorA, sensorB, indeterminate, failure }

class DiagnosisResult {
  const DiagnosisResult({required this.completedAt, required this.outcome});
  final DateTime completedAt;
  final DemoOutcome outcome;
  String get title => switch (outcome) {
        DemoOutcome.sensorA => 'Sensor A is relatively more vulnerable',
        DemoOutcome.sensorB => 'Sensor B is relatively more vulnerable',
        DemoOutcome.indeterminate => 'No clear difference',
        DemoOutcome.failure => 'Analysis could not be completed',
      };
  double get scoreA => outcome == DemoOutcome.sensorA
      ? 0.81
      : outcome == DemoOutcome.indeterminate
          ? 0.58
          : 0.32;
  double get scoreB => outcome == DemoOutcome.sensorA
      ? 0.32
      : outcome == DemoOutcome.indeterminate
          ? 0.62
          : 0.81;
}

/// UI-only preview. Does not read sensors, submit an experiment, or run a model.
/// Replace this controller's demo operations with the team's session/inference API.
class DiagnosisController extends ChangeNotifier {
  DiagnosisStage stage = DiagnosisStage.idle;
  DemoOutcome outcome = DemoOutcome.sensorB;
  bool fastPreview = true;
  int elapsed = 0;
  DiagnosisResult? latestResult;
  DateTime? startedAt;
  Timer? _timer;
  final List<TemperaturePoint> historyA = [];
  final List<TemperaturePoint> historyB = [];

  bool get active =>
      stage == DiagnosisStage.baseline ||
      stage == DiagnosisStage.heating ||
      stage == DiagnosisStage.cooling ||
      stage == DiagnosisStage.analyzing;
  void configure({DemoOutcome? result, bool? fast}) {
    if (active) return;
    outcome = result ?? outcome;
    fastPreview = fast ?? fastPreview;
    notifyListeners();
  }

  void start() {
    _timer?.cancel();
    elapsed = 0;
    historyA.clear();
    historyB.clear();
    stage = DiagnosisStage.baseline;
    notifyListeners();
  }

  void recordBaseline() {
    if (stage != DiagnosisStage.baseline) return;
    stage = DiagnosisStage.heating;
    notifyListeners();
  }

  void startCooling() {
    if (stage != DiagnosisStage.heating) return;
    stage = DiagnosisStage.cooling;
    startedAt = DateTime.now();
    _append(0);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      final next = math.min(180, elapsed + (fastPreview ? 18 : 1));
      for (var t = elapsed + 1; t <= next; t++) {
        _append(t);
      }
      elapsed = next;
      if (elapsed == 180) {
        _timer?.cancel();
        stage = DiagnosisStage.analyzing;
        _timer = Timer(const Duration(seconds: 2), () {
          if (outcome == DemoOutcome.failure) {
            stage = DiagnosisStage.failed;
          } else {
            latestResult =
                DiagnosisResult(completedAt: DateTime.now(), outcome: outcome);
            stage = DiagnosisStage.complete;
          }
          notifyListeners();
        });
      }
      notifyListeners();
    });
    notifyListeners();
  }

  void _append(int second) {
    final time = startedAt!.add(Duration(seconds: second));
    final aRate = outcome == DemoOutcome.sensorA ? 0.009 : 0.003;
    final bRate = outcome == DemoOutcome.indeterminate
        ? 0.0033
        : outcome == DemoOutcome.sensorA
            ? 0.003
            : 0.009;
    historyA.add(TemperaturePoint(time, 20 + 15 * math.exp(-aRate * second)));
    historyB.add(TemperaturePoint(time, 20 + 15 * math.exp(-bRate * second)));
  }

  void cancel() {
    _timer?.cancel();
    stage = DiagnosisStage.idle;
    elapsed = 0;
    historyA.clear();
    historyB.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
