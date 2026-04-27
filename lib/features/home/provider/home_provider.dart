// =============================================================
// FILE: lib/features/home/provider/home_provider.dart
// VERSI: DUMMY DATA — riwayat keseluruhan blok dengan filter
//   periode (semua / bulan ini / minggu ini)
// =============================================================

import 'package:flutter/foundation.dart';
import '../../../data/models/block_model.dart';
import '../../../data/models/daily_summary_model.dart';
import '../../../core/constants/app_constants.dart';

enum BlockFilter { all, thisWeek, thisMonth }

class HomeProvider extends ChangeNotifier {
  List<BlockModel>   _allBlocks  = [];
  BlockFilter        _filter     = BlockFilter.all;
  bool               _loading    = false;

  List<BlockModel>   get allBlocks     => _allBlocks;
  BlockFilter        get filter        => _filter;
  bool               get loading       => _loading;

  // Blok yang ditampilkan sesuai filter aktif
  List<BlockModel> get filteredBlocks {
    final now = DateTime.now();
    switch (_filter) {
      case BlockFilter.thisWeek:
        final weekStart = now.subtract(Duration(days: now.weekday - 1));
        return _allBlocks.where((b) {
          final d = DateTime.tryParse(b.date);
          return d != null && !d.isBefore(
            DateTime(weekStart.year, weekStart.month, weekStart.day));
        }).toList();
      case BlockFilter.thisMonth:
        return _allBlocks.where((b) {
          final d = DateTime.tryParse(b.date);
          return d != null && d.year == now.year && d.month == now.month;
        }).toList();
      case BlockFilter.all:
        return _allBlocks;
    }
  }

  // Statistik keseluruhan dari filteredBlocks
  int    get totalPlanned => filteredBlocks.length;
  int    get totalDone    => filteredBlocks.where((b) => b.status == AppConstants.statusDone).length;
  int    get totalMissed  => filteredBlocks.where((b) => b.status == AppConstants.statusMissed).length;
  int    get totalPending => filteredBlocks.where((b) =>
    b.status == AppConstants.statusPending || b.status == AppConstants.statusOngoing).length;
  double get overallScore => totalPlanned == 0 ? 0 : (totalDone / totalPlanned) * 100;
  int    get totalActualMinutes => filteredBlocks
    .where((b) => b.actualDuration != null)
    .fold(0, (sum, b) => sum + (b.actualDuration ?? 0));

  String get todayDate {
    final n = DateTime.now();
    return '${n.year}-${n.month.toString().padLeft(2,'0')}-${n.day.toString().padLeft(2,'0')}';
  }

  String get filterLabel => switch (_filter) {
    BlockFilter.all       => 'Semua waktu',
    BlockFilter.thisWeek  => 'Minggu ini',
    BlockFilter.thisMonth => 'Bulan ini',
  };

  void setFilter(BlockFilter f) {
    _filter = f;
    notifyListeners();
  }

  Future<void> loadToday() async {
    _loading = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 300));

    // ── DUMMY DATA — riwayat lengkap beberapa minggu ─────────
    final now = DateTime.now();
    _allBlocks = _generateDummyHistory(now);
    // ─────────────────────────────────────────────────────────

    _loading = false;
    notifyListeners();
  }

  List<BlockModel> _generateDummyHistory(DateTime now) {
    final blocks = <BlockModel>[];
    int id = 1;

    // Generate 30 hari ke belakang
    for (int daysAgo = 29; daysAgo >= 0; daysAgo--) {
      final date = now.subtract(Duration(days: daysAgo));
      final dateStr = '${date.year}-${date.month.toString().padLeft(2,'0')}-${date.day.toString().padLeft(2,'0')}';
      final isToday = daysAgo == 0;
      final isWeekend = date.weekday == 6 || date.weekday == 7;

      // Weekend lebih sedikit blok
      final subjects = isWeekend
          ? ['Kalkulus Diferensial', 'Bahasa Inggris']
          : ['Pemrograman Mobile', 'Kalkulus Diferensial', 'Struktur Data', 'Basis Data'];

      for (int si = 0; si < subjects.length; si++) {
        final subject = subjects[si];
        final hour = 8 + si * 2;
        final planned = [60, 90, 45, 60][si % 4];

        // Status: hari ini sebagian pending, hari lalu mostly done
        String status;
        int? actual;
        if (isToday) {
          if (si == 0) { status = AppConstants.statusDone; actual = planned - 5; }
          else if (si == 1) { status = AppConstants.statusOngoing; actual = null; }
          else { status = AppConstants.statusPending; actual = null; }
        } else {
          // Semakin lama makin bervariasi
          final roll = (id + daysAgo) % 10;
          if (roll < 6) { status = AppConstants.statusDone; actual = planned - (roll * 3); }
          else if (roll < 8) { status = AppConstants.statusMissed; actual = null; }
          else { status = AppConstants.statusDone; actual = planned; }
        }

        blocks.add(BlockModel(
          id: id++,
          subject: subject,
          sessionName: _sessionName(subject),
          startTime: DateTime(date.year, date.month, date.day, hour, 0).toIso8601String(),
          plannedDuration: planned,
          actualDuration: actual,
          status: status,
          date: dateStr,
          createdAt: dateStr,
        ));
      }
    }
    return blocks;
  }

  String _sessionName(String subject) => switch (subject) {
    'Pemrograman Mobile'  => 'Implementasi Flutter widget',
    'Kalkulus Diferensial'=> 'Latihan soal integral',
    'Struktur Data'       => 'Review linked list',
    'Basis Data'          => 'Query SQL lanjutan',
    'Bahasa Inggris'      => 'Reading comprehension',
    _                     => 'Sesi belajar',
  };

  Future<void> updateBlockStatus(BlockModel block, String newStatus) async {
    final idx = _allBlocks.indexWhere((b) => b.id == block.id);
    if (idx != -1) {
      _allBlocks[idx] = block.copyWith(status: newStatus);
      notifyListeners();
    }
  }

  Future<void> deleteBlock(int id) async {
    _allBlocks.removeWhere((b) => b.id == id);
    notifyListeners();
  }
}
