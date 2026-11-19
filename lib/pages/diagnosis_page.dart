import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../services/diagnosis_controller.dart';
import '../ui/app_design.dart';
import '../widgets/temperature_chart.dart';

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
          final title = switch (c.stage) {
            DiagnosisStage.idle => 'Discover how your pipe cools.',
            DiagnosisStage.baseline => 'Record a baseline',
            DiagnosisStage.heating => 'Ready to cool?',
            DiagnosisStage.cooling => 'Capturing the cool-down',
            DiagnosisStage.analyzing => 'Reading the pattern',
            DiagnosisStage.complete => 'Your scan is complete',
            DiagnosisStage.failed => 'Let’s try that again',
          };
          final description = switch (c.stage) {
            DiagnosisStage.idle =>
              'Compare the cooling response of two sections to explore their relative thermal vulnerability.',
            DiagnosisStage.baseline =>
              'Capture each sensor’s temperature before heating. These values are examples.',
            DiagnosisStage.heating =>
              'In a real test, remove the heater before starting the cooling recording.',
            DiagnosisStage.cooling =>
              'Following both sensors across a simulated 180-second cooling window.',
            DiagnosisStage.analyzing =>
              'Preparing the selected example result. No AI model is running.',
            DiagnosisStage.complete =>
              'Review the example result below. Live temperature alerts remain separate.',
            DiagnosisStage.failed =>
              'This is a simulated analysis failure. A real result would include the reason the scan could not finish.',
          };
          return ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
              children: [
                const PageHeading('Thermal scan',
                    'Understand the pattern behind the temperature.'),
                const Row(children: [
                  StatusPill('Demo preview', dot: false),
                  SizedBox(width: 8),
                  Expanded(
                      child: Text('Simulated data · AI not connected',
                          style: TextStyle(
                              fontSize: 11, color: AppColors.secondary)))
                ]),
                const SizedBox(height: 18),
                Card(
                    child: Padding(
                        padding: const EdgeInsets.all(22),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(children: [
                                SymbolTile(
                                    c.stage == DiagnosisStage.failed
                                        ? CupertinoIcons.exclamationmark_circle
                                        : CupertinoIcons.waveform_path,
                                    color: c.stage == DiagnosisStage.failed
                                        ? AppColors.orange
                                        : AppColors.blue),
                                const SizedBox(width: 12),
                                Expanded(
                                    child: Text(
                                        step == 0
                                            ? '3 MIN · 2 SENSORS'
                                            : 'STEP $step OF 5',
                                        style: const TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            letterSpacing: 0.8,
                                            color: AppColors.secondary),
                                        textAlign: TextAlign.end)),
                              ]),
                              const SizedBox(height: 22),
                              Text(title,
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineMedium),
                              const SizedBox(height: 10),
                              Text(description),
                              const SizedBox(height: 22),
                              if (c.stage == DiagnosisStage.idle) ...[
                                const _StepRow(1, 'Baseline',
                                    'Record the starting conditions.'),
                                const _StepRow(2, 'Heat & cool',
                                    'Remove the heater, then record for 180 seconds.'),
                                const _StepRow(3, 'Compare',
                                    'Review the relative vulnerability of A and B.'),
                                const SizedBox(height: 18),
                                FilledButton(
                                    onPressed: c.start,
                                    child: const Text('Start demo scan')),
                              ],
                              if (c.stage == DiagnosisStage.baseline) ...[
                                const Row(children: [
                                  Expanded(child: _BaselineValue('Sensor A')),
                                  SizedBox(width: 10),
                                  Expanded(child: _BaselineValue('Sensor B'))
                                ]),
                                const SizedBox(height: 20),
                                FilledButton(
                                    onPressed: c.recordBaseline,
                                    child: const Text('Record baseline')),
                              ],
                              if (c.stage == DiagnosisStage.heating) ...[
                                const Text(
                                    'The demo does not operate a heater or record real sensor data.',
                                    style: TextStyle(fontSize: 12)),
                                const SizedBox(height: 18),
                                FilledButton(
                                    onPressed: c.startCooling,
                                    child: const Text(
                                        'Heater removed · Start cooling')),
                              ],
                              if (c.stage == DiagnosisStage.cooling ||
                                  c.stage == DiagnosisStage.analyzing) ...[
                                Text('${c.elapsed}',
                                    style: const TextStyle(
                                        fontSize: 54,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: -2,
                                        color: AppColors.ink)),
                                const Text('of 180 simulated seconds'),
                                const SizedBox(height: 16),
                                LinearProgressIndicator(
                                    value: c.stage == DiagnosisStage.analyzing
                                        ? null
                                        : c.elapsed / 180),
                                const SizedBox(height: 12),
                                Text('${c.historyA.length} of 181 sample pairs',
                                    style: const TextStyle(fontSize: 12)),
                                const SizedBox(height: 6),
                                Text(
                                    c.fastPreview
                                        ? 'Fast preview · 10 seconds of playback'
                                        : 'Demo playback · one virtual sample per second',
                                    style: const TextStyle(fontSize: 12)),
                              ],
                              if (c.stage == DiagnosisStage.failed)
                                FilledButton(
                                    onPressed: c.start,
                                    child: const Text('Try again')),
                              if (c.stage == DiagnosisStage.complete)
                                OutlinedButton(
                                    onPressed: c.start,
                                    child: const Text('Start another scan')),
                              if (c.active) ...[
                                const SizedBox(height: 6),
                                TextButton(
                                    onPressed: c.cancel,
                                    child: const Text('Cancel scan')),
                              ],
                            ]))),
                if (c.stage == DiagnosisStage.complete &&
                    c.latestResult != null) ...[
                  const SectionCaption('Scan result'),
                  DiagnosisResultCard(result: c.latestResult!),
                ],
                if (c.historyA.isNotEmpty) ...[
                  const SectionCaption('Cooling response · simulated'),
                  Card(
                      child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: TemperatureChart(
                            history1: c.historyA,
                            history2: c.historyB,
                            footer: 'Simulated 0–180 second cooling response',
                          ))),
                ],
                if (!c.active) ...[
                  const SizedBox(height: 18),
                  Card(
                      child: ExpansionTile(
                    shape: const Border(),
                    collapsedShape: const Border(),
                    leading: const Icon(CupertinoIcons.slider_horizontal_3,
                        color: AppColors.secondary, size: 20),
                    title: const Text('Preview settings',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w500)),
                    childrenPadding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
                    children: [
                      DropdownButtonFormField<DemoOutcome>(
                        initialValue: c.outcome,
                        isExpanded: true,
                        decoration: const InputDecoration(
                            labelText: 'Example outcome',
                            filled: true,
                            fillColor: AppColors.background),
                        items: const [
                          DropdownMenuItem(
                              value: DemoOutcome.sensorA,
                              child: Text('Sensor A more vulnerable')),
                          DropdownMenuItem(
                              value: DemoOutcome.sensorB,
                              child: Text('Sensor B more vulnerable')),
                          DropdownMenuItem(
                              value: DemoOutcome.indeterminate,
                              child: Text('Indeterminate result')),
                          DropdownMenuItem(
                              value: DemoOutcome.failure,
                              child: Text('Analysis failure')),
                        ],
                        onChanged: (value) => c.configure(result: value),
                      ),
                      const SizedBox(height: 14),
                      Row(children: [
                        const Expanded(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                              Text('Fast preview',
                                  style: TextStyle(
                                      fontSize: 15, color: AppColors.ink)),
                              Text('Replay 180 seconds in 10 seconds.',
                                  style: TextStyle(fontSize: 12))
                            ])),
                        const SizedBox(width: 8),
                        CupertinoSwitch(
                            value: c.fastPreview,
                            onChanged: (value) => c.configure(fast: value),
                            activeTrackColor: AppColors.blue),
                      ]),
                    ],
                  )),
                ],
                const Padding(
                    padding: EdgeInsets.fromLTRB(4, 14, 4, 0),
                    child: Text(
                        'Preview only. Buttons do not record real measurements, run AI inference, or control heating.',
                        style: TextStyle(
                            fontSize: 12, color: AppColors.secondary))),
              ]);
        },
      );
}

