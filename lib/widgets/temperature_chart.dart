import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import '../models/sensor_data.dart';

class TemperatureChart extends StatefulWidget {
  final List<TemperaturePoint> history1;
  final List<TemperaturePoint> history2;

  const TemperatureChart({
    super.key,
    required this.history1,
    required this.history2,
  });

  @override
  State<TemperatureChart> createState() => _TemperatureChartState();
}

class _TemperatureChartState extends State<TemperatureChart> {
  static const sensor1Color = Color(0xFF006CE5);
  static const sensor2Color = Color(0xFFFF6B00);
  static const pointSpacing = 14.0;

  final ScrollController _scrollController = ScrollController();
  int _pointCount = 0;

  List<FlSpot> _makeSpots(List<TemperaturePoint> history, DateTime start) {
    return history.map((point) {
      final x = point.time.difference(start).inMilliseconds / 1000.0;
      return FlSpot(math.max(0, x), point.value);
    }).toList();
  }

  void _scrollToLatest() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  @override
  void didUpdateWidget(covariant TemperatureChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    final newPointCount = widget.history1.length + widget.history2.length;
    if (newPointCount > _pointCount) {
      _pointCount = newPointCount;
      _scrollToLatest();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final all = [...widget.history1, ...widget.history2]
      ..sort((a, b) => a.time.compareTo(b.time));

    if (all.length < 2) {
      return const SizedBox(
        height: 220,
        child: Center(
          child: Text(
            '온도 데이터를 기다리는 중',
            style: TextStyle(color: Color(0xFF858680)),
          ),
        ),
      );
    }

    if (_pointCount == 0) {
      _pointCount = all.length;
      _scrollToLatest();
    }

    final start = all.first.time;
    final end = all.last.time;
    final maxX = math.max(1.0, end.difference(start).inMilliseconds / 1000.0);
    final spots1 = _makeSpots(widget.history1, start);
    final spots2 = _makeSpots(widget.history2, start);

    final values = all.map((point) => point.value).toList();

    final minTemp = values.reduce(math.min);
    final maxTemp = values.reduce(math.max);
    final timestampCount = all.map((point) => point.time).toSet().length;

    return Column(
      children: [
        const Row(
          children: [
            Icon(Icons.circle, size: 12, color: sensor1Color),
            Text(' 센서 1     '),
            Icon(Icons.circle, size: 12, color: sensor2Color),
            Text(' 센서 2'),
            Spacer(),
            Icon(Icons.swipe, size: 18, color: Color(0xFF777872)),
          ],
        ),

        const SizedBox(height: 16),

        LayoutBuilder(
          builder: (context, constraints) {
            final chartWidth = math.max(
              constraints.maxWidth,
              timestampCount * pointSpacing,
            );
            return Scrollbar(
              controller: _scrollController,
              thumbVisibility: chartWidth > constraints.maxWidth,
              scrollbarOrientation: ScrollbarOrientation.bottom,
              child: SingleChildScrollView(
                controller: _scrollController,
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: chartWidth,
                  height: 230,
                  child: LineChart(
                    LineChartData(
                      minX: 0,
                      maxX: maxX,
                      minY: minTemp - 0.7,
                      maxY: maxTemp + 0.7,
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        getDrawingHorizontalLine: (_) => const FlLine(
                          color: Color(0xFFE1E3E8),
                          strokeWidth: 1,
                        ),
                      ),
                      titlesData: const FlTitlesData(show: false),
                      borderData: FlBorderData(show: false),
                      lineTouchData: LineTouchData(
                        touchTooltipData: LineTouchTooltipData(
                          getTooltipColor: (_) => const Color(0xFF202124),
                        ),
                      ),
                      lineBarsData: [
                        if (spots1.isNotEmpty)
                          LineChartBarData(
                            spots: spots1,
                            isCurved: false,
                            color: sensor1Color,
                            barWidth: 3,
                            dotData: const FlDotData(show: false),
                          ),
                        if (spots2.isNotEmpty)
                          LineChartBarData(
                            spots: spots2,
                            isCurved: false,
                            color: sensor2Color,
                            barWidth: 3,
                            dotData: const FlDotData(show: false),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),

        const SizedBox(height: 12),

        const Text(
          '좌우로 밀어 이전 측정값 보기 · 최대 60건',
          style: TextStyle(fontSize: 12, color: Colors.black54),
        ),
      ],
    );
  }
}
