import 'dart:math' as math;

import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/sensor_data.dart';

class TemperatureService {
  TemperatureService({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  int _demoStep = 0;

  void resetDemo() {
    _demoStep = 0;
  }

  Future<TemperatureBatch> fetchLatestData() async {
    final rows = await _client
        .from('temperature_readings')
        .select('id, sensor1, sensor2, measured_at')
        .order('measured_at', ascending: false)
        .limit(60)
        .timeout(const Duration(seconds: 5));

    if (rows.isEmpty) {
      throw StateError('No temperature readings are available yet.');
    }

    final latest = rows.first;
    final latestAt = DateTime.tryParse(latest['measured_at']?.toString() ?? '');

    double? slopeFor(String key) {
      final newest = parseNumber(latest[key]);
      final oldestRow = rows.last;
      final oldest = parseNumber(oldestRow[key]);
      final oldestAt = DateTime.tryParse(
        oldestRow['measured_at']?.toString() ?? '',
      );
      if (newest == null ||
          oldest == null ||
          latestAt == null ||
          oldestAt == null) {
        return null;
      }
      final minutes = latestAt.difference(oldestAt).inMilliseconds / 60000;
      return minutes > 0 ? (newest - oldest) / minutes : null;
    }

    SensorData sensor(String key) {
      final temperature = parseNumber(latest[key]);
      final slope = slopeFor(key);
      final eta =
          temperature != null && slope != null && slope < 0 && temperature > 2
          ? (temperature - 2) / -slope
          : null;
      final danger =
          temperature != null &&
          (temperature <= 1 || (eta != null && eta <= 10));
      return SensorData(
        ok: temperature != null,
        temperature: temperature,
        slope: slope,
        etaMinutes: eta,
        danger: danger,
      );
    }

    final snapshot = SensorSnapshot(
      sensor1: sensor('sensor1'),
      sensor2: sensor('sensor2'),
      sequence: (latest['id'] as num?)?.toInt(),
      measuredAt: latestAt,
    );

    final sensor1History = <TemperaturePoint>[];
    final sensor2History = <TemperaturePoint>[];
    for (final row in rows.reversed) {
      final time = DateTime.tryParse(row['measured_at']?.toString() ?? '');
      if (time == null) continue;
      final sensor1 = parseNumber(row['sensor1']);
      final sensor2 = parseNumber(row['sensor2']);
      if (sensor1 != null) sensor1History.add(TemperaturePoint(time, sensor1));
      if (sensor2 != null) sensor2History.add(TemperaturePoint(time, sensor2));
    }

    return TemperatureBatch(
      latest: snapshot,
      sensor1History: sensor1History,
      sensor2History: sensor2History,
    );
  }

  // Simulated data for UI testing
  SensorSnapshot createDemoData(DemoRiskScenario scenario) {
    final step = _demoStep++;

    // Presentation mode: begin safely, then reach the selected alert level in
    // about 12 seconds. Values still pass through the production risk rules.
    final progress = math.min(1.0, step / 12);
    final (target1, target2, targetSlope) = switch (scenario) {
      DemoRiskScenario.level1 => (9.8, 10.4, -0.03),
      DemoRiskScenario.level2 => (2.8, 3.4, -0.05),
      DemoRiskScenario.level3 => (0.8, 1.4, -0.12),
    };
    final temp1 = 13.0 + (target1 - 13.0) * progress;
    final temp2 = 14.0 + (target2 - 14.0) * progress;
    final double? slope1 = step < 2 ? null : targetSlope;
    final double? slope2 = step < 2 ? null : targetSlope * 0.9;

    // The demo uses temperature/slope thresholds so ETA does not jump ahead
    // to a more severe level before the selected scenario reaches its target.
    const double? eta1 = null;
    const double? eta2 = null;

    final danger1 = temp1 <= 1 || (eta1 != null && eta1 <= 10);

    final danger2 = temp2 <= 1 || (eta2 != null && eta2 <= 10);

    return SensorSnapshot(
      sensor1: SensorData(
        ok: true,
        temperature: temp1,
        slope: slope1,
        etaMinutes: eta1,
        danger: danger1,
      ),
      sensor2: SensorData(
        ok: true,
        temperature: temp2,
        slope: slope2,
        etaMinutes: eta2,
        danger: danger2,
      ),
      sequence: step,
      measuredAt: DateTime.now(),
    );
  }
}
