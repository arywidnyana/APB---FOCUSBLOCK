// =============================================================
// FILE: lib/features/report/presentation/report_screen.dart
// TANGGUNG JAWAB: Layar laporan — menampilkan consistency score,
//   perbandingan rencana vs aktual, bar chart per mata kuliah,
//   dan daftar missed blocks.
// =============================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import '../provider/report_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/models/daily_summary_model.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReportProvider>().loadReport();
    });
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.navy,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: Text('Laporan Aktivitas', style: AppTypography.h3),
        bottom: TabBar(
          controller: _tabs,
          labelColor: AppColors.teal,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.teal,
          indicatorSize: TabBarIndicatorSize.label,
          labelStyle: GoogleFonts.poppins(
            fontWeight: FontWeight.w600, fontSize: 13),
          tabs: const [
            Tab(text: 'Hari ini'),
            Tab(text: 'Minggu ini'),
          ],
        ),
      ),
      body: Consumer<ReportProvider>(
        builder: (context, provider, _) {
          if (provider.loading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.teal));
          }

          return TabBarView(
            controller: _tabs,
            children: [
              _DailyTab(provider: provider),
              _WeeklyTab(provider: provider),
            ],
          );
        },
      ),
    );
  }
}

// ─── Tab Harian ──────────────────────────────────────────────

class _DailyTab extends StatelessWidget {
  final ReportProvider provider;
  const _DailyTab({required this.provider});

  @override
  Widget build(BuildContext context) {
    final s = provider.dailySummary;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // Score + rencana vs aktual
        Row(
          children: [
            Expanded(child: _ScoreCard(summary: s)),
            const SizedBox(width: 12),
            Expanded(child: _VsCard(summary: s)),
          ],
        ),
        const SizedBox(height: 16),

        // Missed blocks
        if (provider.missedBlocks.isNotEmpty) ...[
          Text('Blok yang terlewat',
            style: AppTypography.h4.copyWith(color: AppColors.coral)),
          const SizedBox(height: 12),
          ...provider.missedBlocks.map((b) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.coralDim),
              ),
              child: Row(
                children: [
                  Container(
                    width: 3, height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.coral,
                      borderRadius: BorderRadius.circular(99)),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(b.subject,
                        style: AppTypography.h4.copyWith(fontSize: 13)),
                      const SizedBox(height: 3),
                      Text(b.sessionName,
                        style: AppTypography.caption),
                    ],
                  ),
                ],
              ),
            ),
          )),
        ],
      ],
    );
  }
}

// ─── Tab Mingguan ─────────────────────────────────────────────

class _WeeklyTab extends StatelessWidget {
  final ReportProvider provider;
  const _WeeklyTab({required this.provider});

  @override
  Widget build(BuildContext context) {
    final subjects = provider.subjectMinutes;
    final maxMin   = subjects.values.isEmpty
        ? 1
        : subjects.values.reduce((a, b) => a > b ? a : b);

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text('Jam belajar per mata kuliah',
          style: AppTypography.h4),
        const SizedBox(height: 16),

        // Bar chart per subject
        if (subjects.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Text('Belum ada data minggu ini',
                style: AppTypography.bodyMuted),
            ),
          )
        else
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: subjects.entries.map((e) {
                final pct = e.value / maxMin;
                final jam = e.value ~/ 60;
                final min = e.value % 60;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 88,
                        child: Text(
                          e.key,
                          style: AppTypography.caption,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(99),
                          child: LinearProgressIndicator(
                            value: pct,
                            minHeight: 8,
                            backgroundColor: AppColors.surface3,
                            valueColor: const AlwaysStoppedAnimation(
                              AppColors.teal),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 40,
                        child: Text(
                          jam > 0 ? '${jam}j${min}m' : '${min}m',
                          style: AppTypography.mono.copyWith(fontSize: 11),
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }
}

// ─── Card widgets ─────────────────────────────────────────────

class _ScoreCard extends StatelessWidget {
  final DailySummaryModel? summary;
  const _ScoreCard({this.summary});

  @override
  Widget build(BuildContext context) {
    final score = summary?.consistencyScore ?? 0.0;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Text(
            score.toStringAsFixed(0),
            style: AppTypography.scoreHuge,
          ),
          const SizedBox(height: 4),
          Text('%', style: AppTypography.bodyMuted),
          const SizedBox(height: 8),
          Text(
            AppConstants.scoreLabel(score),
            style: AppTypography.caption.copyWith(
              color: AppColors.teal, fontWeight: FontWeight.w600),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _VsCard extends StatelessWidget {
  final DailySummaryModel? summary;
  const _VsCard({this.summary});

  @override
  Widget build(BuildContext context) {
    final s = summary;
    final planHour = ((s?.totalPlanned ?? 0) * 30) ~/ 60;
    final planMin  = ((s?.totalPlanned ?? 0) * 30) % 60;
    final actHour  = (s?.totalActualMinutes ?? 0) ~/ 60;
    final actMin   = (s?.totalActualMinutes ?? 0) % 60;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Rencana vs aktual',
            style: AppTypography.caption.copyWith(fontWeight: FontWeight.w500)),
          const SizedBox(height: 12),
          _VsRow(
            label: 'Waktu',
            plan:  '${planHour}j${planMin}m',
            actual:'${actHour}j${actMin}m',
          ),
          _VsRow(
            label: 'Selesai',
            plan:  '${s?.totalPlanned ?? 0}',
            actual:'${s?.totalDone ?? 0}',
          ),
          _VsRow(
            label: 'Missed',
            plan:  '0',
            actual:'${s?.totalMissed ?? 0}',
            actualColor: AppColors.coral,
          ),
        ],
      ),
    );
  }
}

class _VsRow extends StatelessWidget {
  final String label;
  final String plan;
  final String actual;
  final Color  actualColor;

  const _VsRow({
    required this.label,
    required this.plan,
    required this.actual,
    this.actualColor = AppColors.teal,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTypography.caption),
          Row(
            children: [
              Text(plan,
                style: AppTypography.mono.copyWith(
                  color: AppColors.textSecondary)),
              const Text(' → ',
                style: TextStyle(color: AppColors.textTertiary, fontSize: 12)),
              Text(actual,
                style: AppTypography.mono.copyWith(color: actualColor)),
            ],
          ),
        ],
      ),
    );
  }
}
