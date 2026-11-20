import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../services/diagnosis_controller.dart';
import '../ui/app_design.dart';

class DiagnosisPage extends StatelessWidget {
  const DiagnosisPage({super.key, required this.controller});
  final DiagnosisController controller;

  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: controller,
        builder: (context, _) {
          final c = controller;
          final step = switch (c.stage) {
            DiagnosisStage.idle => 0,
            DiagnosisStage.baseline => 1,
            DiagnosisStage.heating => 2,
            DiagnosisStage.cooling => 3,
            DiagnosisStage.analyzing => 4,
            _ => 5,
          };
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
            children: [
              Text('AI Scan',
                  style: Theme.of(context)
                      .textTheme
                      .headlineMedium
                      ?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              const Text('Compare the cooling patterns of two pipe sections.'),
              const SizedBox(height: 16),
              const Card(
                  child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                          'Demo preview. Simulated data · AI not connected. Buttons do not control heating or record real measurements.'))),
              const SizedBox(height: 16),
              if (!c.active) ...[
                DropdownButtonFormField<DemoOutcome>(
                  initialValue: c.outcome,
                  isExpanded: true,
                  decoration: const InputDecoration(
                      labelText: 'Preview outcome',
                      border: OutlineInputBorder()),
                  items: const [
                    DropdownMenuItem(
                        value: DemoOutcome.sensorA,
                        child: Text('Sensor A more vulnerable')),
                    DropdownMenuItem(
                        value: DemoOutcome.sensorB,
                        child: Text('Sensor B more vulnerable')),
                    DropdownMenuItem(
                        value: DemoOutcome.indeterminate,
                        child: Text('Indeterminate')),
                    DropdownMenuItem(
                        value: DemoOutcome.failure,
                        child: Text('Analysis failure')),
                  ],
                  onChanged: (value) => c.configure(result: value),
                ),
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Fast preview'),
                  subtitle: const Text('Replay 180 seconds in 10 seconds'),
                  value: c.fastPreview,
                  onChanged: (value) => c.configure(fast: value),
                ),
              ],
              Card(
                  child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(step == 0 ? 'Ready to scan' : 'Step $step / 5',
                              style: const TextStyle(color: Color(0xFF777872))),
                          const SizedBox(height: 12),
                          Text(
                              switch (c.stage) {
                                DiagnosisStage.idle =>
                                  'Compare a 3-minute cooling response',
                                DiagnosisStage.baseline => 'Record a baseline',
                                DiagnosisStage.heating =>
                                  'Remove the heater after warming',
                                DiagnosisStage.cooling =>
                                  'Recording cooling response',
                                DiagnosisStage.analyzing =>
                                  'Analyzing cooling patterns',
                                DiagnosisStage.complete => 'Analysis complete',
                                DiagnosisStage.failed =>
                                  'Analysis could not be completed',
                              },
                              style: const TextStyle(
                                  fontSize: 23, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 14),
                          if (c.stage == DiagnosisStage.idle) ...[
                            const Text(
                                'Baseline → Heat → Remove heater → Cool for 180 seconds → Review'),
                            const SizedBox(height: 20),
                            FilledButton(
                                onPressed: c.start,
                                child: const Text('Start demo scan')),
                          ],
                          if (c.stage == DiagnosisStage.baseline) ...[
                            const Text(
                                'Sensor A · 20.0°C\nSensor B · 20.0°C\n\nExample baseline temperatures.'),
                            const SizedBox(height: 20),
                            FilledButton(
                                onPressed: c.recordBaseline,
                                child: const Text('Record baseline')),
                          ],
                          if (c.stage == DiagnosisStage.heating) ...[
                            const Text(
                                'In a real scan, cooling starts when the heater is removed. This demo does not operate any hardware.'),
                            const SizedBox(height: 20),
                            FilledButton(
                                onPressed: c.startCooling,
                                child: const Text(
                                    'Heater removed · Start cooling')),
                          ],
                          if (c.stage == DiagnosisStage.cooling ||
                              c.stage == DiagnosisStage.analyzing) ...[
                            Text(
                                '${c.elapsed} / 180 seconds · ${c.historyA.length} / 181 virtual samples'),
                            const SizedBox(height: 12),
                            LinearProgressIndicator(
                                value: c.stage == DiagnosisStage.analyzing
                                    ? null
                                    : c.elapsed / 180),
                            const SizedBox(height: 12),
                            Text(c.fastPreview
                                ? 'Fast playback · simulated time, not measured time.'
                                : 'Generating one virtual sample per second.'),
                          ],
                          if (c.stage == DiagnosisStage.failed) ...[
                            const Text(
                                'Simulated analysis failure. A real scan would show the reason here, such as missing data or a connection error.'),
                            const SizedBox(height: 16),
                            FilledButton(
                                onPressed: c.start,
                                child: const Text('Try again')),
                          ],
                          if (c.stage == DiagnosisStage.complete) ...[
                            const Text(
                                'The result below is the selected demo scenario.'),
                            const SizedBox(height: 16),
                            OutlinedButton(
                                onPressed: c.start,
                                child: const Text('Start another scan')),
                          ],
                          if (c.active)
                            TextButton(
                                onPressed: c.cancel,
                                child: const Text('Cancel scan')),
                        ],
                      ))),
              if (c.historyA.isNotEmpty) ...[
                const SizedBox(height: 16),
                Card(
                    child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Simulated cooling curve · °C',
                                style: TextStyle(fontWeight: FontWeight.w600)),
                            const Text('Blue: Sensor A · Orange: Sensor B'),
                            const SizedBox(height: 20),
                            SizedBox(
                                height: 180,
                                child: LineChart(LineChartData(
                                  minX: 0,
                                  maxX: 180,
                                  minY: 20,
                                  maxY: 36,
                                  titlesData: const FlTitlesData(show: false),
                                  borderData: FlBorderData(show: false),
                                  lineTouchData:
                                      const LineTouchData(enabled: false),
                                  lineBarsData: [
                                    for (var index = 0; index < 2; index++)
                                      LineChartBarData(
                                        spots: (index == 0
                                                ? c.historyA
                                                : c.historyB)
                                            .asMap()
                                            .entries
                                            .map((e) => FlSpot(e.key.toDouble(),
                                                e.value.value))
                                            .toList(),
                                        color: index == 0
                                            ? Colors.blue
                                            : Colors.orange,
                                        dotData: const FlDotData(show: false),
                                      ),
                                  ],
                                ))),
                            const Text('0–180 seconds',
                                style: TextStyle(fontSize: 12)),
                          ],
                        ))),
              ],
              if (c.stage == DiagnosisStage.complete &&
                  c.latestResult != null) ...[
                const SizedBox(height: 16),
                DiagnosisResultCard(result: c.latestResult!),
              ],
            ],
          );
        },
      );
}

