// =============================================================
// FILE: lib/features/collab/presentation/collab_timer_screen.dart
// TANGGUNG JAWAB: Layar timer saat blok belajar bersama teman
//   sedang berjalan. Sama persis dengan TimerScreen tapi dengan
//   panel teman yang ikut sesi di bagian bawah.
// Cara pakai: Navigator.push ke CollabTimerScreen dengan
//   block dan friends yang sudah dipilih dari CollabBlockScreen.
// =============================================================

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../timer/provider/timer_provider.dart';
import '../../../logic/timer_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/models/block_model.dart';
import '../../timer/presentation/widgets/circular_timer.dart';
import '../../friends/presentation/friends_screen.dart';

class CollabTimerScreen extends StatefulWidget {
  final BlockModel          block;
  final List<FriendModel>   friends; // teman yang ikut sesi ini

  const CollabTimerScreen({
    super.key,
    required this.block,
    required this.friends,
  });

  @override
  State<CollabTimerScreen> createState() => _CollabTimerScreenState();
}

class _CollabTimerScreenState extends State<CollabTimerScreen> {
  // Status dummy per teman — dalam produksi ini datang dari Firestore/socket
  late final Map<String, _FriendStatus> _friendStatus;

  @override
  void initState() {
    super.initState();

    // Inisialisasi status awal setiap teman (simulasi)
    _friendStatus = {
      for (final f in widget.friends)
        f.id: _FriendStatus.focusing,
    };

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TimerProvider>().startBlock(widget.block);

      // Simulasi: setelah 5 detik salah satu teman pause (dummy)
      Future.delayed(const Duration(seconds: 5), () {
        if (mounted && widget.friends.length > 1) {
          setState(() {
            _friendStatus[widget.friends[1].id] = _FriendStatus.paused;
          });
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.navy,
      appBar: AppBar(
        backgroundColor: AppColors.navy,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.keyboard_arrow_down,
              color: AppColors.textSecondary, size: 28),
          onPressed: () => _confirmExit(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(widget.block.subject, style: AppTypography.h4),
            Text(
              'Sesi bersama ${widget.friends.length} teman',
              style: AppTypography.caption.copyWith(color: AppColors.teal),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: Consumer<TimerProvider>(
        builder: (context, provider, _) {
          final state = provider.timerState;
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 12),

                  // ── Label fase ──────────────────────────
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: _phaseColor(state.phase).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(99),
                      border: Border.all(
                          color: _phaseColor(state.phase).withOpacity(0.4)),
                    ),
                    child: Text(
                      state.phaseLabel,
                      style: AppTypography.label.copyWith(
                          color: _phaseColor(state.phase),
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // ── Circular timer (identik TimerScreen) ─
                  CircularTimer(
                    progress:     state.progress,
                    displayTime:  state.displayTime,
                    sessionCount: state.sessionCount,
                    phase:        state.phase,
                    color:        _phaseColor(state.phase),
                  ),
                  const SizedBox(height: 20),

                  // ── Nama sesi ───────────────────────────
                  Text(widget.block.sessionName,
                      style: AppTypography.bodyMuted,
                      textAlign: TextAlign.center),
                  const SizedBox(height: 8),

                  // ── Session dots ────────────────────────
                  _SessionDots(
                    current: state.sessionCount,
                    total:   AppConstants.sessionsBeforeLongBreak,
                  ),

                  const SizedBox(height: 20),

                  // ── Panel teman (ini yang baru) ─────────
                  _CollabPanel(
                    friends:      widget.friends,
                    friendStatus: _friendStatus,
                  ),

                  const Spacer(),

                  // ── Kontrol tombol (identik TimerScreen) ─
                  _CollabTimerControls(provider: provider),
                  const SizedBox(height: 28),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Color _phaseColor(TimerPhase phase) {
    return switch (phase) {
      TimerPhase.focus      => AppColors.teal,
      TimerPhase.shortBreak => AppColors.amber,
      TimerPhase.longBreak  => AppColors.coral,
    };
  }

  Future<void> _confirmExit(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text('Keluar dari sesi?', style: AppTypography.h4),
        content: Text(
            'Sesi yang sedang berjalan akan dicatat sebagai missed.',
            style: AppTypography.bodyMuted),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batalkan',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Keluar',
                style: TextStyle(color: AppColors.coral)),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) Navigator.pop(context);
  }
}

// ─────────────────────────────────────────────────────────────
// Panel status teman — KOMPONEN BARU
// ─────────────────────────────────────────────────────────────

enum _FriendStatus { focusing, paused, done }

class _CollabPanel extends StatelessWidget {
  final List<FriendModel>           friends;
  final Map<String, _FriendStatus>  friendStatus;

  const _CollabPanel({
    required this.friends,
    required this.friendStatus,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color:        AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border:       Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header panel
          Row(
            children: [
              const Icon(Icons.people_outline,
                  color: AppColors.teal, size: 15),
              const SizedBox(width: 6),
              Text(
                'Belajar bersama',
                style: AppTypography.label.copyWith(color: AppColors.teal),
              ),
              const Spacer(),
              // Indikator jumlah yang sedang fokus
              Text(
                '${friends.where((f) => friendStatus[f.id] == _FriendStatus.focusing).length}/${friends.length} fokus',
                style: AppTypography.caption,
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Daftar teman
          ...friends.map((f) {
            final status = friendStatus[f.id] ?? _FriendStatus.focusing;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _FriendTile(friend: f, status: status),
            );
          }),
        ],
      ),
    );
  }
}

class _FriendTile extends StatelessWidget {
  final FriendModel   friend;
  final _FriendStatus status;

  const _FriendTile({required this.friend, required this.status});

  @override
  Widget build(BuildContext context) {
    final (color, label, icon) = switch (status) {
      _FriendStatus.focusing => (AppColors.teal,  'Fokus',   Icons.radio_button_on),
      _FriendStatus.paused   => (AppColors.amber,  'Pause',   Icons.pause_circle_outline),
      _FriendStatus.done     => (AppColors.surface3,'Selesai', Icons.check_circle_outline),
    };

    return Row(
      children: [
        // Avatar emoji
        Container(
          width: 34, height: 34,
          decoration: BoxDecoration(
            color:        color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(99),
            border:       Border.all(color: color.withOpacity(0.35)),
          ),
          alignment: Alignment.center,
          child: Text(friend.avatar,
              style: const TextStyle(fontSize: 16)),
        ),
        const SizedBox(width: 10),

        // Nama
        Expanded(
          child: Text(
            friend.name.split(' ').first,
            style: AppTypography.h4.copyWith(fontSize: 13),
            overflow: TextOverflow.ellipsis,
          ),
        ),

        // Status chip
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color:        color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(99),
            border:       Border.all(color: color.withOpacity(0.30)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 11, color: color),
              const SizedBox(width: 4),
              Text(label,
                  style: AppTypography.label.copyWith(
                      color: color, fontSize: 11)),
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Session dots — sama dengan TimerScreen
// ─────────────────────────────────────────────────────────────

class _SessionDots extends StatelessWidget {
  final int current;
  final int total;
  const _SessionDots({required this.current, required this.total});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(total, (i) {
        final isDone   = i < current;
        final isActive = i == current;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width:  isActive ? 16 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: isDone
                ? AppColors.tealDim
                : isActive
                    ? AppColors.teal
                    : AppColors.surface3,
            borderRadius: BorderRadius.circular(99),
          ),
        );
      }),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Kontrol timer — sama dengan TimerScreen
// ─────────────────────────────────────────────────────────────

class _CollabTimerControls extends StatelessWidget {
  final TimerProvider provider;
  const _CollabTimerControls({required this.provider});

  @override
  Widget build(BuildContext context) {
    final isRunning = provider.timerState.isRunning;
    final isPaused  = provider.timerState.isPaused;

    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              provider.completeBlock();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16)),
            child: const Text('Tandai Selesai'),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: isRunning ? provider.pause : provider.resume,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textPrimary,
                  side: const BorderSide(color: AppColors.border),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: Text(
                  isRunning ? 'Pause' : isPaused ? 'Lanjutkan' : 'Mulai',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton(
                onPressed: provider.skip,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textSecondary,
                  side: const BorderSide(color: AppColors.border),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: Text('Lewati',
                    style:
                        GoogleFonts.poppins(fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
