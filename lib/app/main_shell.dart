// =============================================================
// FILE: lib/app/main_shell.dart
// TANGGUNG JAWAB: Shell utama dengan Bottom Navigation Bar.
//   Mengatur perpindahan antar screen utama (Home, Report, Settings).
// =============================================================

import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../features/home/presentation/home_screen.dart';
import '../features/report/presentation/report_screen.dart';
import '../features/settings/presentation/settings_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    ReportScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (i) => setState(() => _currentIndex = i),
          items: const [
            BottomNavigationBarItem(
              icon:       Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label:      'Home',
            ),
            BottomNavigationBarItem(
              icon:       Icon(Icons.bar_chart_outlined),
              activeIcon: Icon(Icons.bar_chart),
              label:      'Laporan',
            ),
            BottomNavigationBarItem(
              icon:       Icon(Icons.settings_outlined),
              activeIcon: Icon(Icons.settings),
              label:      'Settings',
            ),
          ],
        ),
      ),
    );
  }
}
