// FILE: lib/logic/score_calculator.dart
import '../data/models/block_model.dart';
import '../core/constants/app_constants.dart';

class ScoreCalculator {
  ScoreCalculator._();
  static final ScoreCalculator instance = ScoreCalculator._();

  double calculate(List<BlockModel> blocks) {
    if (blocks.isEmpty) return 0.0;
    int countDone = 0;
    for (final b in blocks) {
      if (_isDone(b)) countDone++;
    }
    return (countDone / blocks.length) * 100;
  }

  bool _isDone(BlockModel b) {
    if (b.status == AppConstants.statusDone) return true;
    if (b.actualDuration != null && b.plannedDuration > 0) {
      return b.actualDuration! / b.plannedDuration >= 0.8;
    }
    return false;
  }

  int totalActualMinutes(List<BlockModel> blocks) => blocks
      .where((b) => b.actualDuration != null)
      .fold(0, (sum, b) => sum + (b.actualDuration ?? 0));

  int countByStatus(List<BlockModel> blocks, String status) =>
      blocks.where((b) => b.status == status).length;
}
