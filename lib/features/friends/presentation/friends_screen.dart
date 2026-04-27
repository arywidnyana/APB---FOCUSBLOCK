// =============================================================
// FILE: lib/features/friends/presentation/friends_screen.dart
// TANGGUNG JAWAB: Layar daftar teman dan tambah teman via
//   kode unik 6 digit. Dummy data untuk frontend testing.
// =============================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../social/presentation/social_screen.dart';

// ── Dummy model teman ────────────────────────────────────────
class FriendModel {
  final String id;
  final String name;
  final String friendCode;
  final String avatar;       // emoji avatar
  final double score;
  final int    streak;
  final String status;       // online | studying | offline
  final String lastActive;

  const FriendModel({
    required this.id,
    required this.name,
    required this.friendCode,
    required this.avatar,
    required this.score,
    required this.streak,
    required this.status,
    required this.lastActive,
  });
}

final List<FriendModel> dummyFriends = [
  FriendModel(id:'1', name:'Ary Widnyana',     friendCode:'ARY042', avatar:'🧑‍💻', score:88, streak:12, status:'studying',  lastActive:'Sedang belajar'),
  FriendModel(id:'2', name:'Friskila Anugrah', friendCode:'CIK024', avatar:'👩‍🎨', score:76, streak:7,  status:'online',    lastActive:'Online'),
  FriendModel(id:'3', name:'Budi Santoso',     friendCode:'BUD011', avatar:'🧑‍🔬', score:62, streak:3,  status:'offline',   lastActive:'2 jam lalu'),
  FriendModel(id:'4', name:'Sinta Maharani',   friendCode:'SIN033', avatar:'👩‍💼', score:91, streak:21, status:'studying',  lastActive:'Sedang belajar'),
  FriendModel(id:'5', name:'Rizky Pratama',    friendCode:'RIZ019', avatar:'🧑‍🎓', score:55, streak:1,  status:'offline',   lastActive:'5 jam lalu'),
];

