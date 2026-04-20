// =============================================================
// FILE: lib/data/local/database_helper.dart
// TANGGUNG JAWAB: Inisialisasi SQLite, membuat tabel, dan
//   menyediakan instance database (singleton). Semua akses
//   database dilakukan lewat class ini.
// =============================================================

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../core/constants/app_constants.dart';

class DatabaseHelper {
  DatabaseHelper._();
  static final DatabaseHelper instance = DatabaseHelper._();

  Database? _db;

  Future<Database> get database async {
    _db ??= await _initDB();
    return _db!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path   = join(dbPath, AppConstants.dbName);

    return await openDatabase(
      path,
      version: AppConstants.dbVersion,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // === Tabel blocks ===
    // Menyimpan setiap blok waktu belajar yang dibuat pengguna
    await db.execute('''
      CREATE TABLE ${AppConstants.tableBlocks} (
        id               INTEGER PRIMARY KEY AUTOINCREMENT,
        subject          TEXT    NOT NULL,
        session_name     TEXT    NOT NULL,
        start_time       TEXT    NOT NULL,
        planned_duration INTEGER NOT NULL,
        actual_duration  INTEGER,
        status           TEXT    NOT NULL DEFAULT '${AppConstants.statusPending}',
        date             TEXT    NOT NULL,
        created_at       TEXT    NOT NULL
      )
    ''');

    // === Tabel sessions ===
    // Log setiap sesi Pomodoro yang berjalan, terhubung ke blocks
    await db.execute('''
      CREATE TABLE ${AppConstants.tableSessions} (
        id             INTEGER PRIMARY KEY AUTOINCREMENT,
        block_id       INTEGER NOT NULL REFERENCES ${AppConstants.tableBlocks}(id),
        started_at     TEXT    NOT NULL,
        ended_at       TEXT,
        actual_minutes INTEGER,
        phase          TEXT    NOT NULL DEFAULT '${AppConstants.phaseFocus}'
      )
    ''');

    // === Tabel daily_summary ===
    // Ringkasan harian yang di-generate otomatis oleh ReportGenerator
    await db.execute('''
      CREATE TABLE ${AppConstants.tableSummary} (
        id                   INTEGER PRIMARY KEY AUTOINCREMENT,
        date                 TEXT    UNIQUE NOT NULL,
        total_planned        INTEGER NOT NULL DEFAULT 0,
        total_done           INTEGER NOT NULL DEFAULT 0,
        total_missed         INTEGER NOT NULL DEFAULT 0,
        consistency_score    REAL    NOT NULL DEFAULT 0,
        total_actual_minutes INTEGER NOT NULL DEFAULT 0
      )
    ''');
  }
}
