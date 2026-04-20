// =============================================================
// FILE: lib/features/home/presentation/widgets/daily_summary_bar.dart
// TANGGUNG JAWAB: Widget kartu summary harian di bagian atas
//   HomeScreen — menampilkan score, progress bar, dan statistik.
// =============================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../data/models/daily_summary_model.dart';

class DailySummaryBar extends StatelessWidget {
  final DailySummaryModel? summary;

  const DailySummaryBar({super.key, this.summary});

  @override
  Widget build(BuildContext context) {
    final s     = summary;
    final score = s?.consistencyScore ?? 0.0;
    final prog  = s == null || s.totalPlanned == 0
        ? 0.0
        : s.totalDone / s.totalPlanned;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Score besar di kiri
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    score.toStringAsFixed(0),
                    style: AppTypography.scoreHuge,
                  ),
                  const SizedBox(width: 2),
                  Text('%',
                    style: GoogleFonts.poppins(
                      fontSize: 20, fontWeight: FontWeight.w500,
                      color: AppColors.tealMid)),
                ],
              ),
              const SizedBox(height: 4),
              Text(AppConstants.scoreLabel(score),
                style: AppTypography.caption.copyWith(
                  color: AppColors.teal, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(width: 20),

          // Progress & stats di kanan
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Progress hari ini', style: AppTypography.caption),
                    Text(
                      '${s?.totalDone ?? 0} / ${s?.totalPlanned ?? 0} blok',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.teal),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(99),
                  child: LinearProgressIndicator(
                    value: prog.clamp(0.0, 1.0),
                    minHeight: 6,
                    backgroundColor: AppColors.surface3,
                    valueColor: const AlwaysStoppedAnimation(AppColors.teal),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _StatChip(
                      value: '${s?.totalDone ?? 0}',
                      label: 'Selesai',
                      color: AppColors.teal,
                    ),
                    const SizedBox(width: 8),
                    _StatChip(
                      value: '${s?.totalMissed ?? 0}',
                      label: 'Missed',
                      color: AppColors.coral,
                    ),
                    const SizedBox(width: 8),
                    _StatChip(
                      value: s == null
                          ? '0'
                          : '${s.totalPlanned - s.totalDone - s.totalMissed}',
                      label: 'Pending',
                      color: AppColors.textSecondary,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String value;
  final String label;
  final Color  color;

  const _StatChip({
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.surface3,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(value,
              style: GoogleFonts.poppins(
                fontSize: 16, fontWeight: FontWeight.w600, color: color)),
            const SizedBox(height: 2),
            Text(label,
              style: AppTypography.label.copyWith(fontSize: 10)),
          ],
        ),
      ),
    );
  }
}
