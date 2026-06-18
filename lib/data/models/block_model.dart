// FILE: lib/data/models/block_model.dart
class BlockModel {
  final String? id;
  final String  subject;
  final String  sessionName;
  final String  startTime;
  final int     plannedDuration;
  final int?    actualDuration;
  final String  status;
  final String  date;
  final String  createdAt;

  const BlockModel({
    this.id,
    required this.subject,
    required this.sessionName,
    required this.startTime,
    required this.plannedDuration,
    this.actualDuration,
    this.status = 'pending',
    required this.date,
    required this.createdAt,
  });

  factory BlockModel.fromMap(Map<String, dynamic> map) => BlockModel(
    id:              map['id'] as String?,
    subject:         map['subject']          as String,
    sessionName:     map['session_name']     as String,
    startTime:       map['start_time']       as String,
    plannedDuration: map['planned_duration'] as int,
    actualDuration:  map['actual_duration']  as int?,
    status:          map['status']           as String? ?? 'pending',
    date:            map['date']             as String,
    createdAt:       map['created_at']       as String? ?? '',
  );

  Map<String, dynamic> toMap() => {
    'subject':          subject,
    'session_name':     sessionName,
    'start_time':       startTime,
    'planned_duration': plannedDuration,
    'actual_duration':  actualDuration,
    'status':           status,
    'date':             date,
    'created_at':       createdAt,
  };

  BlockModel copyWith({
    String? id, String? subject, String? sessionName, String? startTime,
    int? plannedDuration, int? actualDuration, String? status,
    String? date, String? createdAt,
  }) => BlockModel(
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
