// =============================================================
// FILE: lib/app/main_shell.dart
// TANGGUNG JAWAB: Shell utama dengan Navigation Bar 5 tab —
//   Home, Teman, Notifikasi, Laporan, Settings.
// =============================================================

import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../features/home/presentation/home_screen.dart';
import '../features/friends/presentation/friends_screen.dart';
import '../features/notifications/presentation/notif_screen.dart';
import '../features/report/presentation/report_screen.dart';
import '../features/settings/presentation/settings_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});
  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;
  final int _unreadNotif = 3;

  final List<Widget> _screens = const [
    HomeScreen(),
    FriendsScreen(),
    NotifScreen(),
    ReportScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.border))),
        child: NavigationBar(
          backgroundColor: AppColors.surface,
          surfaceTintColor: Colors.transparent,
          selectedIndex: _currentIndex,
          onDestinationSelected: (i) => setState(() => _currentIndex = i),
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          indicatorColor: AppColors.tealDim,
          destinations: [
            const NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home, color: AppColors.teal),
              label: 'Home'),
            const NavigationDestination(
              icon: Icon(Icons.people_outline),
              selectedIcon: Icon(Icons.people, color: AppColors.teal),
              label: 'Teman'),
            NavigationDestination(
              icon: Badge(
                label: Text('$_unreadNotif'),
                backgroundColor: AppColors.coral,
                child: const Icon(Icons.notifications_outlined)),
              selectedIcon: Badge(
                label: Text('$_unreadNotif'),
                backgroundColor: AppColors.coral,
                child: const Icon(Icons.notifications, color: AppColors.teal)),
              label: 'Notifikasi'),
            const NavigationDestination(
              icon: Icon(Icons.bar_chart_outlined),
              selectedIcon: Icon(Icons.bar_chart, color: AppColors.teal),
              label: 'Laporan'),
            const NavigationDestination(
              icon: Icon(Icons.settings_outlined),
              selectedIcon: Icon(Icons.settings, color: AppColors.teal),
              label: 'Settings'),
          ],
        ),
      ),
    );
  }
}
