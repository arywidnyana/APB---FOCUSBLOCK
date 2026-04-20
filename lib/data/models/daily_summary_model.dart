// =============================================================
// FILE: lib/data/models/daily_summary_model.dart
// TANGGUNG JAWAB: Model ringkasan harian yang dihasilkan
//   oleh ReportGenerator dan disimpan ke tabel daily_summary.
// =============================================================

class DailySummaryModel {
  final int?   id;
  final String date;
  final int    totalPlanned;
  final int    totalDone;
  final int    totalMissed;
  final double consistencyScore;  // 0.0 - 100.0
  final int    totalActualMinutes;

  const DailySummaryModel({
    this.id,
    required this.date,
    required this.totalPlanned,
    required this.totalDone,
    required this.totalMissed,
    required this.consistencyScore,
    required this.totalActualMinutes,
  });

  factory DailySummaryModel.fromMap(Map<String, dynamic> map) =>
    DailySummaryModel(
      id:                 map['id'] as int?,
      date:               map['date'] as String,
      totalPlanned:       map['total_planned'] as int,
      totalDone:          map['total_done'] as int,
      totalMissed:        map['total_missed'] as int,
      consistencyScore:   (map['consistency_score'] as num).toDouble(),
      totalActualMinutes: map['total_actual_minutes'] as int,
    );

  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'date':                date,
    'total_planned':       totalPlanned,
    'total_done':          totalDone,
    'total_missed':        totalMissed,
    'consistency_score':   consistencyScore,
    'total_actual_minutes':totalActualMinutes,
  };
}
