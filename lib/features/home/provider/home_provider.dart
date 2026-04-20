// =============================================================
// FILE: lib/features/home/provider/home_provider.dart
// VERSI: DUMMY DATA — untuk testing frontend tanpa database
// =============================================================

import 'package:flutter/foundation.dart';
import '../../../data/models/block_model.dart';
import '../../../data/models/daily_summary_model.dart';
import '../../../core/constants/app_constants.dart';

class HomeProvider extends ChangeNotifier {
  List<BlockModel>   _blocks  = [];
  DailySummaryModel? _summary;
  bool               _loading = false;

  List<BlockModel>   get blocks  => _blocks;
  DailySummaryModel? get summary => _summary;
  bool               get loading => _loading;

  String get todayDate {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2,'0')}-${now.day.toString().padLeft(2,'0')}';
  }

  Future<void> loadToday() async {
    _loading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 300));

    // ── DUMMY DATA ──────────────────────────────────────────
    final now  = DateTime.now();
    final date = todayDate;
 
    _blocks = [
      BlockModel(
        id: 1, subject: 'Pemrograman Mobile',
        sessionName:     'Implementasi Flutter widget',
        startTime:       DateTime(now.year, now.month, now.day, 8, 0).toIso8601String(),
        plannedDuration: 90, actualDuration: 87,
        status: AppConstants.statusDone,
        date: date, createdAt: date,
      ),
      BlockModel(
        id: 2, subject: 'Kalkulus Diferensial',
        sessionName:     'Latihan soal integral tak tentu',
        startTime:       DateTime(now.year, now.month, now.day, 10, 0).toIso8601String(),
        plannedDuration: 60, actualDuration: 62,
        status: AppConstants.statusDone,
        date: date, createdAt: date,
      ),
      BlockModel(
        id: 3, subject: 'Bahasa Inggris',
        sessionName:     'Reading comprehension TOEFL',
        startTime:       DateTime(now.year, now.month, now.day, 11, 30).toIso8601String(),
        plannedDuration: 30,
        status: AppConstants.statusMissed,
        date: date, createdAt: date,
      ),
      BlockModel(
        id: 4, subject: 'Struktur Data',
        sessionName:     'Review materi linked list',
        startTime:       DateTime(now.year, now.month, now.day, 13, 0).toIso8601String(),
        plannedDuration: 60,
        status: AppConstants.statusOngoing,
        date: date, createdAt: date,
      ),
      BlockModel(
        id: 5, subject: 'Basis Data',
        sessionName:     'Latihan query SQL lanjutan',
        startTime:       DateTime(now.year, now.month, now.day, 15, 0).toIso8601String(),
        plannedDuration: 90,
        status: AppConstants.statusPending,
        date: date, createdAt: date,
      ),
    ];

    _summary = DailySummaryModel(
      date:               date,
      totalPlanned:       5,
      totalDone:          2,
      totalMissed:        1,
      consistencyScore:   72.0,
      totalActualMinutes: 225,
    );
    // ────────────────────────────────────────────────────────

    _loading = false;
    notifyListeners();
  }

  Future<void> updateBlockStatus(BlockModel block, String newStatus) async {
    final idx = _blocks.indexWhere((b) => b.id == block.id);
    if (idx != -1) {
      _blocks[idx] = block.copyWith(status: newStatus);
      notifyListeners();
    }
  }

  Future<void> deleteBlock(int id) async {
    _blocks.removeWhere((b) => b.id == id);
    notifyListeners();
  }
}