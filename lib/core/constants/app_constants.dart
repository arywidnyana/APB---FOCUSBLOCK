// =============================================================
// FILE: lib/core/constants/app_constants.dart
// TANGGUNG JAWAB: Semua konstanta string, angka, dan konfigurasi
//   default. Tidak ada hardcode di tempat lain.
// =============================================================

class AppConstants {
  AppConstants._();

  // === App info ===
  static const String appName        = 'FocusBlock';
  static const String appTagline     = 'Smart Study Planner';

  // === Pomodoro default (menit) ===
  static const int defaultFocusDuration      = 25;
  static const int defaultShortBreak         = 5;
  static const int defaultLongBreak          = 15;
  static const int sessionsBeforeLongBreak   = 4;

  // === Database ===
  static const String dbName         = 'focusblock.db';
  static const int    dbVersion      = 1;
  static const String tableBlocks    = 'blocks';
  static const String tableSessions  = 'sessions';
  static const String tableSummary   = 'daily_summary';

  // === SharedPreferences keys ===
  static const String prefUserName        = 'user_name';
  static const String prefFocusDuration   = 'focus_duration';
  static const String prefShortBreak      = 'short_break';
  static const String prefLongBreak       = 'long_break';
  static const String prefNotifEnabled    = 'notif_enabled';
  static const String prefOnboardingDone  = 'onboarding_done';

  // === Block status ===
  static const String statusPending  = 'pending';
  static const String statusOngoing  = 'ongoing';
  static const String statusDone     = 'done';
  static const String statusMissed   = 'missed';

  // === Pomodoro phase ===
  static const String phaseFocus      = 'focus';
  static const String phaseShortBreak = 'short_break';
  static const String phaseLongBreak  = 'long_break';

  // === Mata kuliah default (dari Firestore, ini fallback offline) ===
  static const List<String> defaultSubjects = [
    'Pemrograman Mobile',
    'Kalkulus Diferensial',
    'Struktur Data',
    'Basis Data',
    'Bahasa Inggris',
    'Fisika Dasar',
    'Statistika',
    'Jaringan Komputer',
  ];

  // === Score labels ===
  static String scoreLabel(double score) {
    if (score >= 71) return 'Luar biasa!';
    if (score >= 41) return 'Cukup baik';
    return 'Perlu ditingkatkan';
  }

  // === Notifikasi ===
  static const int notifIdBlock   = 1000;
  static const int notifIdTimer   = 2000;
  static const String notifChannel = 'focusblock_channel';
}
