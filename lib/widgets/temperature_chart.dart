import 'dart:math' as math;
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../models/sensor_data.dart';
import '../ui/app_design.dart';

class TemperatureChart extends StatelessWidget {
  const TemperatureChart(
      {super.key,
      required this.history1,
      required this.history2,
      this.footer = 'Latest 60 readings · temperatures in °C'});
  final List<TemperaturePoint> history1;
  final List<TemperaturePoint> history2;
  final String footer;
  @override
  Widget build(BuildContext context) {
    final all = [...history1, ...history2]
      ..sort((a, b) => a.time.compareTo(b.time));
    if (all.length < 2) {
      return const SizedBox(
          height: 220,
          child: Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.show_chart_rounded, color: AppColors.blue, size: 32),
            SizedBox(height: 12),
            Text('Waiting for temperature data'),
          ])));
    }
    final start = all.first.time;
    final maxX =
        math.max(1.0, all.last.time.difference(start).inMilliseconds / 1000);
    final minY = (all.map((e) => e.value).reduce(math.min) - 1).floorToDouble();
    final maxY = (all.map((e) => e.value).reduce(math.max) + 1).ceilToDouble();
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      const Wrap(spacing: 20, runSpacing: 8, children: [
        _Legend('Sensor A', AppColors.blue),
        _Legend('Sensor B', AppColors.teal)
      ]),
      const SizedBox(height: 24),
      SizedBox(
          height: 200,
          child: LineChart(
              LineChartData(
                minX: 0,
                maxX: maxX,
                minY: minY,
                maxY: maxY,
                gridData: FlGridData(
                    drawVerticalLine: false,
                    horizontalInterval:
                        math.max(1, ((maxY - minY) / 4).ceilToDouble()),
                    getDrawingHorizontalLine: (_) => const FlLine(
                        color: AppColors.separator, strokeWidth: 0.7)),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 34,
                          interval:
                              math.max(1, ((maxY - minY) / 4).ceilToDouble()),
                          getTitlesWidget: (v, meta) => Text('${v.round()}°',
                              style: const TextStyle(
                                  fontSize: 10, color: AppColors.secondary)))),
                ),
                lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                        getTooltipItems: (spots) => spots
                            .map((spot) => LineTooltipItem(
                                '${spot.barIndex == 0 ? 'A' : 'B'}  ${spot.y.toStringAsFixed(1)}°C',
                                const TextStyle(
                                    color: Colors.white, fontSize: 12)))
                            .toList())),
                lineBarsData: [
                  for (var i = 0; i < 2; i++)
                    LineChartBarData(
                      spots: (i == 0 ? history1 : history2)
                          .map((p) => FlSpot(
                              p.time.difference(start).inMilliseconds / 1000,
                              p.value))
                          .toList(),
                      color: i == 0 ? AppColors.blue : AppColors.teal,
                      barWidth: 2.5,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                          show: true,
                          gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                (i == 0 ? AppColors.blue : AppColors.teal)
                                    .withValues(alpha: 0.08),
                                Colors.transparent
                              ])),
                    ),
                ],
              ),
              duration: Duration.zero)),
      const SizedBox(height: 12),
      Row(children: [
        const Text('0s', style: TextStyle(fontSize: 10)),
        const Spacer(),
        Text('${maxX.round()}s', style: const TextStyle(fontSize: 10))
      ]),
      const SizedBox(height: 12),
      Text(footer, style: Theme.of(context).textTheme.bodySmall),
    ]);
  }
}

class _Legend extends StatelessWidget {
  const _Legend(this.label, this.color);
  final String label;
  final Color color;
  @override
  Widget build(BuildContext context) =>
      Row(mainAxisSize: MainAxisSize.min, children: [
        Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 7),
        Text(label, style: const TextStyle(fontSize: 12, color: AppColors.ink))
      ]);
}