// ── Main Screen ───────────────────────────────────────────────
class FriendsScreen extends StatefulWidget {
  const FriendsScreen({super.key});
  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;
  final _codeCtrl = TextEditingController();
  List<FriendModel> _friends = List.from(dummyFriends);

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    _codeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.navy,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: Text('Teman', style: AppTypography.h3),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_outlined, color: AppColors.teal),
            onPressed: _showAddFriendSheet,
          ),
        ],
        bottom: TabBar(
          controller: _tabs,
          labelColor: AppColors.teal,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.teal,
          indicatorSize: TabBarIndicatorSize.label,
          labelStyle: GoogleFonts.poppins(
            fontWeight: FontWeight.w600, fontSize: 12),
          tabs: const [
            Tab(text: 'Semua'),
            Tab(text: 'Sedang belajar'),
            Tab(text: 'Permintaan'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: [
          _buildFriendList(_friends),
          _buildFriendList(_friends.where((f) => f.status == 'studying').toList()),
          _buildRequestList(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.teal,
        foregroundColor: AppColors.navy,
        onPressed: _showAddFriendSheet,
        icon: const Icon(Icons.person_add),
        label: Text('Tambah teman',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13)),
      ),
    );
  }

  Widget _buildFriendList(List<FriendModel> friends) {
    if (friends.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.people_outline, size: 48, color: AppColors.textTertiary),
            const SizedBox(height: 16),
            Text('Tidak ada teman di sini', style: AppTypography.bodyMuted),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      itemCount: friends.length,
      itemBuilder: (_, i) => _FriendCard(
        friend: friends[i],
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => SocialScreen(friend: friends[i])),
        ),
        onRemove: () => setState(() => _friends.remove(friends[i])),
      ),
    );
  }

  Widget _buildRequestList() {
    // Dummy incoming requests
    final requests = [
      {'name': 'Dika Saputra', 'code': 'DIK007', 'avatar': '🧑‍💻', 'mutual': '2 teman mutual'},
      {'name': 'Laras Putri',  'code': 'LAR055', 'avatar': '👩‍🎓', 'mutual': '1 teman mutual'},
    ];
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Permintaan masuk', style: AppTypography.label),
        const SizedBox(height: 12),
        ...requests.map((r) => Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  color: AppColors.surface2,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(child: Text(r['avatar']!, style: const TextStyle(fontSize: 22))),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(r['name']!, style: AppTypography.h4.copyWith(fontSize: 13)),
                    Text(r['mutual']!, style: AppTypography.caption),
                  ],
                ),
              ),
              Row(
                children: [
                  _SmallBtn(label: 'Tolak', color: AppColors.coral,
                    onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                      _snack('Permintaan ditolak'))),
                  const SizedBox(width: 8),
                  _SmallBtn(label: 'Terima', color: AppColors.teal,
                    onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                      _snack('${r['name']} ditambahkan!'))),
                ],
              ),
            ],
          ),
        )),
      ],
    );
  }

  void _showAddFriendSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: EdgeInsets.fromLTRB(
          24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: AppColors.surface3,
                  borderRadius: BorderRadius.circular(99)),
              ),
            ),
            const SizedBox(height: 20),
            Text('Tambah teman', style: AppTypography.h3),
            const SizedBox(height: 6),
            Text('Masukkan kode unik teman kamu (6 karakter)',
              style: AppTypography.caption),
            const SizedBox(height: 20),

            // Kode unik sendiri
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.tealDim,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.tealMid),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Kode unikmu', style: AppTypography.label.copyWith(color: AppColors.teal)),
                      const SizedBox(height: 4),
                      Text('TGR042',
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 22, fontWeight: FontWeight.w700,
                          color: AppColors.teal, letterSpacing: 4)),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy, color: AppColors.teal, size: 20),
                    onPressed: () {
                      Clipboard.setData(const ClipboardData(text: 'TGR042'));
                      ScaffoldMessenger.of(context).showSnackBar(
                        _snack('Kode disalin!'));
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            Text('KODE TEMAN', style: AppTypography.label),
            const SizedBox(height: 8),
            TextField(
              controller: _codeCtrl,
              style: GoogleFonts.jetBrainsMono(
                fontSize: 18, color: AppColors.textPrimary,
                letterSpacing: 3),
              textCapitalization: TextCapitalization.characters,
              maxLength: 6,
              decoration: const InputDecoration(
                hintText: 'contoh: ARY042',
                counterText: '',
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    _snack('Permintaan pertemanan terkirim!'));
                  _codeCtrl.clear();
                },
                child: const Text('Kirim permintaan'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  SnackBar _snack(String msg) => SnackBar(
    content: Text(msg),
    backgroundColor: AppColors.teal.withOpacity(0.9),
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
  );
}

// ── Friend card ───────────────────────────────────────────────
class _FriendCard extends StatelessWidget {
  final FriendModel  friend;
  final VoidCallback onTap;
  final VoidCallback onRemove;
  const _FriendCard({required this.friend, required this.onTap, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    final statusColor = friend.status == 'studying'
        ? AppColors.teal
        : friend.status == 'online'
            ? AppColors.amber
            : AppColors.textTertiary;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Stack(
              children: [
                Container(
                  width: 48, height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.surface2,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Text(friend.avatar, style: const TextStyle(fontSize: 24))),
                ),
                Positioned(
                  right: 0, bottom: 0,
                  child: Container(
                    width: 12, height: 12,
                    decoration: BoxDecoration(
                      color: statusColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.surface, width: 2),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(friend.name, style: AppTypography.h4.copyWith(fontSize: 13)),
                  const SizedBox(height: 3),
                  Text(friend.lastActive,
                    style: AppTypography.caption.copyWith(color: statusColor)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  children: [
                    const Icon(Icons.local_fire_department,
                      size: 14, color: AppColors.amber),
                    const SizedBox(width: 2),
                    Text('${friend.streak}',
                      style: AppTypography.mono.copyWith(
                        color: AppColors.amber, fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 4),
                Text('${friend.score.toInt()}%',
                  style: AppTypography.monoAccent.copyWith(fontSize: 12)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SmallBtn extends StatelessWidget {
  final String       label;
  final Color        color;
  final VoidCallback onTap;
  const _SmallBtn({required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(label,
        style: TextStyle(
          fontSize: 11, fontWeight: FontWeight.w600, color: color)),
    ),
  );
}
