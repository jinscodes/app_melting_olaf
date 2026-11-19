import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../models/sensor_data.dart';
import '../services/diagnosis_controller.dart';
import '../ui/app_design.dart';
import 'diagnosis_page.dart';

class HomePage extends StatelessWidget {
  const HomePage(
      {super.key,
      required this.connected,
      required this.demoMode,
      required this.data,
      required this.lastUpdated,
      required this.error,
      required this.onOpenMenu,
      this.diagnosisResult,
      this.onOpenDiagnosis});
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
    final color = !connected || stale || sensorError
        ? AppColors.secondary
        : switch (risk) {
            FreezeRiskLevel.safe => AppColors.teal,
            FreezeRiskLevel.caution => AppColors.orange,
            FreezeRiskLevel.warning => AppColors.orange,
            FreezeRiskLevel.danger => AppColors.red,
          };
    final title = !connected
        ? 'Waiting for readings'
        : stale
            ? 'Readings paused'
            : sensorError
                ? 'Check your sensors'
                : switch (risk) {
                    FreezeRiskLevel.safe => 'No low-temperature alerts',
                    FreezeRiskLevel.caution => 'Temperature is falling',
                    FreezeRiskLevel.warning => 'Take preventive action',
                    FreezeRiskLevel.danger => 'Check your pipe now',
                  };
    final description = !connected
        ? 'Your latest sensor readings will appear here.'
        : stale
            ? 'The latest reading is more than 15 seconds old. Current conditions are unknown.'
            : sensorError
                ? 'One or more sensors are not reporting a valid temperature.'
                : switch (risk) {
                    FreezeRiskLevel.safe =>
                      'Your latest readings have not triggered a temperature alert.',
                    FreezeRiskLevel.caution =>
                      'Check insulation around the monitored sections.',
                    FreezeRiskLevel.warning =>
                      'Low temperatures or rapid cooling have triggered a warning.',
                    FreezeRiskLevel.danger =>
                      'The temperature alert threshold has been reached. Inspect the monitored pipe immediately.',
                  };
    return ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        children: [
          const PageHeading(
              'Overview', 'A clearer view of your pipe’s condition.'),
          Card(
              child: Padding(
                  padding: const EdgeInsets.all(22),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          SymbolTile(CupertinoIcons.shield_lefthalf_fill,
                              color: color),
                          const Spacer(),
                          StatusPill(
                              !connected
                                  ? 'Connecting'
                                  : stale
                                      ? 'Paused'
                                      : demoMode
                                          ? 'Demo data'
                                          : sensorError
                                              ? 'Sensor issue'
                                              : risk == FreezeRiskLevel.safe
                                                  ? 'Monitoring'
                                                  : risk.label,
                              color: color),
                        ]),
                        const SizedBox(height: 24),
                        Text(title,
                            style: Theme.of(context).textTheme.headlineMedium),
                        const SizedBox(height: 10),
                        Text(description),
                        const SizedBox(height: 22),
                        const Divider(),
                        const SizedBox(height: 14),
                        Row(children: [
                          const Icon(CupertinoIcons.clock,
                              size: 14, color: AppColors.secondary),
                          const SizedBox(width: 6),
                          Expanded(
                              child: Text(
                                  'Updated ${displayTime(context, lastUpdated)}',
                                  style:
                                      Theme.of(context).textTheme.bodySmall)),
                        ]),
                      ]))),
          const SectionCaption('Your sensors'),
          Card(
              child: Column(children: [
            _SensorRow(
                label: 'Sensor A',
                sensor: data?.sensor1,
                available: connected && !stale,
                color: AppColors.blue),
            const Padding(padding: EdgeInsets.only(left: 64), child: Divider()),
            _SensorRow(
                label: 'Sensor B',
                sensor: data?.sensor2,
                available: connected && !stale,
                color: AppColors.teal),
            const Divider(),
            TextButton(
                onPressed: onOpenMenu,
                child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(child: Text('View live readings')),
                      SizedBox(width: 5),
                      Icon(CupertinoIcons.chevron_right, size: 13),
                    ])),
          ])),
          const SectionCaption('Thermal insights'),
          DiagnosisResultCard(result: diagnosisResult, onOpen: onOpenDiagnosis),
          if (error != null) ...[
            const SizedBox(height: 16),
            const Text(
                'Unable to refresh readings. Check your connection and try again.',
                style: TextStyle(color: AppColors.red)),
          ],
        ]);
  }
}

class _SensorRow extends StatelessWidget {
  const _SensorRow(
      {required this.label,
      required this.sensor,
      required this.available,
      required this.color});
  final String label;
  final SensorData? sensor;
  final bool available;
  final Color color;
  @override
  Widget build(BuildContext context) {
    final valid = available && sensor?.ok == true;
    return Padding(
        padding: const EdgeInsets.all(18),
        child: Row(children: [
          SymbolTile(CupertinoIcons.thermometer, color: color),
          const SizedBox(width: 12),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(label, style: Theme.of(context).textTheme.titleMedium),
                Text(valid ? 'Temperature' : 'Waiting for data',
                    style: Theme.of(context).textTheme.bodySmall),
              ])),
          Text(valid ? '${sensor!.temperature!.toStringAsFixed(1)}°C' : '—',
              style: const TextStyle(
                  color: AppColors.ink,
                  fontSize: 23,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.8)),
        ]));
  }
}
