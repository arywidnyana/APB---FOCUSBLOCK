// FILE: lib/features/home/provider/home_provider.dart
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../data/models/block_model.dart';
import '../../../data/repositories/block_repository.dart';
import '../../../core/constants/app_constants.dart';

enum BlockFilter { all, thisWeek, thisMonth }

class HomeProvider extends ChangeNotifier {
  final BlockRepository _repo = BlockRepository();

  List<BlockModel> _allBlocks = [];
  BlockFilter _filter = BlockFilter.all;
  bool _loading = false;
  String? _error;

  List<BlockModel> get allBlocks => _allBlocks;
  BlockFilter get filter => _filter;
  bool get loading => _loading;
  String? get error => _error;

  List<BlockModel> get filteredBlocks {
    final now = DateTime.now();
    switch (_filter) {
      case BlockFilter.thisWeek:
        final weekStart = now.subtract(Duration(days: now.weekday - 1));
        return _allBlocks.where((b) {
          final d = DateTime.tryParse(b.date);
          return d != null && !d.isBefore(DateTime(weekStart.year, weekStart.month, weekStart.day));
        }).toList();
      case BlockFilter.thisMonth:
        return _allBlocks.where((b) {
          final d = DateTime.tryParse(b.date);
          return d != null && d.year == now.year && d.month == now.month;
        }).toList();
      case BlockFilter.all:
        return _allBlocks;
    }
  }

  int get totalPlanned => filteredBlocks.length;
  int get totalDone => filteredBlocks.where((b) => b.status == AppConstants.statusDone).length;
  int get totalMissed => filteredBlocks.where((b) => b.status == AppConstants.statusMissed).length;
  double get overallScore => totalPlanned == 0 ? 0 : (totalDone / totalPlanned) * 100;
  int get totalActualMinutes => filteredBlocks
      .where((b) => b.actualDuration != null)
      .fold(0, (sum, b) => sum + (b.actualDuration ?? 0));

  String get filterLabel => switch (_filter) {
    BlockFilter.all => 'Semua waktu',
    BlockFilter.thisWeek => 'Minggu ini',
    BlockFilter.thisMonth => 'Bulan ini',
  };

  void setFilter(BlockFilter f) { _filter = f; notifyListeners(); }

  Future<void> loadToday() async {
    if (FirebaseAuth.instance.currentUser == null) return;
    _loading = true; _error = null;
    notifyListeners();
    try {
      _allBlocks = await _repo.getAllBlocks();
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> updateBlockStatus(BlockModel block, String newStatus) async {
    await _repo.updateBlock(block.copyWith(status: newStatus));
    await loadToday();
  }

  Future<void> deleteBlock(String id) async {
    await _repo.deleteBlock(id);
    _allBlocks.removeWhere((b) => b.id == id);
    notifyListeners();
  }
}
