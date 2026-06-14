// =============================================================
// FILE: lib/data/repositories/block_repository.dart
// TANGGUNG JAWAB: CRUD blok belajar ke Firestore.
//   SQLite sudah tidak dipakai.
// =============================================================

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/block_model.dart';

class BlockRepository {
  final FirebaseFirestore _db   = FirebaseFirestore.instance;
  final FirebaseAuth      _auth = FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> get _blocksRef {
    final uid = _auth.currentUser!.uid;
    return _db.collection('blocks').doc(uid).collection('userBlocks');
  }

  Future<String> insertBlock(BlockModel block) async {
    final doc = await _blocksRef.add(block.toMap());
    return doc.id;
  }

  Future<List<BlockModel>> getBlocksByDate(String date) async {
    final snap = await _blocksRef
        .where('date', isEqualTo: date)
        .orderBy('start_time')
        .get();
    return snap.docs
        .map((d) => BlockModel.fromMap({...d.data(), 'id': d.id}))
        .toList();
  }

  Future<List<BlockModel>> getAllBlocks() async {
    final snap = await _blocksRef
        .orderBy('date', descending: true)
        .get();
    return snap.docs
        .map((d) => BlockModel.fromMap({...d.data(), 'id': d.id}))
        .toList();
  }

  Future<List<BlockModel>> getBlocksByDateRange(
      String startDate, String endDate) async {
    final snap = await _blocksRef
        .where('date', isGreaterThanOrEqualTo: startDate)
        .where('date', isLessThanOrEqualTo: endDate)
        .orderBy('date')
        .get();
    return snap.docs
        .map((d) => BlockModel.fromMap({...d.data(), 'id': d.id}))
        .toList();
  }

  Future<void> updateBlock(BlockModel block) async {
    await _blocksRef.doc(block.id).update(block.toMap());
  }

  Future<void> deleteBlock(String id) async {
    await _blocksRef.doc(id).delete();
  }

  Future<Map<String, int>> getSubjectMinutes(
      String startDate, String endDate) async {
    final blocks = await getBlocksByDateRange(startDate, endDate);
    final map    = <String, int>{};
    for (final b in blocks) {
      if (b.status == 'done' && b.actualDuration != null) {
        map[b.subject] = (map[b.subject] ?? 0) + b.actualDuration!;
      }
    }
    return map;
  }
}