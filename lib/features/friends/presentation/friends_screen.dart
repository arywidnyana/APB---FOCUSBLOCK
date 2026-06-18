// =============================================================
// FILE: lib/features/friends/presentation/friends_screen.dart
// =============================================================
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/repositories/friend_repository.dart';
import '../../social/presentation/social_screen.dart';

class FriendsScreen extends StatefulWidget {
  const FriendsScreen({super.key});
  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabs;
  final _codeCtrl = TextEditingController();
  final _repo = FriendRepository();
  String _myFriendCode = '------';

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
    _loadMyCode();
  }

  Future<void> _loadMyCode() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    if (doc.exists && mounted) setState(() => _myFriendCode = doc.data()?['friendCode'] ?? '------');
  }

  @override
  void dispose() { _tabs.dispose(); _codeCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.navy,
      appBar: AppBar(backgroundColor: AppColors.surface, title: Text('Teman', style: AppTypography.h3),
        actions: [IconButton(icon: const Icon(Icons.person_add_outlined, color: AppColors.teal),
          onPressed: _showAddFriendSheet)],
        bottom: TabBar(controller: _tabs, labelColor: AppColors.teal, unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.teal, indicatorSize: TabBarIndicatorSize.label,
          tabs: const [Tab(text: 'Teman saya'), Tab(text: 'Permintaan')])),
      body: TabBarView(controller: _tabs, children: [_buildFriendList(), _buildRequestList()]),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.teal, foregroundColor: AppColors.navy,
        onPressed: _showAddFriendSheet, icon: const Icon(Icons.person_add),
        label: Text('Tambah teman', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13))),
    );
  }

  Widget _buildFriendList() {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _repo.streamFriends(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: AppColors.teal));
        }
        final friends = snapshot.data ?? [];
        if (friends.isEmpty) {
          return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Icon(Icons.people_outline, size: 48, color: AppColors.textTertiary),
            const SizedBox(height: 16),
            Text('Belum ada teman', style: AppTypography.bodyMuted),
            const SizedBox(height: 8),
            Text('Tambahkan teman lewat kode unik', style: AppTypography.caption),
          ]));
        }
        return ListView.builder(padding: const EdgeInsets.all(16), itemCount: friends.length,
          itemBuilder: (_, i) => _FriendCard(friend: friends[i],
            onTap: () => Navigator.push(context, MaterialPageRoute(
              builder: (_) => SocialScreen(friendUid: friends[i]['uid'], friendName: friends[i]['name'] ?? 'Teman')))));
      },
    );
  }

  Widget _buildRequestList() {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _repo.streamIncomingRequests(),
      builder: (context, snapshot) {
        final requests = snapshot.data ?? [];
        if (requests.isEmpty) {
          return Center(child: Text('Tidak ada permintaan masuk', style: AppTypography.bodyMuted));
        }
        return ListView.builder(padding: const EdgeInsets.all(16), itemCount: requests.length,
          itemBuilder: (_, i) {
            final r = requests[i];
            return Container(margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border)),
              child: Row(children: [
                Container(width: 44, height: 44, decoration: BoxDecoration(
                  color: AppColors.surface2, borderRadius: BorderRadius.circular(12)),
                  child: Center(child: Text(r['avatar'] ?? '🧑', style: const TextStyle(fontSize: 22)))),
                const SizedBox(width: 12),
                Expanded(child: Text(r['name'] ?? 'Pengguna', style: AppTypography.h4.copyWith(fontSize: 13))),
                TextButton(onPressed: () async {
                  await _repo.acceptFriendRequest(r['friendshipId']);
                  setState(() {});
                }, child: const Text('Terima', style: TextStyle(color: AppColors.teal))),
              ]));
          });
      },
    );
  }

  void _showAddFriendSheet() {
    showModalBottomSheet(context: context, backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 24),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Tambah teman', style: AppTypography.h3),
          const SizedBox(height: 6),
          Text('Masukkan kode unik teman kamu', style: AppTypography.caption),
          const SizedBox(height: 20),
          Container(padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: AppColors.tealDim, borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.tealMid)),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Kode unikmu', style: AppTypography.label.copyWith(color: AppColors.teal)),
                const SizedBox(height: 4),
                Text(_myFriendCode, style: GoogleFonts.jetBrainsMono(fontSize: 22,
                  fontWeight: FontWeight.w700, color: AppColors.teal, letterSpacing: 4)),
              ]),
              IconButton(icon: const Icon(Icons.copy, color: AppColors.teal, size: 20),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: _myFriendCode));
                  ScaffoldMessenger.of(context).showSnackBar(_snack('Kode disalin!'));
                }),
            ])),
          const SizedBox(height: 20),
          Text('KODE TEMAN', style: AppTypography.label),
          const SizedBox(height: 8),
          TextField(controller: _codeCtrl, style: GoogleFonts.jetBrainsMono(
            fontSize: 18, color: AppColors.textPrimary, letterSpacing: 3),
            textCapitalization: TextCapitalization.characters, maxLength: 6,
            decoration: const InputDecoration(hintText: 'contoh: ARY042', counterText: '')),
          const SizedBox(height: 16),
          SizedBox(width: double.infinity, child: ElevatedButton(
            onPressed: () async {
              final code = _codeCtrl.text.trim();
              if (code.isEmpty) return;
              final found = await _repo.findByFriendCode(code);
              if (found == null) {
                ScaffoldMessenger.of(context).showSnackBar(_snack('Kode tidak ditemukan'));
                return;
              }
              await _repo.sendFriendRequest(found['uid']);
              if (mounted) Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(_snack('Permintaan terkirim!'));
              _codeCtrl.clear();
            }, child: const Text('Kirim permintaan'))),
        ]),
      ),
    );
  }

  SnackBar _snack(String msg) => SnackBar(content: Text(msg), backgroundColor: AppColors.teal.withOpacity(0.9),
    behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)));
}

