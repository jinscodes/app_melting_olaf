double? parseNumber(dynamic value) {
  if (value is num) {
    final result = value.toDouble();
    return result.isFinite ? result : null;
  }
  return null;
}

enum FreezeRiskLevel {
  safe,
  caution,
  warning,
  danger;

  String get label => switch (this) {
    safe => '안전',
    caution => '1단계 · 조심',
    warning => '2단계 · 주의',
    danger => '3단계 · 위험',
  };
}

class SensorData {
  final bool ok;
  final double? temperature;
  final double? slope;
  final double? etaMinutes;
  final bool danger;

  const SensorData({
    required this.ok,
    required this.temperature,
    required this.slope,
    required this.etaMinutes,
    required this.danger,
  });

  FreezeRiskLevel get freezeRisk {
    if (!ok || temperature == null) return FreezeRiskLevel.safe;

    final temp = temperature!;
    final eta = etaMinutes;
    if (temp <= 1 || (eta != null && eta <= 10)) {
      return FreezeRiskLevel.danger;
    }
    if (temp <= 3 ||
        (eta != null && eta <= 30) ||
        (temp <= 8 && slope != null && slope! <= -0.1)) {
      return FreezeRiskLevel.warning;
    }
    if ((temp <= 10 && slope != null && slope! <= -0.02) ||
        (eta != null && eta <= 60)) {
      return FreezeRiskLevel.caution;
    }
    return FreezeRiskLevel.safe;
  }
}

class SensorSnapshot {
  final SensorData sensor1;
  final SensorData sensor2;
  final int? sequence;
  final DateTime? measuredAt;

  const SensorSnapshot({
    required this.sensor1,
    required this.sensor2,
    this.sequence,
    this.measuredAt,
  });

  int get workingCount => (sensor1.ok ? 1 : 0) + (sensor2.ok ? 1 : 0);

  bool get anyDanger => freezeRisk == FreezeRiskLevel.danger;

  FreezeRiskLevel get freezeRisk =>
      sensor1.freezeRisk.index >= sensor2.freezeRisk.index
      ? sensor1.freezeRisk
      : sensor2.freezeRisk;

  bool get anySensorError => !sensor1.ok || !sensor2.ok;

  factory SensorSnapshot.fromJson(Map<String, dynamic> json) {
    final temp1 = parseNumber(json['temperature']);
    final temp2 = parseNumber(json['temperature2']);

    return SensorSnapshot(
      sensor1: SensorData(
        ok: json['sensorOk'] == true && temp1 != null,
        temperature: temp1,
        slope: parseNumber(json['slope']),
        etaMinutes: parseNumber(json['etaMinutes']),
        danger: json['danger'] == true,
      ),
      sensor2: SensorData(
        ok: json['sensor2Ok'] == true && temp2 != null,
        temperature: temp2,
        slope: parseNumber(json['slope2']),
        etaMinutes: parseNumber(json['etaMinutes2']),
        danger: json['danger2'] == true,
      ),
      sequence: json['sequence'] is num
          ? (json['sequence'] as num).toInt()
          : null,
      measuredAt: DateTime.tryParse(json['measuredAt']?.toString() ?? ''),
    );
  }
}

class TemperaturePoint {
  final DateTime time;
  final double value;

  const TemperaturePoint(this.time, this.value);
}

class TemperatureBatch {
  final SensorSnapshot latest;
  final List<TemperaturePoint> sensor1History;
  final List<TemperaturePoint> sensor2History;

  const TemperatureBatch({
    required this.latest,
    required this.sensor1History,
    required this.sensor2History,
  });
}
