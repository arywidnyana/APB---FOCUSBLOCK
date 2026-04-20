// =============================================================
// FILE: lib/features/timer/presentation/widgets/circular_timer.dart
// TANGGUNG JAWAB: Widget lingkaran countdown timer dengan
//   custom painter. Menampilkan progress arc dan waktu di tengah.
// =============================================================

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../logic/timer_controller.dart';

class CircularTimer extends StatelessWidget {
  final double     progress;     // 0.0 – 1.0
  final String     displayTime;  // "18:43"
  final int        sessionCount;
  final TimerPhase phase;
  final Color      color;

  const CircularTimer({
    super.key,
    required this.progress,
    required this.displayTime,
    required this.sessionCount,
    required this.phase,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 240,
      height: 240,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Arc painter
          CustomPaint(
            size: const Size(240, 240),
            painter: _ArcPainter(progress: progress, color: color),
          ),

          // Waktu di tengah
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                displayTime,
                style: GoogleFonts.poppins(
                  fontSize: 52,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  letterSpacing: -1,
                ),
              ),
              Text(
                'sesi ke-${sessionCount + 1}',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ArcPainter extends CustomPainter {
  final double progress;
  final Color  color;

  _ArcPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r  = size.width / 2 - 10;

    final trackPaint = Paint()
      ..color       = AppColors.surface3
      ..style       = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap   = StrokeCap.round;

    final arcPaint = Paint()
      ..color       = color
      ..style       = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap   = StrokeCap.round;

    // Track lingkaran penuh
    canvas.drawCircle(Offset(cx, cy), r, trackPaint);

    // Arc progress (mulai dari atas, searah jarum jam)
    final sweepAngle = 2 * math.pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: r),
      -math.pi / 2,
      sweepAngle,
      false,
      arcPaint,
    );
  }

  @override
  bool shouldRepaint(_ArcPainter old) =>
    old.progress != progress || old.color != color;
}
