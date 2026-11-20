import 'package:flutter/material.dart';

import '../models/sensor_data.dart';
import '../widgets/temperature_chart.dart';

class MenuPage extends StatelessWidget {
  const MenuPage({
    super.key,
    required this.connected,
    required this.demoMode,
    required this.data,
    required this.error,
    required this.history1,
    required this.history2,
    required this.onModeChanged,
    required this.demoScenario,
    required this.onDemoScenarioChanged,
  });

  final bool connected;
  final bool demoMode;
  final SensorSnapshot? data;
  final String? error;
  final List<TemperaturePoint> history1;
  final List<TemperaturePoint> history2;
  final ValueChanged<bool> onModeChanged;
  final DemoRiskScenario demoScenario;
  final ValueChanged<DemoRiskScenario> onDemoScenarioChanged;

  String _temperature(double? value) =>
      value == null ? '--' : '${value.toStringAsFixed(1)}°';
  String _slope(double? value) =>
      value == null ? 'Calculating' : '${value.toStringAsFixed(2)} °C/min';

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
      children: [
        Text(
          'Monitoring',
          style: Theme.of(context).textTheme.headlineMedium
              ?.copyWith(fontWeight: FontWeight.w600, letterSpacing: -1),
        ),
        const SizedBox(height: 8),
        const Text(
          'Recent temperatures and cooling rates',
          style: TextStyle(color: Color(0xFF777872)),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: _SensorCard(
                label: 'Sensor A',
                sensor: data?.sensor1,
                connected: connected,
                temperature: _temperature,
                slope: _slope,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _SensorCard(
                label: 'Sensor B',
                sensor: data?.sensor2,
                connected: connected,
                temperature: _temperature,
                slope: _slope,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Card(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 20, 18, 16),
            child: TemperatureChart(history1: history1, history2: history2),
          ),
        ),
        const SizedBox(height: 14),
        Card(
          child: SwitchListTile.adaptive(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 4,
            ),
            title: const Text('Demo scan'),
            subtitle: Text(
              demoMode
                  ? 'Presentation mode · selected alert in about 12 seconds'
                  : 'Using live sensor readings',
            ),
            value: demoMode,
            activeTrackColor: const Color(0xFF7A7D76),
            onChanged: onModeChanged,
          ),
        ),
        if (demoMode) ...[
          const SizedBox(height: 14),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Choose demo alert',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Each scenario finishes in under one minute.',
                    style: TextStyle(color: Color(0xFF777872), fontSize: 12),
                  ),
                  const SizedBox(height: 14),
                  SegmentedButton<DemoRiskScenario>(
                    segments: [
                      for (final scenario in DemoRiskScenario.values)
                        ButtonSegment(
                          value: scenario,
                          label: Text(scenario.label),
                          tooltip:
                              '${scenario.label} · ${scenario.description}',
                        ),
                    ],
                    selected: {demoScenario},
                    showSelectedIcon: false,
                    onSelectionChanged: (selection) =>
                        onDemoScenarioChanged(selection.first),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '${demoScenario.label} · ${demoScenario.description}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ),
        ],
        if (error != null) ...[
          const SizedBox(height: 12),
          Text(
            error!,
            style: const TextStyle(color: Color(0xFF76554D), fontSize: 12),
          ),
        ],
      ],
    );
  }
}

class _SensorCard extends StatelessWidget {
  const _SensorCard({
    required this.label,
    required this.sensor,
    required this.connected,
    required this.temperature,
    required this.slope,
  });

  final String label;
  final SensorData? sensor;
  final bool connected;
  final String Function(double?) temperature;
  final String Function(double?) slope;

  @override
  Widget build(BuildContext context) {
    final ok = connected && sensor?.ok == true;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(color: Color(0xFF777872)),
                  ),
                ),
                Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: ok
                        ? const Color(0xFF626A63)
                        : const Color(0xFF8A756F),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),
            Text(
              ok ? temperature(sensor?.temperature) : '--',
              style: const TextStyle(
                fontSize: 31,
                fontWeight: FontWeight.w500,
                letterSpacing: -1.2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              ok ? slope(sensor?.slope) : 'No data',
              style: const TextStyle(fontSize: 12, color: Color(0xFF858680)),
            ),
          ],
        ),
      ),
    );
  }
}
