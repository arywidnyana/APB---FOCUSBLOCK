// =============================================================
// FILE: lib/features/timer/provider/timer_provider.dart
// VERSI: DUMMY — tanpa database, untuk testing frontend
// =============================================================

import 'package:flutter/foundation.dart';
import '../../../logic/timer_controller.dart';
import '../../../data/models/block_model.dart';
import '../../../core/constants/app_constants.dart';

class TimerProvider extends ChangeNotifier {
  final TimerController _ctrl = TimerController();
  BlockModel? _activeBlock;

  BlockModel? get activeBlock => _activeBlock;
  TimerState  get timerState  => _ctrl.state;

  TimerProvider() {
    _ctrl.onTick          = (_) => notifyListeners();
    _ctrl.onPhaseComplete = _onPhaseComplete;
  }

  Future<void> startBlock(BlockModel block) async {
    _activeBlock = block;
    _ctrl.reset();
    _ctrl.start();
    notifyListeners();
  }

  void pause()  => _ctrl.pause();
  void resume() => _ctrl.resume();
  void skip()   => _ctrl.skip();

  Future<void> completeBlock() async {
    _ctrl.complete();
    _activeBlock = null;
    notifyListeners();
  }

  Future<void> _onPhaseComplete(TimerPhase phase) async {
    // dummy — tidak simpan ke database
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }
}