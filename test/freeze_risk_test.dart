import 'package:flutter_test/flutter_test.dart';
import 'package:temp_alert_app/models/sensor_data.dart';

SensorData sensor({
  required double temperature,
  double? slope,
  double? etaMinutes,
}) {
  return SensorData(
    ok: true,
    temperature: temperature,
    slope: slope,
    etaMinutes: etaMinutes,
    danger: false,
  );
}

void main() {
  group('동파 위험 단계', () {
    test('10도 이하에서 하강 중이면 1단계 조심으로 판정한다', () {
      expect(
        sensor(temperature: 10, slope: -0.02).freezeRisk,
        FreezeRiskLevel.caution,
      );
    });

    test('10도 이하여도 하강하지 않으면 안전으로 판정한다', () {
      expect(sensor(temperature: 10).freezeRisk, FreezeRiskLevel.safe);
      expect(
        sensor(temperature: 10, slope: -0.01).freezeRisk,
        FreezeRiskLevel.safe,
      );
    });

    test('3도 이하를 2단계 주의로 판정한다', () {
      expect(sensor(temperature: 3).freezeRisk, FreezeRiskLevel.warning);
    });

    test('1도 이하를 3단계 위험으로 판정한다', () {
      expect(sensor(temperature: 1).freezeRisk, FreezeRiskLevel.danger);
    });

    test('예상 도달 시간과 급격한 하강도 단계 판정에 반영한다', () {
      expect(
        sensor(temperature: 9, etaMinutes: 50).freezeRisk,
        FreezeRiskLevel.caution,
      );
      expect(
        sensor(temperature: 7, slope: -0.1).freezeRisk,
        FreezeRiskLevel.warning,
      );
      expect(
        sensor(temperature: 4, etaMinutes: 10).freezeRisk,
        FreezeRiskLevel.danger,
      );
    });
  });
}
