// =============================================================
// FILE: lib/data/models/session_model.dart
// TANGGUNG JAWAB: Model untuk satu sesi Pomodoro yang berjalan.
// =============================================================

class SessionModel {
  final int?   id;
  final int    blockId;
  final String startedAt;
  final String? endedAt;
  final int?   actualMinutes;
  final String phase; // focus | short_break | long_break

  const SessionModel({
    this.id,
    required this.blockId,
    required this.startedAt,
    this.endedAt,
    this.actualMinutes,
    required this.phase,
  });

  factory SessionModel.fromMap(Map<String, dynamic> map) => SessionModel(
    id:            map['id'] as int?,
    blockId:       map['block_id'] as int,
    startedAt:     map['started_at'] as String,
    endedAt:       map['ended_at'] as String?,
    actualMinutes: map['actual_minutes'] as int?,
    phase:         map['phase'] as String,
  );

  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'block_id':       blockId,
    'started_at':     startedAt,
    'ended_at':       endedAt,
    'actual_minutes': actualMinutes,
    'phase':          phase,
  };

  SessionModel copyWith({
    int?    id,
    int?    blockId,
    String? startedAt,
    String? endedAt,
    int?    actualMinutes,
    String? phase,
  }) => SessionModel(
    id:            id            ?? this.id,
    blockId:       blockId       ?? this.blockId,
    startedAt:     startedAt     ?? this.startedAt,
    endedAt:       endedAt       ?? this.endedAt,
    actualMinutes: actualMinutes ?? this.actualMinutes,
    phase:         phase         ?? this.phase,
  );
}
