// FILE: lib/logic/timer_controller.dart
import 'dart:async';
import '../core/constants/app_constants.dart';

enum TimerPhase { focus, shortBreak, longBreak }

class TimerState {
  final TimerPhase phase;
  final int remainingSeconds;
  final int sessionCount;
  final bool isRunning;
  final bool isPaused;

  const TimerState({
    required this.phase, required this.remainingSeconds,
    required this.sessionCount, required this.isRunning, required this.isPaused,
  });

  TimerState copyWith({
    TimerPhase? phase, int? remainingSeconds, int? sessionCount,
    bool? isRunning, bool? isPaused,
  }) => TimerState(
    phase: phase ?? this.phase,
    remainingSeconds: remainingSeconds ?? this.remainingSeconds,
    sessionCount: sessionCount ?? this.sessionCount,
    isRunning: isRunning ?? this.isRunning,
    isPaused: isPaused ?? this.isPaused,
  );

  double get progress {
    final total = _totalSecondsForPhase(phase);
    return 1.0 - (remainingSeconds / total);
  }

  String get displayTime {
    final m = (remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final s = (remainingSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  String get phaseLabel {
    switch (phase) {
      case TimerPhase.focus: return 'Sesi Fokus';
      case TimerPhase.shortBreak: return 'Istirahat Pendek';
      case TimerPhase.longBreak: return 'Istirahat Panjang';
    }
  }
}

int _totalSecondsForPhase(TimerPhase phase) {
  switch (phase) {
    case TimerPhase.focus: return AppConstants.defaultFocusDuration * 60;
    case TimerPhase.shortBreak: return AppConstants.defaultShortBreak * 60;
    case TimerPhase.longBreak: return AppConstants.defaultLongBreak * 60;
  }
}

class TimerController {
  Timer? _timer;
  TimerState _state = TimerState(
    phase: TimerPhase.focus,
    remainingSeconds: AppConstants.defaultFocusDuration * 60,
    sessionCount: 0, isRunning: false, isPaused: false,
  );

  TimerState get state => _state;
  void Function(TimerState)? onTick;
  void Function(TimerPhase completedPhase)? onPhaseComplete;

  void start() {
    if (_state.isRunning) return;
    _state = _state.copyWith(isRunning: true, isPaused: false);
    _timer = Timer.periodic(const Duration(seconds: 1), _tick);
    onTick?.call(_state);
  }

  void pause() {
    _timer?.cancel();
    _state = _state.copyWith(isRunning: false, isPaused: true);
    onTick?.call(_state);
  }

  void resume() { if (_state.isPaused) start(); }
  void skip() { _timer?.cancel(); _advancePhase(); }

  void complete() {
    _timer?.cancel();
    onPhaseComplete?.call(_state.phase);
    _advancePhase();
  }

  void reset() {
    _timer?.cancel();
    _state = TimerState(
      phase: TimerPhase.focus,
      remainingSeconds: AppConstants.defaultFocusDuration * 60,
      sessionCount: 0, isRunning: false, isPaused: false,
    );
    onTick?.call(_state);
  }

  void dispose() => _timer?.cancel();

  void _tick(Timer t) {
    if (_state.remainingSeconds <= 1) {
      t.cancel();
      onPhaseComplete?.call(_state.phase);
      _advancePhase();
    } else {
      _state = _state.copyWith(remainingSeconds: _state.remainingSeconds - 1);
      onTick?.call(_state);
    }
  }

  void _advancePhase() {
    int newCount = _state.sessionCount;
    TimerPhase nextPhase;
    if (_state.phase == TimerPhase.focus) {
      newCount++;
      nextPhase = (newCount % AppConstants.sessionsBeforeLongBreak == 0)
          ? TimerPhase.longBreak : TimerPhase.shortBreak;
    } else {
      nextPhase = TimerPhase.focus;
    }
    _state = TimerState(
      phase: nextPhase,
      remainingSeconds: _totalSecondsForPhase(nextPhase),
      sessionCount: newCount, isRunning: false, isPaused: false,
    );
    onTick?.call(_state);
  }
}
