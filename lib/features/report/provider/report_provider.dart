// FILE: lib/features/report/provider/report_provider.dart
import 'package:flutter/foundation.dart';
import '../../../data/models/block_model.dart';
import '../../../logic/report_generator.dart';

class ReportProvider extends ChangeNotifier {
  final ReportGenerator _gen = ReportGenerator.instance;
  DailySummaryModel? _dailySummary;
  List<BlockModel> _missedBlocks = [];
  Map<String, int> _subjectMinutes = {};
  bool _loading = false;

  DailySummaryModel? get dailySummary => _dailySummary;
  List<BlockModel> get missedBlocks => _missedBlocks;
  Map<String, int> get subjectMinutes => _subjectMinutes;
  bool get loading => _loading;

  String get todayDate {
    final n = DateTime.now();
    return '${n.year}-${n.month.toString().padLeft(2,'0')}-${n.day.toString().padLeft(2,'0')}';
  }

  Future<void> loadReport() async {
    _loading = true;
    notifyListeners();
    try {
      final now = DateTime.now();
      final weekStart = now.subtract(Duration(days: now.weekday - 1));
      final startDate = '${weekStart.year}-${weekStart.month.toString().padLeft(2,'0')}-${weekStart.day.toString().padLeft(2,'0')}';
      _dailySummary = await _gen.generateDailySummary(todayDate);
      _missedBlocks = await _gen.getMissedBlocks(todayDate);
      _subjectMinutes = await _gen.getSubjectBreakdown(startDate, todayDate);
    } catch (e) {
      debugPrint('ReportProvider error: $e');
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
