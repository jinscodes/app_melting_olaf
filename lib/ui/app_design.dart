import 'package:flutter/material.dart';

abstract final class AppTheme {
  static ThemeData get light => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF555752),
          brightness: Brightness.light,
          surface: const Color(0xFFFAFAF7),
        ),
        scaffoldBackgroundColor: const Color(0xFFF6F6F2),
        fontFamily: 'sans-serif',
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFF6F6F2),
          foregroundColor: Color(0xFF242522),
          elevation: 0,
          scrolledUnderElevation: 0,
        ),
        cardTheme: CardThemeData(
          color: const Color(0xFFFAFAF7),
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Color(0xFFE3E3DD)),
          ),
        ),
        navigationBarTheme: const NavigationBarThemeData(
          backgroundColor: Color(0xFFFAFAF7),
          indicatorColor: Color(0xFFE8E8E2),
          elevation: 0,
          height: 68,
        ),
        dividerTheme: const DividerThemeData(color: Color(0xFFE6E6E0)),
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
