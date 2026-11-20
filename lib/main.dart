import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app_shell.dart';
import 'ui/app_design.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: const String.fromEnvironment(
      'SUPABASE_URL',
      defaultValue: 'https://pimrwslkvqumueidurir.supabase.co',
    ),
    publishableKey: const String.fromEnvironment(
      'SUPABASE_ANON_KEY',
      defaultValue: 'sb_publishable_lW0v5zIRxP0tLxsEyLIR0g_ZS3P-0nd',
    ),
  );

  runApp(const TempAlertApp());
}

class TempAlertApp extends StatelessWidget {
  const TempAlertApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Melting Olaf',
      locale: const Locale('en', 'US'),
      theme: AppTheme.light,
      home: const AppShell(),
    );
  }
}
