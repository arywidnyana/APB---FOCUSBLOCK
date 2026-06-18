// FILE: lib/features/timer/provider/timer_provider.dart
import 'package:flutter/foundation.dart';
import '../../../logic/timer_controller.dart';
import '../../../data/models/block_model.dart';
import '../../../data/repositories/block_repository.dart';
import '../../../core/constants/app_constants.dart';
import '../../../logic/notification_service.dart';
import '../../../logic/presence_service.dart';

class TimerProvider extends ChangeNotifier {
  final TimerController _ctrl = TimerController();
  final BlockRepository _repo = BlockRepository();
  BlockModel? _activeBlock;
  DateTime? _sessionStart;

  BlockModel? get activeBlock => _activeBlock;
  TimerState get timerState => _ctrl.state;

  TimerProvider() {
    _ctrl.onTick = (_) => notifyListeners();
    _ctrl.onPhaseComplete = _onPhaseComplete;
  }

  Future<void> startBlock(BlockModel block) async {
    _activeBlock = block;
    _sessionStart = DateTime.now();
    await _repo.updateBlock(block.copyWith(status: AppConstants.statusOngoing));
    await PresenceService.instance.setStudying(); // ← teman bisa lihat status "sedang belajar"
    _ctrl.reset();
    _ctrl.start();
    notifyListeners();
  }

  void pause() => _ctrl.pause();
  void resume() => _ctrl.resume();
  void startTimer() => _ctrl.start();
  void skip() => _ctrl.skip();

  Future<void> completeBlock() async {
    _ctrl.complete();
    await _saveBlockDone();
    await PresenceService.instance.setOnline(); // ← kembali jadi "online" biasa
  }

  Future<void> exitTimer() async {
    await PresenceService.instance.setOnline();
  }

  Future<void> _onPhaseComplete(TimerPhase phase) async {
    // Notifikasi instan setiap fase selesai — fokus atau istirahat
    await _notifyPhaseComplete(phase);
    if (phase == TimerPhase.focus) await _saveBlockDone();
  }

  Future<void> _notifyPhaseComplete(TimerPhase phase) async {
    final (title, body) = switch (phase) {
      TimerPhase.focus => (
        'Sesi fokus selesai! 🎉',
        'Waktunya istirahat sebentar sebelum lanjut sesi berikutnya'
      ),
      TimerPhase.shortBreak => (
        'Istirahat selesai',
        'Siap untuk fokus lagi? Ayo mulai sesi berikutnya'
      ),
      TimerPhase.longBreak => (
        'Istirahat panjang selesai',
        'Kamu sudah menyelesaikan 4 sesi fokus, hebat! Lanjut lagi yuk'
      ),
    };
    await NotificationService.instance.showInstant(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: title, body: body,
    );
  }

  Future<void> _saveBlockDone() async {
    if (_activeBlock == null) return;
    final actualMin = _sessionStart != null
        ? DateTime.now().difference(_sessionStart!).inMinutes
        : _activeBlock!.plannedDuration;
    await _repo.updateBlock(_activeBlock!.copyWith(
      status: AppConstants.statusDone, actualDuration: actualMin));
    _activeBlock = null;
    _sessionStart = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }
}
