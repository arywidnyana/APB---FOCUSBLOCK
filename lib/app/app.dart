// =============================================================
// FILE: lib/app/app.dart
// TANGGUNG JAWAB: Root widget aplikasi. Mendaftarkan semua
//   Provider dan menyiapkan MaterialApp dengan routing utama.
// =============================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_theme.dart';
import '../features/home/provider/home_provider.dart';
import '../features/timer/provider/timer_provider.dart';
import '../features/block/provider/block_provider.dart';
import '../features/report/provider/report_provider.dart';
import 'main_shell.dart';

class FocusBlockApp extends StatelessWidget {
  const FocusBlockApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => HomeProvider()),
        ChangeNotifierProvider(create: (_) => TimerProvider()),
        ChangeNotifierProvider(create: (_) => BlockProvider()),
        ChangeNotifierProvider(create: (_) => ReportProvider()),
      ],
      child: MaterialApp(
        title:        'FocusBlock',
        theme:        AppTheme.dark,
        debugShowCheckedModeBanner: false,
        home:         const MainShell(),
      ),
    );
  }
}
