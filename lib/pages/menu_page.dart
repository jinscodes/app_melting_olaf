import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../models/sensor_data.dart';
import '../ui/app_design.dart';
import '../widgets/temperature_chart.dart';

class MenuPage extends StatelessWidget {
  const MenuPage(
      {super.key,
      required this.connected,
      required this.demoMode,
      required this.data,
      required this.error,
      required this.history1,
      required this.history2,
      required this.onModeChanged});
  final bool connected;
  final bool demoMode;
  final SensorSnapshot? data;
  final String? error;
  final List<TemperaturePoint> history1;
  final List<TemperaturePoint> history2;
  final ValueChanged<bool> onModeChanged;

  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        children: [
          const PageHeading(
              'Live readings', 'Two sensors. One complete picture.'),
          Row(children: [
            Expanded(
                child: _SensorCard(
                    'Sensor A', data?.sensor1, connected, AppColors.blue)),
            const SizedBox(width: 12),
            Expanded(
                child: _SensorCard(
                    'Sensor B', data?.sensor2, connected, AppColors.teal)),
          ]),
          const SectionCaption('Temperature history'),
          Card(
              child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: TemperatureChart(
                      history1: history1, history2: history2))),
          const SectionCaption('Data source'),
          Card(
              child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                  child: Row(children: [
                    const SymbolTile(CupertinoIcons.play_circle),
                    const SizedBox(width: 12),
                    Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                          Text('Demo readings',
                              style: Theme.of(context).textTheme.titleMedium),
                          const SizedBox(height: 3),
                          Text(
                              demoMode
                                  ? 'Simulated sensor data'
                                  : 'Using connected sensors',
                              style: Theme.of(context).textTheme.bodySmall),
                        ])),
                    const SizedBox(width: 8),
                    CupertinoSwitch(
                        value: demoMode,
                        onChanged: onModeChanged,
                        activeTrackColor: AppColors.blue),
                  ]))),
          const Padding(
              padding: EdgeInsets.fromLTRB(4, 10, 4, 0),
              child: Text(
                  'Temperatures are shown in Celsius. Cooling rate is measured in °C per minute.',
                  style: TextStyle(fontSize: 12, color: AppColors.secondary))),
          if (error != null)
            const Padding(
                padding: EdgeInsets.only(top: 16),
                child: Text(
                    'Readings could not be refreshed. Check your connection.',
                    style: TextStyle(color: AppColors.red))),
        ],
      );
}

class _SensorCard extends StatelessWidget {
  const _SensorCard(this.label, this.sensor, this.connected, this.color);
  final String label;
  final SensorData? sensor;
  final bool connected;
  final Color color;
  @override
  Widget build(BuildContext context) {
    final ok = connected && sensor?.ok == true;
    return Card(
        child: Padding(
            padding: const EdgeInsets.all(18),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Icon(CupertinoIcons.thermometer, size: 21, color: color),
              const SizedBox(height: 14),
              Text(label, style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 8),
              FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                      ok ? '${sensor!.temperature!.toStringAsFixed(1)}°C' : '—',
                      style: const TextStyle(
                          color: AppColors.ink,
                          fontSize: 32,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -1.2))),
              const SizedBox(height: 8),
              Text(
                  !ok
                      ? 'No data'
                      : sensor?.slope == null
                          ? 'Calculating rate…'
                          : '${sensor!.slope!.toStringAsFixed(2)} °C/min',
                  style: TextStyle(
                      fontSize: 12, color: ok ? color : AppColors.secondary)),
            ])));
  }
}
