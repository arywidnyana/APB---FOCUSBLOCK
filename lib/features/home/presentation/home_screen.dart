// =============================================================
// FILE: lib/features/home/presentation/home_screen.dart
// TANGGUNG JAWAB: Layar utama — riwayat keseluruhan blok dengan
//   filter periode + overall score akumulatif.
//   Score di sini = keseluruhan, bukan harian (harian ada di Laporan).
// =============================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../provider/home_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/models/block_model.dart';
import '../../block/presentation/add_block_screen.dart';
import '../../timer/presentation/timer_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeProvider>().loadToday();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.navy,
      body: Consumer<HomeProvider>(
        builder: (context, provider, _) {
          return RefreshIndicator(
            color: AppColors.teal,
            backgroundColor: AppColors.surface,
            onRefresh: provider.loadToday,
            child: CustomScrollView(
              slivers: [
                _buildAppBar(provider),
                if (provider.loading)
                  const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator(color: AppColors.teal)))
                else ...[
                  // Overall score card
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                      child: _OverallScoreCard(provider: provider),
                    ),
                  ),

                  // Filter chips
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                      child: _FilterBar(provider: provider),
                    ),
                  ),

                  // Section header riwayat
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Riwayat blok', style: AppTypography.h4),
                          Text(
                            '${provider.filteredBlocks.length} blok',
                            style: AppTypography.caption),
                        ],
                      ),
                    ),
                  ),

                  // List riwayat blok
                  if (provider.filteredBlocks.isEmpty)
                    SliverToBoxAdapter(child: _buildEmptyState())
                  else
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, i) {
                          final block = provider.filteredBlocks[i];
                          // Tampilkan date separator
                          final showDate = i == 0 ||
                            provider.filteredBlocks[i - 1].date != block.date;
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (showDate)
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 6),
                                  child: Text(
                                    _formatDateLabel(block.date),
                                    style: AppTypography.label.copyWith(
                                      color: AppColors.textSecondary)),
                                ),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                                child: _HistoryBlockCard(
                                  block: block,
                                  onStart: () => _startBlock(block),
                                  onDelete: () => provider.deleteBlock(block.id!),
                                ),
                              ),
                            ],
                          );
                        },
                        childCount: provider.filteredBlocks.length,
                      ),
                    ),
                  const SliverToBoxAdapter(child: SizedBox(height: 100)),
                ],
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.teal,
        foregroundColor: AppColors.navy,
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddBlockScreen()),
        ).then((_) => context.read<HomeProvider>().loadToday()),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildAppBar(HomeProvider provider) {
    final hour = DateTime.now().hour;
    final greeting = hour < 12 ? 'Selamat pagi' : hour < 17 ? 'Selamat siang' : 'Selamat malam';
    final now = DateTime.now();
    final days = ['Minggu','Senin','Selasa','Rabu','Kamis','Jumat','Sabtu'];
    final months = ['','Jan','Feb','Mar','Apr','Mei','Jun','Jul','Ags','Sep','Okt','Nov','Des'];
    final dateStr = '${days[now.weekday % 7]}, ${now.day} ${months[now.month]} ${now.year}';

    return SliverAppBar(
      backgroundColor: AppColors.surface,
      floating: true,
      pinned: false,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(greeting, style: AppTypography.h3),
          Text(dateStr, style: AppTypography.caption),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_none, color: AppColors.textSecondary),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildEmptyState() => Padding(
    padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 40),
    child: Column(
      children: [
        const Icon(Icons.inbox_outlined, size: 48, color: AppColors.textTertiary),
        const SizedBox(height: 16),
        Text('Belum ada blok di periode ini',
          style: AppTypography.h4.copyWith(color: AppColors.textSecondary),
          textAlign: TextAlign.center),
        const SizedBox(height: 8),
        Text('Tap tombol + untuk mulai merencanakan sesi belajar',
          style: AppTypography.caption, textAlign: TextAlign.center),
      ],
    ),
  );

  String _formatDateLabel(String dateStr) {
    final d = DateTime.tryParse(dateStr);
    if (d == null) return dateStr;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final target = DateTime(d.year, d.month, d.day);

    if (target == today) return 'Hari ini';
    if (target == yesterday) return 'Kemarin';

    final days = ['','Senin','Selasa','Rabu','Kamis','Jumat','Sabtu','Minggu'];
    final months = ['','Jan','Feb','Mar','Apr','Mei','Jun','Jul','Ags','Sep','Okt','Nov','Des'];
    return '${days[d.weekday]}, ${d.day} ${months[d.month]}';
  }

  void _startBlock(BlockModel block) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => TimerScreen(block: block)),
    ).then((_) => context.read<HomeProvider>().loadToday());
  }
}

// ── Overall Score Card ────────────────────────────────────────

class _OverallScoreCard extends StatelessWidget {
  final HomeProvider provider;
  const _OverallScoreCard({required this.provider});

