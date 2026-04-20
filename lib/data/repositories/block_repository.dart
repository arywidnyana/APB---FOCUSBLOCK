// =============================================================
// FILE: lib/data/repositories/block_repository.dart
// TANGGUNG JAWAB: Semua operasi CRUD untuk tabel blocks dan
//   sessions. Business Logic memanggil repository ini —
//   tidak pernah langsung ke DatabaseHelper.
// =============================================================

import 'package:sqflite/sqflite.dart';
import '../local/database_helper.dart';
import '../models/block_model.dart';
import '../models/session_model.dart';
import '../../core/constants/app_constants.dart';

class BlockRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // ─── Blocks ──────────────────────────────────────────────

  /// Ambil semua blok untuk tanggal tertentu (format: "2026-04-19")
  Future<List<BlockModel>> getBlocksByDate(String date) async {
    final db   = await _dbHelper.database;
    final rows = await db.query(
      AppConstants.tableBlocks,
      where:   'date = ?',
      whereArgs: [date],
      orderBy: 'start_time ASC',
    );
    return rows.map(BlockModel.fromMap).toList();
  }

  /// Ambil blok berdasarkan id
  Future<BlockModel?> getBlockById(int id) async {
    final db   = await _dbHelper.database;
    final rows = await db.query(
      AppConstants.tableBlocks,
      where:     'id = ?',
      whereArgs: [id],
      limit:     1,
    );
    if (rows.isEmpty) return null;
    return BlockModel.fromMap(rows.first);
  }

  /// Simpan blok baru, return id yang baru dibuat
  Future<int> insertBlock(BlockModel block) async {
    final db = await _dbHelper.database;
    return await db.insert(AppConstants.tableBlocks, block.toMap());
  }

  /// Update blok yang sudah ada (biasanya untuk update status / actual_duration)
  Future<void> updateBlock(BlockModel block) async {
    final db = await _dbHelper.database;
    await db.update(
      AppConstants.tableBlocks,
      block.toMap(),
      where:     'id = ?',
      whereArgs: [block.id],
    );
  }

  /// Hapus blok berdasarkan id
  Future<void> deleteBlock(int id) async {
    final db = await _dbHelper.database;
    await db.delete(
      AppConstants.tableBlocks,
      where:     'id = ?',
      whereArgs: [id],
    );
  }

  /// Ambil blok dalam rentang tanggal untuk laporan mingguan
  Future<List<BlockModel>> getBlocksByDateRange(
      String startDate, String endDate) async {
    final db   = await _dbHelper.database;
    final rows = await db.query(
      AppConstants.tableBlocks,
      where:     'date >= ? AND date <= ?',
      whereArgs: [startDate, endDate],
      orderBy:   'date ASC, start_time ASC',
    );
    return rows.map(BlockModel.fromMap).toList();
  }

  // ─── Sessions ────────────────────────────────────────────

  /// Simpan sesi Pomodoro baru
  Future<int> insertSession(SessionModel session) async {
    final db = await _dbHelper.database;
    return await db.insert(AppConstants.tableSessions, session.toMap());
  }

  /// Update sesi (biasanya saat sesi selesai — isi ended_at & actual_minutes)
  Future<void> updateSession(SessionModel session) async {
    final db = await _dbHelper.database;
    await db.update(
      AppConstants.tableSessions,
      session.toMap(),
      where:     'id = ?',
      whereArgs: [session.id],
    );
  }

  /// Ambil semua sesi untuk satu blok
  Future<List<SessionModel>> getSessionsByBlock(int blockId) async {
    final db   = await _dbHelper.database;
    final rows = await db.query(
      AppConstants.tableSessions,
      where:     'block_id = ?',
      whereArgs: [blockId],
      orderBy:   'started_at ASC',
    );
    return rows.map(SessionModel.fromMap).toList();
  }

  /// Total menit aktual per mata kuliah dalam rentang tanggal
  /// Return: Map<subject, totalMenit>
  Future<Map<String, int>> getSubjectMinutes(
      String startDate, String endDate) async {
    final db  = await _dbHelper.database;
    final res = await db.rawQuery('''
      SELECT subject, SUM(actual_duration) as total
      FROM   ${AppConstants.tableBlocks}
      WHERE  date >= ? AND date <= ?
        AND  status = '${AppConstants.statusDone}'
        AND  actual_duration IS NOT NULL
      GROUP  BY subject
      ORDER  BY total DESC
    ''', [startDate, endDate]);

    final map = <String, int>{};
    for (final row in res) {
      map[row['subject'] as String] = (row['total'] as int?) ?? 0;
    }
    return map;
  }
}
