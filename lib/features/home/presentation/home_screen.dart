// =============================================================
// FILE: lib/features/home/presentation/home_screen.dart
// TANGGUNG JAWAB: Layar utama — menampilkan consistency score
//   harian dan daftar blok hari ini dalam format timeline.
// =============================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/home_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
// ignore: unused_import
import '../../../core/constants/app_constants.dart';
import '../../../data/models/block_model.dart';
import 'widgets/timeline_block_card.dart';
import 'widgets/daily_summary_bar.dart';
import '../../block/presentation/add_block_screen.dart';
import '../../timer/presentation/timer_screen.dart';
import '../../../data/repositories/block_repository.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
void initState() {
  super.initState();
  WidgetsBinding.instance.addPostFrameCallback((_) async {
    // ← Tambah dummy data untuk testing
    final repo = BlockRepository();
    final now  = DateTime.now();
    final date = '${now.year}-${now.month.toString().padLeft(2,'0')}-${now.day.toString().padLeft(2,'0')}';

    await repo.insertBlock(BlockModel(
      subject:         'Pemrograman Mobile',
      sessionName:     'Implementasi Flutter widget',
      startTime:       now.toIso8601String(),
      plannedDuration: 25,
      status:          'pending',
      date:            date,
      createdAt:       now.toIso8601String(),
    ));

    await repo.insertBlock(BlockModel(
      subject:         'Kalkulus',
      sessionName:     'Latihan soal integral',
      startTime:       now.add(const Duration(hours: 1)).toIso8601String(),
      plannedDuration: 45,
      status:          'pending',
      date:            date,
      createdAt:       now.toIso8601String(),
    ));

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
                _buildAppBar(),
                if (provider.loading)
                  const SliverFillRemaining(
                    child: Center(
                      child: CircularProgressIndicator(color: AppColors.teal),
                    ),
                  )
                else ...[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                      child: DailySummaryBar(summary: provider.summary),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Blok hari ini', style: AppTypography.h4),
                          Text(
                            '${provider.blocks.length} blok',
                            style: AppTypography.caption,
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (provider.blocks.isEmpty)
                    SliverToBoxAdapter(child: _buildEmptyState())
                  else
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, i) => Padding(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                          child: TimelineBlockCard(
                            block: provider.blocks[i],
                            onStart: () => _startBlock(provider.blocks[i]),
                            onDelete: () =>
                                provider.deleteBlock(provider.blocks[i].id!),
                          ),
                        ),
                        childCount: provider.blocks.length,
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
        onPressed: _openAddBlock,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildAppBar() {
    final greeting = _greetingText();
    final now = DateTime.now();
    final days = [
      'Minggu',
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu',
    ];
    final months = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Ags',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    final dateStr =
        '${days[now.weekday % 7]}, ${now.day} ${months[now.month]} ${now.year}';

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
          icon: const Icon(
            Icons.notifications_none,
            color: AppColors.textSecondary,
          ),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 40),
      child: Column(
        children: [
          const Icon(
            Icons.calendar_today_outlined,
            size: 48,
            color: AppColors.textTertiary,
          ),
          const SizedBox(height: 16),
          Text(
            'Belum ada blok hari ini',
            style: AppTypography.h4.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Tap tombol + untuk mulai merencanakan sesi belajarmu',
            style: AppTypography.caption,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _greetingText() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Selamat pagi';
    if (hour < 17) return 'Selamat siang';
    return 'Selamat malam';
  }

  void _startBlock(BlockModel block) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => TimerScreen(block: block)),
    ).then((_) => context.read<HomeProvider>().loadToday());
  }

  void _openAddBlock() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddBlockScreen()),
    ).then((_) => context.read<HomeProvider>().loadToday());
  }
}
