// =============================================================
// FILE: lib/logic/report_generator.dart
// TANGGUNG JAWAB: Mengolah data mentah dari repository menjadi
//   ringkasan siap tampil. Tidak tahu UI sama sekali.
// =============================================================

import '../data/models/block_model.dart';
import '../data/models/daily_summary_model.dart';
import '../data/repositories/block_repository.dart';
import 'score_calculator.dart';
import '../core/constants/app_constants.dart';

class ReportGenerator {
  final BlockRepository   _repo      = BlockRepository();
  final ScoreCalculator   _calc      = ScoreCalculator.instance;

  ReportGenerator._();
  static final ReportGenerator instance = ReportGenerator._();

  /// Buat DailySummaryModel untuk satu tanggal
  Future<DailySummaryModel> generateDailySummary(String date) async {
    final blocks = await _repo.getBlocksByDate(date);
    final score  = _calc.calculate(blocks);

    return DailySummaryModel(
      date:               date,
      totalPlanned:       blocks.length,
      totalDone:          _calc.countByStatus(blocks, AppConstants.statusDone),
      totalMissed:        _calc.countByStatus(blocks, AppConstants.statusMissed),
      consistencyScore:   score,
      totalActualMinutes: _calc.totalActualMinutes(blocks),
    );
  }

  /// Buat ringkasan 7 hari ke belakang
  Future<List<DailySummaryModel>> generateWeeklySummary(
      DateTime weekStart) async {
    final summaries = <DailySummaryModel>[];
    for (int i = 0; i < 7; i++) {
      final date = _formatDate(weekStart.add(Duration(days: i)));
      summaries.add(await generateDailySummary(date));
    }
    return summaries;
  }

  /// Breakdown jam per mata kuliah dalam rentang tanggal
  Future<Map<String, int>> getSubjectBreakdown(
      String startDate, String endDate) async {
    return _repo.getSubjectMinutes(startDate, endDate);
  }

  /// Ambil missed blocks untuk tanggal tertentu
  Future<List<BlockModel>> getMissedBlocks(String date) async {
    final blocks = await _repo.getBlocksByDate(date);
    return blocks.where((b) => b.status == AppConstants.statusMissed).toList();
  }

  String _formatDate(DateTime dt) =>
    '${dt.year}-${dt.month.toString().padLeft(2,'0')}-${dt.day.toString().padLeft(2,'0')}';
}
