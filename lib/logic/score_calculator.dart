// =============================================================
// FILE: lib/logic/score_calculator.dart
// TANGGUNG JAWAB: Menghitung consistency score harian
//   berdasarkan list blocks. Tidak tahu UI, tidak tahu database.
// =============================================================

import '../data/models/block_model.dart';
import '../core/constants/app_constants.dart';

class ScoreCalculator {
  ScoreCalculator._();
  static final ScoreCalculator instance = ScoreCalculator._();

  /// Hitung consistency score (0.0 – 100.0) dari list blok satu hari.
  ///
  /// Sebuah blok dihitung "done" jika:
  ///   - status == done, ATAU
  ///   - actual_duration >= 80% dari planned_duration
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

  /// Total menit aktual dari blok yang selesai
  int totalActualMinutes(List<BlockModel> blocks) {
    return blocks
      .where((b) => b.actualDuration != null)
      .fold(0, (sum, b) => sum + (b.actualDuration ?? 0));
  }

  /// Jumlah blok dengan status tertentu
  int countByStatus(List<BlockModel> blocks, String status) =>
    blocks.where((b) => b.status == status).length;
}
