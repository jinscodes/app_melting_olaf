import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../services/diagnosis_controller.dart';

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
              Text('AI 진단',
                  style: Theme.of(context)
                      .textTheme
                      .headlineMedium
                      ?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              const Text('냉각 패턴으로 두 구간의 열 취약성을 비교해요.'),
              const SizedBox(height: 16),
              const Card(
                  child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                          '데모 미리보기 · 실제 센서 기록이나 AI 분석 결과가 아닙니다. 버튼은 화면 흐름만 변경하며 히터를 제어하지 않습니다.'))),
              const SizedBox(height: 16),
              if (!c.active) ...[
                DropdownButtonFormField<DemoOutcome>(
                  initialValue: c.outcome,
                  decoration: const InputDecoration(
                      labelText: '미리 볼 결과', border: OutlineInputBorder()),
                  items: const [
                    DropdownMenuItem(
                        value: DemoOutcome.sensorA, child: Text('센서 A 상대 취약')),
                    DropdownMenuItem(
                        value: DemoOutcome.sensorB, child: Text('센서 B 상대 취약')),
                    DropdownMenuItem(
                        value: DemoOutcome.indeterminate, child: Text('판정 보류')),
                    DropdownMenuItem(
                        value: DemoOutcome.failure, child: Text('분석 실패')),
                  ],
                  onChanged: (value) => c.configure(result: value),
                ),
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('빠른 미리보기'),
                  subtitle: const Text('180초 수집 화면을 10초 동안 재생'),
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
                          Text(step == 0 ? '검사를 시작해 보세요' : '단계 $step / 5',
                              style: const TextStyle(color: Color(0xFF777872))),
                          const SizedBox(height: 12),
                          Text(
                              switch (c.stage) {
                                DiagnosisStage.idle => '약 3분의 냉각 반응을 비교합니다',
                                DiagnosisStage.baseline => '가열 전 기준온도 기록',
                                DiagnosisStage.heating => '가열 후 열선을 제거하세요',
                                DiagnosisStage.cooling => '냉각 기록 수집 중',
                                DiagnosisStage.analyzing => '냉각 패턴 분석 중',
                                DiagnosisStage.complete => '분석 완료',
                                DiagnosisStage.failed => '분석을 완료하지 못했어요',
                              },
                              style: const TextStyle(
                                  fontSize: 23, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 14),
                          if (c.stage == DiagnosisStage.idle) ...[
                            const Text(
                                '기준온도 기록 → 가열 → 열선 제거 → 180초 냉각 → 결과 확인'),
                            const SizedBox(height: 20),
                            FilledButton(
                                onPressed: c.start,
                                child: const Text('데모 검사 시작')),
                          ],
                          if (c.stage == DiagnosisStage.baseline) ...[
                            const Text(
                                '센서 A · 20.0°C\n센서 B · 20.0°C\n\n화면 설명용 기준온도입니다.'),
                            const SizedBox(height: 20),
                            FilledButton(
                                onPressed: c.recordBaseline,
                                child: const Text('기준온도 기록 · 데모')),
                          ],
                          if (c.stage == DiagnosisStage.heating) ...[
                            const Text(
                                '실제 검사에서는 가열을 마치고 열선을 제거한 시점을 냉각 시작으로 기록합니다. 이 데모는 장치를 작동시키지 않습니다.'),
                            const SizedBox(height: 20),
                            FilledButton(
                                onPressed: c.startCooling,
                                child: const Text('열선 제거 · 냉각 측정 시작')),
                          ],
                          if (c.stage == DiagnosisStage.cooling ||
                              c.stage == DiagnosisStage.analyzing) ...[
                            Text(
                                '${c.elapsed} / 180초 · ${c.historyA.length} / 181개 (가상 측정값)'),
                            const SizedBox(height: 12),
                            LinearProgressIndicator(
                                value: c.stage == DiagnosisStage.analyzing
                                    ? null
                                    : c.elapsed / 180),
                            const SizedBox(height: 12),
                            Text(c.fastPreview
                                ? '빠른 미리보기 재생 중 · 표시 시간은 실측 시간이 아닙니다.'
                                : '1초 간격의 가상 데이터를 생성하고 있습니다.'),
                          ],
                          if (c.stage == DiagnosisStage.failed) ...[
                            const Text(
                                '데모 분석 실패 상황입니다. 실제 연결 시 데이터 누락·연결 오류 등의 원인을 여기에 표시합니다.'),
                            const SizedBox(height: 16),
                            FilledButton(
                                onPressed: c.start, child: const Text('다시 검사')),
                          ],
                          if (c.stage == DiagnosisStage.complete) ...[
                            const Text('아래 결과는 선택한 데모 시나리오입니다.'),
                            const SizedBox(height: 16),
                            OutlinedButton(
                                onPressed: c.start,
                                child: const Text('새 데모 검사')),
                          ],
                          if (c.active)
                            TextButton(
                                onPressed: c.cancel,
                                child: const Text('검사 취소')),
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
                            const Text('가상 냉각 곡선 · °C',
                                style: TextStyle(fontWeight: FontWeight.w600)),
                            const Text('파랑: 센서 A · 주황: 센서 B'),
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
                            const Text(
                                '0초                                      180초',
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
    final time = r?.completedAt.toLocal();
    return Card(
        child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('최근 AI 진단 · 데모',
                    style: TextStyle(color: Color(0xFF777872))),
                const SizedBox(height: 12),
                Text(r?.title ?? '아직 AI 검사 결과가 없어요',
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.w600)),
                const SizedBox(height: 10),
                if (r != null) ...[
                  Text(
                      '검사 시각: ${time!.year}.${time.month.toString().padLeft(2, '0')}.${time.day.toString().padLeft(2, '0')} ${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:${time.second.toString().padLeft(2, '0')}'),
                  const Text('냉각 구간: 0~180초 · 모델: UI 데모'),
                  const SizedBox(height: 12),
                  Text(r.outcome == DemoOutcome.indeterminate
                      ? '두 점수 차이가 작아 판정을 보류한 예시입니다.'
                      : '해당 구간의 단열 상태를 우선 확인하는 결과 예시입니다.'),
                  if (onOpen == null)
                    ExpansionTile(
                      tilePadding: EdgeInsets.zero,
                      title: const Text('모델 점수 자세히 보기'),
                      children: [
                        Text(
                            '센서 A: ${r.scoreA.toStringAsFixed(2)} · 센서 B: ${r.scoreB.toStringAsFixed(2)}'),
                        const Text(
                            '비단열 모델 점수 예시입니다. 동파 확률이 아닙니다.\n점수 차이 0.15는 검증 전 임시 판정 기준입니다.'),
                      ],
                    ),
                ] else
                  const Text('AI 진단 탭에서 검사 흐름을 미리 확인하세요.'),
                const SizedBox(height: 10),
                const Text('실제 AI 미연결 · 가상 결과 · 실시간 온도 경고와 별개',
                    style: TextStyle(fontSize: 12, color: Color(0xFF777872))),
                if (onOpen != null)
                  TextButton(
                      onPressed: onOpen,
                      child: Text(r == null ? 'AI 진단 시작하기' : '진단 결과 보기')),
              ],
            )));
  }
}
