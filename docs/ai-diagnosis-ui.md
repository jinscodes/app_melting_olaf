# AI diagnosis UI preview

This branch adds a third tab for the upcoming FreezeScope thermal vulnerability model. It does not run inference, record actual experiments, control heating, or write to Supabase. Existing live temperature monitoring and rule-based alerts continue separately.

## Preview

Open **AI 진단**, select A vulnerable, B vulnerable, indeterminate, or failure. Start the demo, record the example baseline, and start cooling. Fast preview compresses a simulated 180-second curve into 10 seconds; disabling it generates virtual samples at one-second intervals. Two additional seconds demonstrate analysis. Cancellation stops the preview. The home card keeps the last successful/indeterminate demo result for the current app session; results are not persisted after restart.

The UI always identifies simulated data. Model scores are examples, not freeze probabilities. The example 0.15 score-gap threshold is unvalidated. No conditional freezing-time model is connected.

## Integration handoff

`DiagnosisController` owns the preview state and `DiagnosisResult` owns presentation data. Replace demo methods with the team's acquisition/inference adapter without changing the existing temperature warning path. Future adapter events should carry:

- Experiment ID, device ID and analysis window.
- Stage: baseline / heating / cooling / analyzing / complete / failed.
- Actual elapsed time, synchronized A/B samples and data quality.
- Per-sensor baseline, cooling start and actual collection timestamps.
- Outcome: A / B / indeterminate; independent A/B scores.
- Model and preprocessing versions, completion time and failure reason.

Future integration must validate input and reject stale results belonging to a previous experiment. A failed or cancelled attempt must not replace the last completed result. Preserve explicit result timestamps and distinguish monitoring alerts from inspection results. Remove the preview label only when the real adapter is connected and tested. Real sensor collection, persistence, push alerts while the app is stopped, and model validation are outside this UI implementation.

## English interface and original visual design

All product screens, tabs, status labels, errors, and notifications use US English. The app preserves the original cream background (#F6F6F2), off-white cards (#FAFAF7), thin borders, muted gray-green controls, 16-pixel card corners, and Material navigation. The AI tab follows the same original visual language. Sensor labels use A/B; temperature units remain Celsius and thresholds are unchanged. Overview marks readings older than 15 seconds as paused. Responsive and English-copy checks cover 320- and 390-pixel layouts. UI_PREVIEW_DIR optionally captures rendered previews using local test fonts on Windows.
