// =============================================================
// FILE: lib/data/models/block_model.dart
// TANGGUNG JAWAB: Model data untuk satu blok waktu belajar.
//   Menyediakan fromMap() untuk baca dari SQLite dan
//   toMap() untuk tulis ke SQLite.
// =============================================================

import '../../core/constants/app_constants.dart';

class BlockModel {
  final int?   id;
  final String subject;
  final String sessionName;
  final String startTime;       // ISO8601: "2026-04-19T08:00:00"
  final int    plannedDuration; // menit
  final int?   actualDuration;  // menit, diisi setelah selesai
  final String status;          // pending | ongoing | done | missed
  final String date;            // "2026-04-19"
  final String createdAt;

  const BlockModel({
    this.id,
    required this.subject,
    required this.sessionName,
    required this.startTime,
    required this.plannedDuration,
    this.actualDuration,
    this.status = AppConstants.statusPending,
    required this.date,
    required this.createdAt,
  });

  // Buat BlockModel dari row SQLite
  factory BlockModel.fromMap(Map<String, dynamic> map) {
    return BlockModel(
      id:              map['id'] as int?,
      subject:         map['subject'] as String,
      sessionName:     map['session_name'] as String,
      startTime:       map['start_time'] as String,
      plannedDuration: map['planned_duration'] as int,
      actualDuration:  map['actual_duration'] as int?,
      status:          map['status'] as String,
      date:            map['date'] as String,
      createdAt:       map['created_at'] as String,
    );
  }

  // Konversi ke Map untuk ditulis ke SQLite
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'subject':          subject,
      'session_name':     sessionName,
      'start_time':       startTime,
      'planned_duration': plannedDuration,
      'actual_duration':  actualDuration,
      'status':           status,
      'date':             date,
      'created_at':       createdAt,
    };
  }

  // Buat salinan dengan field yang diubah (immutable update)
  BlockModel copyWith({
    int?    id,
    String? subject,
    String? sessionName,
    String? startTime,
    int?    plannedDuration,
    int?    actualDuration,
    String? status,
    String? date,
    String? createdAt,
  }) {
    return BlockModel(
      id:              id              ?? this.id,
      subject:         subject         ?? this.subject,
      sessionName:     sessionName     ?? this.sessionName,
      startTime:       startTime       ?? this.startTime,
      plannedDuration: plannedDuration ?? this.plannedDuration,
      actualDuration:  actualDuration  ?? this.actualDuration,
      status:          status          ?? this.status,
      date:            date            ?? this.date,
      createdAt:       createdAt       ?? this.createdAt,
    );
  }

  @override
  String toString() =>
    'BlockModel(id: $id, subject: $subject, status: $status, date: $date)';
}
