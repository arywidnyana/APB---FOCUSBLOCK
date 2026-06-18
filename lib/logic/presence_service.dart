// =============================================================
// FILE: lib/logic/presence_service.dart
// TANGGUNG JAWAB: Update status kehadiran user (online/studying/
//   offline) ke Firestore supaya teman bisa lihat secara realtime.
// =============================================================

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PresenceService {
  PresenceService._();
  static final PresenceService instance = PresenceService._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  // ── Set status user saat ini ───────────────────────────────
  // status: 'online' | 'studying' | 'offline'
  Future<void> setStatus(String status) async {
    final uid = _uid;
    if (uid == null) return;
    try {
      await _db.collection('users').doc(uid).set({
        'status': status,
        'lastSeen': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (_) {
      // Diam saja kalau gagal — presence tidak boleh bikin app crash
    }
  }

  Future<void> setOnline()   => setStatus('online');
  Future<void> setStudying() => setStatus('studying');
  Future<void> setOffline()  => setStatus('offline');
}
