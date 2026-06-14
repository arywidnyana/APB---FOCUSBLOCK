// =============================================================
// FILE: lib/features/report/provider/report_provider.dart
// VERSI: DUMMY DATA — untuk testing frontend tanpa database
// =============================================================

import 'package:flutter/foundation.dart';
import '../../../data/models/block_model.dart';
import '../../../data/models/daily_summary_model.dart';
import '../../../core/constants/app_constants.dart';

class ReportProvider extends ChangeNotifier {
  DailySummaryModel? _dailySummary;
  List<BlockModel>   _missedBlocks   = [];
  Map<String, int>   _subjectMinutes = {};
  bool               _loading        = false;

  DailySummaryModel? get dailySummary   => _dailySummary;
  List<BlockModel>   get missedBlocks   => _missedBlocks;
  Map<String, int>   get subjectMinutes => _subjectMinutes;
  bool               get loading        => _loading;

  String get todayDate {
    final n = DateTime.now();
    return '${n.year}-${n.month.toString().padLeft(2,'0')}-${n.day.toString().padLeft(2,'0')}';
  }

  Future<void> loadReport() async {
    _loading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 400));

    // ── DUMMY DATA ──────────────────────────────────────────
    _dailySummary = DailySummaryModel(
      date:               todayDate,
      totalPlanned:       7,
      totalDone:          5,
      totalMissed:        1,
      consistencyScore:   72.0,
      totalActualMinutes: 225,
    );

    _missedBlocks = [
      BlockModel(
        id: '3', subject: 'Bahasa Inggris',
        sessionName:     'Reading comprehension TOEFL',
        startTime:       DateTime.now().toIso8601String(),
        plannedDuration: 30,
        status:          AppConstants.statusMissed,
        date:            todayDate,
        createdAt:       todayDate,
      ),
    ];

    _subjectMinutes = {
      'Pemrograman Mobile': 306,
      'Kalkulus':           252,
      'Struktur Data':      180,
      'Basis Data':         126,
      'Bahasa Inggris':     72,
    };
    // ────────────────────────────────────────────────────────

    _loading = false;
    notifyListeners();
  }
}