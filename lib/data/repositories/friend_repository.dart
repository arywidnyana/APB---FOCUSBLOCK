// FILE: lib/data/repositories/friend_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FriendRepository {
  final FirebaseFirestore _db   = FirebaseFirestore.instance;
  final FirebaseAuth      _auth = FirebaseAuth.instance;

  String get _myUid => _auth.currentUser!.uid;

  Future<Map<String, dynamic>?> findByFriendCode(String code) async {
    final snap = await _db.collection('users')
        .where('friendCode', isEqualTo: code.toUpperCase())
        .limit(1).get();
    if (snap.docs.isEmpty) return null;
    return {...snap.docs.first.data(), 'uid': snap.docs.first.id};
  }

  Future<void> sendFriendRequest(String targetUid) async {
    final existing = await _db.collection('friendships')
        .where('uid1', isEqualTo: _myUid)
        .where('uid2', isEqualTo: targetUid).get();
    if (existing.docs.isNotEmpty) return;

    await _db.collection('friendships').add({
      'uid1': _myUid, 'uid2': targetUid,
      'status': 'pending', 'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> acceptFriendRequest(String friendshipId) async {
    await _db.collection('friendships').doc(friendshipId).update({'status': 'accepted'});
  }

  Stream<List<Map<String, dynamic>>> streamFriends() {
    return _db.collection('friendships')
        .where('uid1', isEqualTo: _myUid)
        .where('status', isEqualTo: 'accepted')
        .snapshots()
        .asyncMap((snap) async {
          final friends = <Map<String, dynamic>>[];
          for (final doc in snap.docs) {
            final friendUid = doc['uid2'] as String;
            final userDoc = await _db.collection('users').doc(friendUid).get();
            if (userDoc.exists) {
              friends.add({...userDoc.data()!, 'uid': friendUid, 'friendshipId': doc.id});
            }
          }
          return friends;
        });
  }

  Stream<List<Map<String, dynamic>>> streamIncomingRequests() {
    return _db.collection('friendships')
        .where('uid2', isEqualTo: _myUid)
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .asyncMap((snap) async {
          final requests = <Map<String, dynamic>>[];
          for (final doc in snap.docs) {
            final senderDoc = await _db.collection('users').doc(doc['uid1'] as String).get();
            if (senderDoc.exists) {
              requests.add({...senderDoc.data()!, 'uid': doc['uid1'], 'friendshipId': doc.id});
            }
          }
          return requests;
        });
  }

  Future<String> createPact({
    required String partnerUid, required String subject,
    required String sessionName, required int durationMinutes,
  }) async {
    final doc = await _db.collection('pacts').add({
      'uid1': _myUid, 'uid2': partnerUid,
      'subject': subject, 'sessionName': sessionName,
      'durationMinutes': durationMinutes, 'sharedStreak': 0,
      'status': 'active', 'createdAt': FieldValue.serverTimestamp(),
      'lastCheckinDate': null,
    });
    return doc.id;
  }

  Stream<List<Map<String, dynamic>>> streamActivePacts() {
    return _db.collection('pacts')
        .where('status', isEqualTo: 'active')
        .where(Filter.or(
          Filter('uid1', isEqualTo: _myUid),
          Filter('uid2', isEqualTo: _myUid),
        ))
        .snapshots()
        .map((snap) => snap.docs.map((d) => {...d.data(), 'pactId': d.id}).toList());
  }

  Future<void> checkIn(String pactId) async {
    final today = _todayStr();
    final docRef = _db.collection('pacts').doc(pactId).collection('checkins').doc(today);
    final existing = await docRef.get();
    final data = existing.data() ?? {};
    final uid1Done = data['uid1Done'] as bool? ?? false;
    final uid2Done = data['uid2Done'] as bool? ?? false;

    final pactDoc = await _db.collection('pacts').doc(pactId).get();
    final isUid1 = (pactDoc.data()?['uid1'] as String?) == _myUid;

    await docRef.set({
      'date': today,
      'uid1Done': isUid1 ? true : uid1Done,
      'uid2Done': isUid1 ? uid2Done : true,
    }, SetOptions(merge: true));

    final newUid1 = isUid1 ? true : uid1Done;
    final newUid2 = isUid1 ? uid2Done : true;
    if (newUid1 && newUid2) {
      await _db.collection('pacts').doc(pactId).update({
        'sharedStreak': FieldValue.increment(1),
        'lastCheckinDate': today,
      });
    }
  }

  Stream<Map<String, dynamic>> streamTodayCheckin(String pactId) {
    return _db.collection('pacts').doc(pactId)
        .collection('checkins').doc(_todayStr())
        .snapshots()
        .map((s) => s.data() ?? {'uid1Done': false, 'uid2Done': false});
  }

  Future<void> sendReaction(String pactId, String emoji) async {
    final pactDoc = await _db.collection('pacts').doc(pactId).get();
    final isUid1 = (pactDoc.data()?['uid1'] as String?) == _myUid;
    final field = isUid1 ? 'reaction1' : 'reaction2';
    await _db.collection('pacts').doc(pactId)
        .collection('checkins').doc(_todayStr())
        .set({field: emoji}, SetOptions(merge: true));
  }

  Future<void> sendMessage(String pactId, String text) async {
    await _db.collection('pacts').doc(pactId).collection('messages').add({
      'senderUid': _myUid, 'text': text,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Stream<List<Map<String, dynamic>>> streamMessages(String pactId) {
    return _db.collection('pacts').doc(pactId)
        .collection('messages').orderBy('timestamp')
        .snapshots()
        .map((snap) => snap.docs.map((d) => d.data()).toList());
  }

  String _todayStr() {
    final n = DateTime.now();
    return '${n.year}-${n.month.toString().padLeft(2,'0')}-${n.day.toString().padLeft(2,'0')}';
  }
}
