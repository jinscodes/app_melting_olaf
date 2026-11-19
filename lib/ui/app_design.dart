import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

abstract final class AppColors {
  static const background = Color(0xFFF2F2F7);
  static const ink = Color(0xFF1C1C1E);
  static const secondary = Color(0xFF68686E);
  static const blue = Color(0xFF007AFF);
  static const teal = Color(0xFF148678);
  static const orange = Color(0xFFB95B00);
  static const red = Color(0xFFD52C35);
  static const separator = Color(0xFFE8E8ED);
}

abstract final class AppTheme {
  static ThemeData get light => ThemeData(
        useMaterial3: true,
        platform: TargetPlatform.iOS,
        fontFamily: '.SF Pro Text',
        fontFamilyFallback: const ['Segoe UI', 'Arial'],
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.blue).copyWith(
          primary: AppColors.blue,
          surface: Colors.white,
          onSurface: AppColors.ink,
        ),
        textTheme: const TextTheme(
          headlineLarge: TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.w700,
              letterSpacing: -1.1,
              color: AppColors.ink),
          headlineMedium: TextStyle(
              fontSize: 27,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.7,
              color: AppColors.ink),
          titleLarge: TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.4,
              color: AppColors.ink),
          titleMedium: TextStyle(
              fontSize: 17, fontWeight: FontWeight.w600, color: AppColors.ink),
          bodyLarge:
              TextStyle(fontSize: 16, height: 1.45, color: AppColors.ink),
          bodyMedium:
              TextStyle(fontSize: 14, height: 1.45, color: AppColors.secondary),
          bodySmall:
              TextStyle(fontSize: 12, height: 1.4, color: AppColors.secondary),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.background,
          foregroundColor: AppColors.ink,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: false,
          titleSpacing: 20,
          toolbarHeight: 48,
          titleTextStyle: TextStyle(
              fontFamily: '.SF Pro Text',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.ink),
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          margin: EdgeInsets.zero,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        ),
        filledButtonTheme: FilledButtonThemeData(
            style: FilledButton.styleFrom(
          backgroundColor: AppColors.blue,
          foregroundColor: Colors.white,
          minimumSize: const Size(0, 50),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          textStyle: const TextStyle(
              fontFamily: '.SF Pro Text',
              fontSize: 16,
              fontWeight: FontWeight.w600),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        )),
        outlinedButtonTheme: OutlinedButtonThemeData(
            style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, 48),
          foregroundColor: AppColors.blue,
          side: const BorderSide(color: AppColors.separator),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        )),
        textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
          foregroundColor: AppColors.blue,
          minimumSize: const Size(44, 44),
          textStyle: const TextStyle(
              fontFamily: '.SF Pro Text',
              fontSize: 15,
              fontWeight: FontWeight.w600),
        )),
        dividerTheme: const DividerThemeData(
            color: AppColors.separator, thickness: 0.7, space: 1),
        progressIndicatorTheme: const ProgressIndicatorThemeData(
            color: AppColors.blue,
            linearTrackColor: Color(0xFFE8F1FF),
            borderRadius: BorderRadius.all(Radius.circular(8)),
            linearMinHeight: 7),
        cupertinoOverrideTheme:
            const CupertinoThemeData(primaryColor: AppColors.blue),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none),
        ),
      );
}

class PageHeading extends StatelessWidget {
  const PageHeading(this.title, this.subtitle, {super.key});
  final String title;
  final String subtitle;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: Theme.of(context).textTheme.headlineLarge),
          const SizedBox(height: 6),
          Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
        ]),
      );
}

class SectionCaption extends StatelessWidget {
  const SectionCaption(this.text, {super.key});
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(4, 24, 4, 10),
        child: Text(text.toUpperCase(),
            style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.2,
                color: AppColors.secondary)),
      );
}

class StatusPill extends StatelessWidget {
  const StatusPill(this.label,
      {super.key, this.color = AppColors.blue, this.dot = true});
  final String label;
  final Color color;
  final bool dot;
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
            color: color.withValues(alpha: 0.09),
            borderRadius: BorderRadius.circular(20)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          if (dot) ...[
            Icon(CupertinoIcons.circle_fill, size: 6, color: color),
            const SizedBox(width: 6)
          ],
          Flexible(
              child: Text(label,
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: color))),
        ]),
      );
}

class SymbolTile extends StatelessWidget {
  const SymbolTile(this.icon, {super.key, this.color = AppColors.blue});
  final IconData icon;
  final Color color;
  @override
  Widget build(BuildContext context) => Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
            color: color.withValues(alpha: 0.09),
            borderRadius: BorderRadius.circular(12)),
        child: Icon(icon, color: color, size: 21),
      );
}

String displayTime(BuildContext context, DateTime? value, {bool date = false}) {
  if (value == null) return 'No readings yet';
  final local = value.toLocal();
  final labels = MaterialLocalizations.of(context);
  final time = labels.formatTimeOfDay(TimeOfDay.fromDateTime(local),
      alwaysUse24HourFormat: false);
  return date ? '${labels.formatShortDate(local)} · $time' : time;
}
