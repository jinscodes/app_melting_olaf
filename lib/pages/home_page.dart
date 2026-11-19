import 'package:flutter/material.dart';

import '../models/sensor_data.dart';
import '../services/diagnosis_controller.dart';
import 'diagnosis_page.dart';
import '../ui/app_design.dart';

class HomePage extends StatelessWidget {
  const HomePage({
    super.key,
    required this.connected,
    required this.demoMode,
    required this.data,
    required this.lastUpdated,
    required this.error,
    required this.onOpenMenu,
    this.diagnosisResult,
    this.onOpenDiagnosis,
  });

  final bool connected;
  final bool demoMode;
  final SensorSnapshot? data;
  final DateTime? lastUpdated;
  final String? error;
  final VoidCallback onOpenMenu;
  final DiagnosisResult? diagnosisResult;
  final VoidCallback? onOpenDiagnosis;

  @override
  Widget build(BuildContext context) {
    final risk = connected
        ? data?.freezeRisk ?? FreezeRiskLevel.safe
        : FreezeRiskLevel.safe;
    final sensorError = connected && (data?.anySensorError ?? false);
    final stale = connected &&
        !demoMode &&
        (lastUpdated == null ||
            DateTime.now().difference(lastUpdated!) >
                const Duration(seconds: 15));
    final title = stale
        ? 'Readings paused'
        : !connected
            ? 'Connecting'
            : risk != FreezeRiskLevel.safe
                ? risk.label
                : sensorError
                    ? 'Check your sensors'
                    : 'No low-temperature alerts';
    final description = stale
        ? 'The latest reading is more than 15 seconds old. Current conditions are unknown.'
        : !connected
            ? 'Loading the latest temperature readings.'
            : risk == FreezeRiskLevel.danger
                ? 'Temperature alert threshold reached. Check your pipe now.'
                : risk == FreezeRiskLevel.warning
                    ? 'Low temperature or rapid cooling detected. Take preventive action.'
                    : risk == FreezeRiskLevel.caution
                        ? 'Pipe temperature is falling. Check insulation.'
                        : sensorError
                            ? 'Some sensors are not reporting a valid temperature.'
                            : 'No temperature alert threshold has been triggered.';
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
          'Pipe status',
          style: Theme.of(context)
              .textTheme
              .headlineMedium
              ?.copyWith(fontWeight: FontWeight.w600, letterSpacing: -1),
        ),
        const SizedBox(height: 8),
        Text(
          'Last reading ${displayTime(context, lastUpdated)}',
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
                _InfoRow(
                    label: 'Data',
                    value: connected ? 'Connected' : 'Disconnected'),
                const Divider(height: 1),
                _InfoRow(
                  label: 'Sensors',
                  value: '${connected ? data?.workingCount ?? 0 : 0} / 2',
                ),
                const Divider(height: 1),
                _InfoRow(
                    label: 'Source',
                    value: demoMode ? 'Demo data' : 'Supabase'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        DiagnosisResultCard(result: diagnosisResult, onOpen: onOpenDiagnosis),
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
          child: const Text('View readings'),
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
              child:
                  Text(label, style: const TextStyle(color: Color(0xFF777872))),
            ),
            Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
          ],
        ),
      );
}
