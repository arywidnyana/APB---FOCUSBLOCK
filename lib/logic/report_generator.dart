// FILE: lib/logic/report_generator.dart
import '../data/models/block_model.dart';
import '../data/repositories/block_repository.dart';
import 'score_calculator.dart';
import '../core/constants/app_constants.dart';

class DailySummaryModel {
  final String date;
  final int totalPlanned, totalDone, totalMissed, totalActualMinutes;
  final double consistencyScore;
  const DailySummaryModel({
    required this.date, required this.totalPlanned, required this.totalDone,
    required this.totalMissed, required this.consistencyScore,
    required this.totalActualMinutes,
  });
}

class ReportGenerator {
  final BlockRepository _repo = BlockRepository();
  final ScoreCalculator _calc = ScoreCalculator.instance;
  ReportGenerator._();
  static final ReportGenerator instance = ReportGenerator._();

  Future<DailySummaryModel> generateDailySummary(String date) async {
    final blocks = await _repo.getBlocksByDate(date);
    final score = _calc.calculate(blocks);
    return DailySummaryModel(
      date: date, totalPlanned: blocks.length,
      totalDone: _calc.countByStatus(blocks, AppConstants.statusDone),
      totalMissed: _calc.countByStatus(blocks, AppConstants.statusMissed),
      consistencyScore: score,
      totalActualMinutes: _calc.totalActualMinutes(blocks),
    );
  }

  Future<Map<String, int>> getSubjectBreakdown(String startDate, String endDate) =>
      _repo.getSubjectMinutes(startDate, endDate);

  Future<List<BlockModel>> getMissedBlocks(String date) async {
    final blocks = await _repo.getBlocksByDate(date);
    return blocks.where((b) => b.status == AppConstants.statusMissed).toList();
  }
}