class _BaselineValue extends StatelessWidget {
  const _BaselineValue(this.label);
  final String label;
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(14)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: const TextStyle(fontSize: 12)),
          const SizedBox(height: 6),
          const FittedBox(
              child: Text('20.0°C',
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: AppColors.ink)))
        ]),
      );
}

class _StepRow extends StatelessWidget {
  const _StepRow(this.number, this.title, this.description);
  final int number;
  final String title;
  final String description;
  @override
  Widget build(BuildContext context) => Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
            width: 25,
            height: 25,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
                shape: BoxShape.circle, color: Color(0xFFEDF4FF)),
            child: Text('$number',
                style: const TextStyle(
                    color: AppColors.blue,
                    fontSize: 12,
                    fontWeight: FontWeight.w600))),
        const SizedBox(width: 12),
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.ink)),
          const SizedBox(height: 2),
          Text(description, style: const TextStyle(fontSize: 12))
        ])),
      ]));
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
            padding: const EdgeInsets.all(22),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Row(children: [
                    SymbolTile(CupertinoIcons.chart_bar_alt_fill),
                    Spacer(),
                    StatusPill('Demo result', dot: false)
                  ]),
                  const SizedBox(height: 18),
                  Text(r?.title ?? 'Your first insight starts here.',
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 10),
                  Text(r == null
                      ? 'Explore a guided thermal scan to compare two pipe sections.'
                      : r.outcome == DemoOutcome.indeterminate
                          ? 'The example scores are too close to distinguish the two sections.'
                          : 'The selected demo identifies this section as relatively more vulnerable. Check its insulation first.'),
                  if (r != null) ...[
                    const SizedBox(height: 18),
                    Text(displayTime(context, r.completedAt, date: true),
                        style: Theme.of(context).textTheme.bodySmall),
                    const Text('Cooling window: 0–180 seconds · UI demo',
                        style: TextStyle(fontSize: 12)),
                    if (onOpen == null)
                      ExpansionTile(
                        tilePadding: EdgeInsets.zero,
                        shape: const Border(),
                        collapsedShape: const Border(),
                        title: const Text('Model score details',
                            style:
                                TextStyle(fontSize: 14, color: AppColors.blue)),
                        children: [
                          _ScoreRow('Sensor A', r.scoreA, AppColors.blue),
                          _ScoreRow('Sensor B', r.scoreB, AppColors.teal),
                          const SizedBox(height: 12),
                          const Text(
                              'Example non-insulation scores, not freeze probabilities. The 0.15 score-gap threshold is provisional and unvalidated.',
                              style: TextStyle(fontSize: 12)),
                        ],
                      ),
                  ],
                  if (onOpen != null) ...[
                    const SizedBox(height: 16),
                    FilledButton.tonal(
                        onPressed: onOpen,
                        style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFFEDF4FF),
                            foregroundColor: AppColors.blue),
                        child: Text(
                            r == null ? 'Explore thermal scan' : 'View scan')),
                  ],
                  const SizedBox(height: 12),
                  const Text(
                      'Simulated result. Separate from live temperature alerts.',
                      style: TextStyle(fontSize: 11)),
                ])));
  }
}

class _ScoreRow extends StatelessWidget {
  const _ScoreRow(this.label, this.score, this.color);
  final String label;
  final double score;
  final Color color;
  @override
  Widget build(BuildContext context) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Column(children: [
        Row(children: [
          Text(label),
          const Spacer(),
          Text(score.toStringAsFixed(2))
        ]),
        const SizedBox(height: 6),
        LinearProgressIndicator(value: score, color: color),
      ]));
}