class DiagnosisResultCard extends StatelessWidget {
  const DiagnosisResultCard({super.key, required this.result, this.onOpen});
  final DiagnosisResult? result;
  final VoidCallback? onOpen;

  @override
  Widget build(BuildContext context) {
    final r = result;
    return Card(
        child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('Latest AI scan · Demo',
                    style: TextStyle(color: Color(0xFF777872))),
                const SizedBox(height: 12),
                Text(r?.title ?? 'No AI scan results yet',
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.w600)),
                const SizedBox(height: 10),
                if (r != null) ...[
                  Text(
                      'Scanned: ${displayTime(context, r.completedAt, date: true)}'),
                  const Text('Cooling window: 0–180 seconds · UI demo'),
                  const SizedBox(height: 12),
                  Text(r.outcome == DemoOutcome.indeterminate
                      ? 'The example scores are too close to distinguish the two sections.'
                      : 'This example suggests checking the insulation of this section first.'),
                  if (onOpen == null)
                    ExpansionTile(
                      tilePadding: EdgeInsets.zero,
                      title: const Text('Model score details'),
                      children: [
                        Text(
                            'Sensor A: ${r.scoreA.toStringAsFixed(2)} · Sensor B: ${r.scoreB.toStringAsFixed(2)}'),
                        const Text(
                            'Example non-insulation scores, not freeze probabilities.\nThe 0.15 score-gap threshold is provisional and unvalidated.'),
                      ],
                    ),
                ] else
                  const Text('Explore the demo in the AI Scan tab.'),
                const SizedBox(height: 10),
                const Text(
                    'AI not connected · Simulated result · Separate from live alerts',
                    style: TextStyle(fontSize: 12, color: Color(0xFF777872))),
                if (onOpen != null)
                  TextButton(
                      onPressed: onOpen,
                      child: Text(
                          r == null ? 'Explore AI scan' : 'View scan result')),
              ],
            )));
  }
}
