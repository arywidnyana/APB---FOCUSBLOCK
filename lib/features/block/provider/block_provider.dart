// FILE: lib/features/block/provider/block_provider.dart
import 'package:flutter/foundation.dart';
import '../../../data/models/block_model.dart';
import '../../../data/repositories/block_repository.dart';
import '../../../core/constants/app_constants.dart';
import '../../../logic/notification_service.dart';

class BlockProvider extends ChangeNotifier {
  final BlockRepository _repo = BlockRepository();
  bool _saving = false;
  String? _error;

  bool get saving => _saving;
  String? get error => _error;

  Future<bool> saveBlock({
    required String subject, required String sessionName,
    required DateTime startTime, required int plannedDuration,
  }) async {
    if (subject.isEmpty || sessionName.isEmpty) {
      _error = 'Semua field wajib diisi';
      notifyListeners();
      return false;
    }
    _saving = true; _error = null;
    notifyListeners();
    try {
      final now = DateTime.now();
      final date = '${startTime.year}-${startTime.month.toString().padLeft(2,'0')}-${startTime.day.toString().padLeft(2,'0')}';
      final block = BlockModel(
        subject: subject, sessionName: sessionName,
        startTime: startTime.toIso8601String(),
        plannedDuration: plannedDuration, status: AppConstants.statusPending,
        date: date, createdAt: now.toIso8601String(),
      );
      final id = await _repo.insertBlock(block);

      // Jadwalkan notifikasi pengingat 10 menit sebelum blok mulai
      final reminderTime = startTime.subtract(const Duration(minutes: 10));
      await NotificationService.instance.scheduleReminder(
        id: id.hashCode,
        title: 'Blok belajar segera dimulai',
        body: '$subject — $sessionName dimulai 10 menit lagi',
        scheduledTime: reminderTime,
      );

      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _saving = false;
      notifyListeners();
    }
  }
}
