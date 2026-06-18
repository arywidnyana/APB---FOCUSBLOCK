// =============================================================
// FILE: lib/features/timer/presentation/timer_screen.dart
// =============================================================
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../provider/timer_provider.dart';
import '../../../logic/timer_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/models/block_model.dart';
import 'widgets/circular_timer.dart';

class TimerScreen extends StatefulWidget {
  final BlockModel block;
  const TimerScreen({super.key, required this.block});
  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TimerProvider>().startBlock(widget.block);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.navy,
      appBar: AppBar(backgroundColor: AppColors.navy, elevation: 0,
        leading: IconButton(icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.textSecondary, size: 28),
          onPressed: () => _confirmExit(context)),
        title: Text(widget.block.subject, style: AppTypography.h4), centerTitle: true),
      body: Consumer<TimerProvider>(builder: (context, provider, _) {
        final state = provider.timerState;
        return SafeArea(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(children: [
            const SizedBox(height: 16),
            Container(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(color: _phaseColor(state.phase).withOpacity(0.15),
                borderRadius: BorderRadius.circular(99),
                border: Border.all(color: _phaseColor(state.phase).withOpacity(0.4))),
              child: Text(state.phaseLabel, style: AppTypography.label.copyWith(
                color: _phaseColor(state.phase), fontWeight: FontWeight.w600))),
            const SizedBox(height: 36),
            CircularTimer(progress: state.progress, displayTime: state.displayTime,
              sessionCount: state.sessionCount, phase: state.phase, color: _phaseColor(state.phase)),
            const SizedBox(height: 28),
            Text(widget.block.sessionName, style: AppTypography.bodyMuted, textAlign: TextAlign.center),
            const SizedBox(height: 8),
            _SessionDots(current: state.sessionCount, total: AppConstants.sessionsBeforeLongBreak),
            const Spacer(),
            _TimerControls(provider: provider),
            const SizedBox(height: 32),
          ])));
      }),
    );
  }

  Color _phaseColor(TimerPhase phase) => switch (phase) {
    TimerPhase.focus => AppColors.teal, TimerPhase.shortBreak => AppColors.amber, TimerPhase.longBreak => AppColors.coral,
  };

  Future<void> _confirmExit(BuildContext context) async {
    final confirmed = await showDialog<bool>(context: context, builder: (_) => AlertDialog(
      backgroundColor: AppColors.surface, title: Text('Keluar dari sesi?', style: AppTypography.h4),
      content: Text('Sesi yang sedang berjalan akan dicatat sebagai missed.', style: AppTypography.bodyMuted),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false),
          child: const Text('Batalkan', style: TextStyle(color: AppColors.textSecondary))),
        TextButton(onPressed: () => Navigator.pop(context, true),
          child: const Text('Keluar', style: TextStyle(color: AppColors.coral))),
      ]));
    if (confirmed == true && mounted) {
      await context.read<TimerProvider>().exitTimer();
      Navigator.pop(context);
    }
  }
}

class _SessionDots extends StatelessWidget {
  final int current, total;
  const _SessionDots({required this.current, required this.total});
  @override
  Widget build(BuildContext context) => Row(mainAxisAlignment: MainAxisAlignment.center,
    children: List.generate(total, (i) {
      final isDone = i < current, isActive = i == current;
      return Container(margin: const EdgeInsets.symmetric(horizontal: 4),
        width: isActive ? 16 : 8, height: 8,
        decoration: BoxDecoration(
          color: isDone ? AppColors.tealDim : isActive ? AppColors.teal : AppColors.surface3,
          borderRadius: BorderRadius.circular(99)));
    }));
}

class _TimerControls extends StatelessWidget {
  final TimerProvider provider;
  const _TimerControls({required this.provider});

  @override
  Widget build(BuildContext context) {
    final isRunning = provider.timerState.isRunning;
    final isPaused = provider.timerState.isPaused;
    return Column(children: [
      SizedBox(width: double.infinity, child: ElevatedButton(
        onPressed: () { provider.completeBlock(); Navigator.pop(context); },
        style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
        child: const Text('Tandai Selesai'))),
      const SizedBox(height: 12),
      Row(children: [
        Expanded(child: OutlinedButton(
          onPressed: () {
            if (isRunning) {
              provider.pause();
            } else if (isPaused) {
              provider.resume();
            } else {
              provider.startTimer();
            }
          },
          style: OutlinedButton.styleFrom(foregroundColor: AppColors.textPrimary,
            side: const BorderSide(color: AppColors.border), padding: const EdgeInsets.symmetric(vertical: 14)),
          child: Text(isRunning ? 'Pause' : isPaused ? 'Lanjutkan' : 'Mulai',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600)))),
        const SizedBox(width: 12),
        Expanded(child: OutlinedButton(
          onPressed: provider.skip,
          style: OutlinedButton.styleFrom(foregroundColor: AppColors.textSecondary,
            side: const BorderSide(color: AppColors.border), padding: const EdgeInsets.symmetric(vertical: 14)),
          child: Text('Lewati', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)))),
      ]),
    ]);
  }
}
