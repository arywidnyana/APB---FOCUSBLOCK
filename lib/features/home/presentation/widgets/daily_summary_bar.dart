// FILE: lib/features/home/presentation/widgets/daily_summary_bar.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

class MiniStat extends StatelessWidget {
  final String value, label;
  final Color color;
  const MiniStat({super.key, required this.value, required this.label, required this.color});

  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(color: AppColors.surface3, borderRadius: BorderRadius.circular(8)),
      child: Column(children: [
        Text(value, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: color)),
        const SizedBox(height: 2),
        Text(label, style: AppTypography.label.copyWith(fontSize: 10)),
      ]),
    ),
  );
}
