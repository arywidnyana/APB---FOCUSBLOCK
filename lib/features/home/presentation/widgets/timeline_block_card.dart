// =============================================================
// FILE: lib/features/home/presentation/widgets/timeline_block_card.dart
// TANGGUNG JAWAB: Kartu satu blok belajar di timeline HomeScreen.
//   Menampilkan indikator warna status, info sesi, dan tombol aksi.
// =============================================================

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../data/models/block_model.dart';

class TimelineBlockCard extends StatelessWidget {
  final BlockModel block;
  final VoidCallback onStart;
  final VoidCallback onDelete;

  const TimelineBlockCard({
    super.key,
    required this.block,
    required this.onStart,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = AppColors.statusColor(block.status);
    final startDt     = DateTime.tryParse(block.startTime);
    final startStr    = startDt != null
        ? DateFormat('HH:mm').format(startDt)
        : '--:--';
    final endDt       = startDt?.add(Duration(minutes: block.plannedDuration));
    final endStr      = endDt != null
        ? DateFormat('HH:mm').format(endDt)
        : '--:--';

    return Dismissible(
      key: Key('block_${block.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppColors.coralDim,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete_outline, color: AppColors.coral),
      ),
      onDismissed: (_) => onDelete(),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: IntrinsicHeight(
          child: Row(
            children: [
              // Indikator warna status di sisi kiri
              Container(
                width: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(12)),
                ),
              ),
              const SizedBox(width: 14),

              // Info blok
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(block.subject, style: AppTypography.h4),
                      const SizedBox(height: 3),
                      Text(block.sessionName,
                        style: AppTypography.bodyMuted.copyWith(fontSize: 13)),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.schedule,
                            size: 12, color: AppColors.textTertiary),
                          const SizedBox(width: 4),
                          Text(
                            '$startStr — $endStr · ${block.plannedDuration} menit',
                            style: AppTypography.mono.copyWith(fontSize: 11),
                          ),
                        ],
                      ),
                      if (block.actualDuration != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Aktual: ${block.actualDuration} menit',
                          style: AppTypography.mono.copyWith(
                            fontSize: 11, color: statusColor),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              // Badge status + tombol aksi
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 14, 14, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _StatusBadge(status: block.status),
                    const SizedBox(height: 8),
                    if (block.status == AppConstants.statusPending ||
                        block.status == AppConstants.statusOngoing)
                      _StartButton(
                        label: block.status == AppConstants.statusOngoing
                            ? 'Lanjutkan'
                            : 'Mulai',
                        onPressed: onStart,
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final color = AppColors.statusColor(status);
    final bg    = AppColors.statusBg(status);
    final label = switch (status) {
      AppConstants.statusDone    => 'Selesai',
      AppConstants.statusMissed  => 'Missed',
      AppConstants.statusOngoing => 'Berjalan',
      _                          => 'Pending',
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(label,
        style: AppTypography.label.copyWith(
          fontSize: 10, color: color, fontWeight: FontWeight.w600)),
    );
  }
}

class _StartButton extends StatelessWidget {
  final String       label;
  final VoidCallback onPressed;
  const _StartButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: AppColors.tealDim,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: AppColors.tealMid),
        ),
        child: Text(label,
          style: AppTypography.label.copyWith(
            color: AppColors.teal, fontWeight: FontWeight.w600)),
      ),
    );
  }
}
