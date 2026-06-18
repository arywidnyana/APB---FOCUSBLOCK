// =============================================================
// FILE: lib/logic/notification_service.dart
// TANGGUNG JAWAB: Mengelola local notification — pengingat blok
//   belajar dan notifikasi timer selesai. Tidak butuh server.
// =============================================================

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tzdata;

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  // ── Inisialisasi — panggil sekali di main.dart ─────────────
  Future<void> init() async {
    if (_initialized) return;

    tzdata.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);

    await _plugin.initialize(initSettings);
    await _requestPermission();

    _initialized = true;
  }

  // ── Minta izin notifikasi (Android 13+) ────────────────────
  Future<void> _requestPermission() async {
    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.requestNotificationsPermission();
    await androidPlugin?.requestExactAlarmsPermission();
  }

  // ── Notifikasi langsung (instan) — untuk timer selesai ─────
  Future<void> showInstant({
    required int id,
    required String title,
    required String body,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'focusblock_instant',
      'FocusBlock — Timer',
      channelDescription: 'Notifikasi saat sesi Pomodoro selesai',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );
    const details = NotificationDetails(android: androidDetails);
    await _plugin.show(id, title, body, details);
  }

  // ── Jadwalkan notifikasi — untuk pengingat blok belajar ────
  Future<void> scheduleReminder({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
  }) async {
    if (scheduledTime.isBefore(DateTime.now())) return; // jangan jadwalkan masa lalu

    const androidDetails = AndroidNotificationDetails(
      'focusblock_reminder',
      'FocusBlock — Pengingat Blok',
      channelDescription: 'Pengingat sebelum blok belajar dimulai',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );
    const details = NotificationDetails(android: androidDetails);

    await _plugin.zonedSchedule(
      id, title, body,
      tz.TZDateTime.from(scheduledTime, tz.local),
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  // ── Batalkan notifikasi tertentu (misal blok dihapus) ──────
  Future<void> cancel(int id) async => await _plugin.cancel(id);

  // ── Batalkan semua notifikasi ───────────────────────────────
  Future<void> cancelAll() async => await _plugin.cancelAll();
}
