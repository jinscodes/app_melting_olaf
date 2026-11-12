import 'package:flutter/material.dart';

import '../models/sensor_data.dart';

class HomePage extends StatelessWidget {
  const HomePage({
    super.key,
    required this.connected,
    required this.demoMode,
    required this.data,
    required this.lastUpdated,
    required this.error,
    required this.onOpenMenu,
  });

  final bool connected;
  final bool demoMode;
  final SensorSnapshot? data;
  final DateTime? lastUpdated;
  final String? error;
  final VoidCallback onOpenMenu;

  String _time(DateTime? value) {
    if (value == null) return '기록 없음';
    String two(int number) => number.toString().padLeft(2, '0');
    return '${two(value.hour)}:${two(value.minute)}:${two(value.second)}';
  }

  @override
  Widget build(BuildContext context) {
    final risk = connected
        ? data?.freezeRisk ?? FreezeRiskLevel.safe
        : FreezeRiskLevel.safe;
    final sensorError = connected && (data?.anySensorError ?? false);
    final title = !connected
        ? '연결 확인 중'
        : risk != FreezeRiskLevel.safe
        ? risk.label
        : sensorError
        ? '센서를 확인하세요'
        : '현재 안전해요';
    final description = !connected
        ? 'Supabase에서 최근 측정값을 불러오고 있습니다.'
        : risk == FreezeRiskLevel.danger
        ? '동파 위험이 임박했습니다. 즉시 배관을 확인하세요.'
        : risk == FreezeRiskLevel.warning
        ? '동파 가능성이 높아지고 있습니다. 예방 조치를 시작하세요.'
        : risk == FreezeRiskLevel.caution
        ? '배관 온도가 낮아지고 있습니다. 보온 상태를 확인하세요.'
        : sensorError
        ? '일부 센서의 값이 비어 있습니다.'
        : '동파 위험 신호가 감지되지 않았습니다.';
    final accent = risk == FreezeRiskLevel.danger
        ? const Color(0xFFC62828)
        : risk == FreezeRiskLevel.warning
        ? const Color(0xFFE66A00)
        : risk == FreezeRiskLevel.caution
        ? const Color(0xFFF2A900)
        : sensorError
        ? const Color(0xFF746A52)
        : const Color(0xFF586159);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
      children: [
        Text(
          '배관 상태',
          style: Theme.of(context).textTheme.headlineMedium
              ?.copyWith(fontWeight: FontWeight.w600, letterSpacing: -1),
        ),
        const SizedBox(height: 8),
        Text(
          '마지막 측정 ${_time(lastUpdated)}',
          style: const TextStyle(color: Color(0xFF777872)),
        ),
        const SizedBox(height: 28),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: accent,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.8,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: const TextStyle(color: Color(0xFF696A65), height: 1.5),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Column(
              children: [
                _InfoRow(label: '데이터', value: connected ? '연결됨' : '연결 안 됨'),
                const Divider(height: 1),
                _InfoRow(
                  label: '센서',
                  value: '${connected ? data?.workingCount ?? 0 : 0} / 2',
                ),
                const Divider(height: 1),
                _InfoRow(label: '소스', value: demoMode ? '데모 데이터' : 'Supabase'),
              ],
            ),
          ),
        ),
        if (error != null) ...[
          const SizedBox(height: 14),
          Text(
            error!,
            style: const TextStyle(color: Color(0xFF76554D), fontSize: 12),
          ),
        ],
        const SizedBox(height: 24),
        OutlinedButton(
          onPressed: onOpenMenu,
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF30312E),
            side: const BorderSide(color: Color(0xFFCECEC7)),
            padding: const EdgeInsets.symmetric(vertical: 17),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: const Text('측정값 자세히 보기'),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 15),
    child: Row(
      children: [
        Expanded(
          child: Text(label, style: const TextStyle(color: Color(0xFF777872))),
        ),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
      ],
    ),
  );
}
