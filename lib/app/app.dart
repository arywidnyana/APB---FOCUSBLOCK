// FILE: lib/app/app.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../core/theme/app_theme.dart';
import '../core/theme/app_colors.dart';
import '../features/auth/provider/auth_provider.dart' as app_auth;
import '../features/home/provider/home_provider.dart';
import '../features/timer/provider/timer_provider.dart';
import '../features/block/provider/block_provider.dart';
import '../features/report/provider/report_provider.dart';
import '../features/auth/presentation/login_screen.dart';
import '../logic/presence_service.dart';
import 'main_shell.dart';

class FocusBlockApp extends StatelessWidget {
  const FocusBlockApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => app_auth.AuthProvider()), ChangeNotifierProvider(create: (_) => HomeProvider()),
        ChangeNotifierProvider(create: (_) => TimerProvider()),
        ChangeNotifierProvider(create: (_) => BlockProvider()),
        ChangeNotifierProvider(create: (_) => ReportProvider()),
      ],
      child: MaterialApp(
        title: 'FocusBlock',
        theme: AppTheme.dark,
        debugShowCheckedModeBanner: false,
        home: const AuthGate(),
      ),
    );
  }
}

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});
  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    PresenceService.instance.setOffline();
    super.dispose();
  }

  // Update status otomatis berdasarkan siklus hidup app
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        PresenceService.instance.setOnline();
        break;
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
        PresenceService.instance.setOffline();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: AppColors.navy,
            body: Center(child: CircularProgressIndicator(color: AppColors.teal)),
          );
        }
        if (snapshot.hasData && snapshot.data != null) {
          // User baru login terdeteksi → set status online
          PresenceService.instance.setOnline();
          return const MainShell();
        }
        return const LoginScreen();
      },
    );
  }
}
