// FILE: lib/core/constants/app_constants.dart
class AppConstants {
  AppConstants._();

  static const String appName    = 'FocusBlock';
  static const String appTagline = 'Smart Study Planner';

  static const int defaultFocusDuration    = 25;
  static const int defaultShortBreak       = 5;
  static const int defaultLongBreak        = 15;
  static const int sessionsBeforeLongBreak = 4;

  static const String prefUserName       = 'user_name';
  static const String prefFocusDuration  = 'focus_duration';
  static const String prefShortBreak     = 'short_break';
  static const String prefLongBreak      = 'long_break';
  static const String prefNotifEnabled   = 'notif_enabled';

  static const String statusPending = 'pending';
  static const String statusOngoing = 'ongoing';
  static const String statusDone    = 'done';
  static const String statusMissed  = 'missed';

  static const String phaseFocus      = 'focus';
  static const String phaseShortBreak = 'short_break';
  static const String phaseLongBreak  = 'long_break';

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

  static String scoreLabel(double score) {
    if (score >= 71) return 'Luar biasa!';
    if (score >= 41) return 'Cukup baik';
    return 'Perlu ditingkatkan';
  }
}