  @override
  Widget build(BuildContext context) {
    final score    = provider.overallScore;
    final progress = provider.totalPlanned == 0
        ? 0.0
        : provider.totalDone / provider.totalPlanned;
    final hours    = provider.totalActualMinutes ~/ 60;
    final mins     = provider.totalActualMinutes % 60;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_graph, size: 14, color: AppColors.teal),
              const SizedBox(width: 6),
              Text('Overall progress — ${provider.filterLabel}',
                style: AppTypography.label.copyWith(color: AppColors.teal)),
            ],
          ),
          const SizedBox(height: 16),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Score besar
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(score.toStringAsFixed(0),
                        style: AppTypography.scoreHuge),
                      Text('%',
                        style: GoogleFonts.poppins(
                          fontSize: 20, fontWeight: FontWeight.w500,
                          color: AppColors.tealMid)),
                    ],
                  ),
                  Text(AppConstants.scoreLabel(score),
                    style: AppTypography.caption.copyWith(
                      color: AppColors.teal, fontWeight: FontWeight.w600)),
                ],
              ),
              const SizedBox(width: 20),

              // Progress & stats
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Blok selesai', style: AppTypography.caption),
                        Text('${provider.totalDone} / ${provider.totalPlanned}',
                          style: AppTypography.caption.copyWith(color: AppColors.teal)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(99),
                      child: LinearProgressIndicator(
                        value: progress.clamp(0.0, 1.0),
                        minHeight: 6,
                        backgroundColor: AppColors.surface3,
                        valueColor: const AlwaysStoppedAnimation(AppColors.teal),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _MiniStat(value: '${provider.totalDone}',
                          label: 'Selesai', color: AppColors.teal),
                        const SizedBox(width: 8),
                        _MiniStat(value: '${provider.totalMissed}',
                          label: 'Missed', color: AppColors.coral),
                        const SizedBox(width: 8),
                        _MiniStat(
                          value: hours > 0 ? '${hours}j${mins}m' : '${mins}m',
                          label: 'Total', color: AppColors.textSecondary),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String value;
  final String label;
  final Color  color;
  const _MiniStat({required this.value, required this.label, required this.color});

  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surface3,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(value, style: GoogleFonts.poppins(
            fontSize: 14, fontWeight: FontWeight.w600, color: color)),
          const SizedBox(height: 2),
          Text(label, style: AppTypography.label.copyWith(fontSize: 10)),
        ],
      ),
    ),
  );
}

// ── Filter Bar ────────────────────────────────────────────────

class _FilterBar extends StatelessWidget {
  final HomeProvider provider;
  const _FilterBar({required this.provider});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: BlockFilter.values.map((f) {
          final isActive = provider.filter == f;
          final label = switch (f) {
            BlockFilter.all       => 'Semua waktu',
            BlockFilter.thisMonth => 'Bulan ini',
            BlockFilter.thisWeek  => 'Minggu ini',
          };
          return GestureDetector(
            onTap: () => provider.setFilter(f),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isActive ? AppColors.teal : AppColors.surface,
                borderRadius: BorderRadius.circular(99),
                border: Border.all(
                  color: isActive ? AppColors.teal : AppColors.border),
              ),
              child: Text(label,
                style: GoogleFonts.poppins(
                  fontSize: 12, fontWeight: FontWeight.w600,
                  color: isActive ? AppColors.navy : AppColors.textSecondary)),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ── History Block Card ─────────────────────────────────────────

class _HistoryBlockCard extends StatelessWidget {
  final BlockModel   block;
  final VoidCallback onStart;
  final VoidCallback onDelete;
  const _HistoryBlockCard({
    required this.block,
    required this.onStart,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = AppColors.statusColor(block.status);
    final startDt     = DateTime.tryParse(block.startTime);
    final startStr    = startDt != null
        ? '${startDt.hour.toString().padLeft(2,'0')}:${startDt.minute.toString().padLeft(2,'0')}'
        : '--:--';

    return Dismissible(
      key: Key('hist_${block.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppColors.coralDim,
          borderRadius: BorderRadius.circular(12)),
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
              Container(
                width: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(12))),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(block.subject, style: AppTypography.h4),
                      const SizedBox(height: 3),
                      Text(block.sessionName,
                        style: AppTypography.bodyMuted.copyWith(fontSize: 12)),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.schedule, size: 11,
                            color: AppColors.textTertiary),
                          const SizedBox(width: 4),
                          Text('$startStr · ${block.plannedDuration} menit rencana',
                            style: AppTypography.mono.copyWith(fontSize: 11)),
                          if (block.actualDuration != null) ...[
                            Text(' · ',
                              style: AppTypography.mono.copyWith(fontSize: 11)),
                            Text('${block.actualDuration} mnt aktual',
                              style: AppTypography.mono.copyWith(
                                fontSize: 11, color: statusColor)),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 12, 14, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _StatusBadge(status: block.status),
                    if (block.status == AppConstants.statusPending ||
                        block.status == AppConstants.statusOngoing) ...[
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: onStart,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.tealDim,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: AppColors.tealMid)),
                          child: Text(
                            block.status == AppConstants.statusOngoing
                                ? 'Lanjutkan' : 'Mulai',
                            style: AppTypography.label.copyWith(
                              color: AppColors.teal,
                              fontWeight: FontWeight.w600)),
                        ),
                      ),
                    ],
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
        color: bg, borderRadius: BorderRadius.circular(99)),
      child: Text(label,
        style: AppTypography.label.copyWith(
          fontSize: 10, color: color, fontWeight: FontWeight.w600)),
    );
  }
}