class _FriendCard extends StatelessWidget {
  final Map<String, dynamic> friend;
  final VoidCallback onTap;
  const _FriendCard({required this.friend, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final uid = friend['uid'] as String?;

    return GestureDetector(onTap: onTap, child: Container(margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border)),
      child: Row(children: [
        // Avatar + dot status realtime
        StreamBuilder<DocumentSnapshot>(
          stream: uid != null
              ? FirebaseFirestore.instance.collection('users').doc(uid).snapshots()
              : null,
          builder: (context, snapshot) {
            final data = snapshot.data?.data() as Map<String, dynamic>?;
            final status = data?['status'] as String? ?? 'offline';
            final statusColor = switch (status) {
              'studying' => AppColors.teal,
              'online'   => AppColors.amber,
              _          => AppColors.textTertiary,
            };
            return Stack(children: [
              Container(width: 48, height: 48, decoration: BoxDecoration(
                color: AppColors.surface2, borderRadius: BorderRadius.circular(14)),
                child: Center(child: Text(friend['avatar'] ?? '🧑', style: const TextStyle(fontSize: 24)))),
              Positioned(right: 0, bottom: 0,
                child: Container(width: 13, height: 13,
                  decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle,
                    border: Border.all(color: AppColors.surface, width: 2)))),
            ]);
          },
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(friend['name'] ?? 'Pengguna', style: AppTypography.h4.copyWith(fontSize: 13)),
          const SizedBox(height: 3),
          StreamBuilder<DocumentSnapshot>(
            stream: uid != null
                ? FirebaseFirestore.instance.collection('users').doc(uid).snapshots()
                : null,
            builder: (context, snapshot) {
              final data = snapshot.data?.data() as Map<String, dynamic>?;
              final status = data?['status'] as String? ?? 'offline';
              final label = switch (status) {
                'studying' => 'Sedang belajar',
                'online'   => 'Online',
                _          => 'Offline',
              };
              final color = switch (status) {
                'studying' => AppColors.teal,
                'online'   => AppColors.amber,
                _          => AppColors.textTertiary,
              };
              return Text(label, style: AppTypography.caption.copyWith(color: color));
            },
          ),
        ])),
        const Icon(Icons.chevron_right, color: AppColors.textTertiary),
      ])));
  }
}
