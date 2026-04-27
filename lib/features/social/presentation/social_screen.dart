// =============================================================
// FILE: lib/features/social/presentation/social_screen.dart
// TANGGUNG JAWAB: Layar interaksi bersama satu teman —
//   Pact room, shared streak, emoji reaction, chat singkat.
// =============================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../friends/presentation/friends_screen.dart';

class SocialScreen extends StatefulWidget {
  final FriendModel friend;
  const SocialScreen({super.key, required this.friend});

  @override
  State<SocialScreen> createState() => _SocialScreenState();
}

class _SocialScreenState extends State<SocialScreen> {
  bool _hasPact       = true;
  bool _iCheckedIn    = true;
  bool _friendCheckedIn = false;
  String? _myReaction;
  int  _sharedStreak  = 9;

  final List<Map<String, String>> _messages = [
    {'from': 'friend', 'text': 'Ayo belajar bareng hari ini! 💪', 'time': '08:12'},
    {'from': 'me',     'text': 'Siap! Lagi buka modul Kalkulus nih', 'time': '08:15'},
    {'from': 'friend', 'text': 'Semangat! Udah berapa soal?', 'time': '08:30'},
    {'from': 'me',     'text': 'Baru 5 hehe, susah banget', 'time': '08:31'},
    {'from': 'friend', 'text': 'Haha gas terus, kita jaga streak kita ya 🔥', 'time': '08:32'},
  ];
  final _msgCtrl = TextEditingController();

  @override
  void dispose() {
    _msgCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.navy,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: Row(
          children: [
            Text(widget.friend.avatar, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.friend.name, style: AppTypography.h4),
                Text(widget.friend.lastActive,
                  style: AppTypography.caption.copyWith(
                    color: widget.friend.status == 'studying'
                        ? AppColors.teal
                        : AppColors.textTertiary)),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: AppColors.textSecondary),
            onPressed: () => _showOptions(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Pact room di atas
          _buildPactRoom(),
          const Divider(color: AppColors.border, height: 1),
          // Chat di bawah
          Expanded(child: _buildChat()),
          _buildChatInput(),
        ],
      ),
    );
  }

  Widget _buildPactRoom() {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Header pact
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.handshake_outlined, size: 16, color: AppColors.teal),
                  const SizedBox(width: 6),
                  Text('Study Pact aktif',
                    style: AppTypography.label.copyWith(color: AppColors.teal)),
                ],
              ),
              Row(
                children: [
                  const Icon(Icons.local_fire_department, size: 16, color: AppColors.amber),
                  const SizedBox(width: 4),
                  Text('$_sharedStreak hari streak',
                    style: AppTypography.mono.copyWith(
                      color: AppColors.amber, fontSize: 12, fontWeight: FontWeight.w600)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Status check-in dua orang
          Row(
            children: [
              Expanded(child: _CheckInCard(
                name: 'Kamu',
                avatar: '🧑‍💻',
                isDone: _iCheckedIn,
                score: 72,
                onCheckIn: () => setState(() => _iCheckedIn = true),
              )),
              const SizedBox(width: 10),
              Expanded(child: _CheckInCard(
                name: widget.friend.name.split(' ').first,
                avatar: widget.friend.avatar,
                isDone: _friendCheckedIn,
                score: widget.friend.score.toInt(),
              )),
            ],
          ),
          const SizedBox(height: 12),

          // Emoji reaction
          if (_iCheckedIn && _friendCheckedIn) ...[
            Text('Kirim semangat!', style: AppTypography.caption),
            const SizedBox(height: 8),
          ] else ...[
            Text('Tunggu partner check-in...', style: AppTypography.caption),
            const SizedBox(height: 8),
          ],

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: ['👏','🔥','💪','🎯','😎','🚀'].map((e) => GestureDetector(
              onTap: () {
                setState(() => _myReaction = e);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('Kamu kirim $e ke ${widget.friend.name.split(' ').first}'),
                  backgroundColor: AppColors.tealDim,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ));
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _myReaction == e ? AppColors.tealDim : AppColors.surface2,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: _myReaction == e ? AppColors.tealMid : AppColors.border),
                ),
                child: Text(e, style: const TextStyle(fontSize: 20)),
              ),
            )).toList(),
          ),

          if (!_hasPact) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => setState(() {
                  _hasPact = true;
                  _sharedStreak = 0;
                }),
                icon: const Icon(Icons.handshake, size: 18),
                label: const Text('Buat Study Pact'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildChat() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: _messages.length,
      itemBuilder: (_, i) {
        final m = _messages[i];
        final isMe = m['from'] == 'me';
        return _ChatBubble(
          text: m['text']!,
          time: m['time']!,
          isMe: isMe,
          avatar: isMe ? '🧑‍💻' : widget.friend.avatar,
        );
      },
    );
  }

  Widget _buildChatInput() {
    return Container(
      color: AppColors.surface,
      padding: EdgeInsets.fromLTRB(
        16, 12, 16, MediaQuery.of(context).viewInsets.bottom + 12),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _msgCtrl,
              style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Tulis pesan...',
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(99),
                  borderSide: const BorderSide(color: AppColors.border)),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(99),
                  borderSide: const BorderSide(color: AppColors.border)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(99),
                  borderSide: const BorderSide(color: AppColors.teal)),
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () {
              if (_msgCtrl.text.isNotEmpty) {
                setState(() {
                  _messages.add({
                    'from': 'me',
                    'text': _msgCtrl.text,
                    'time': '${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2,'0')}',
                  });
                  _msgCtrl.clear();
                });
              }
            },
            child: Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: AppColors.teal,
                borderRadius: BorderRadius.circular(99),
              ),
              child: const Icon(Icons.send, color: AppColors.navy, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  void _showOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _OptionTile(icon: Icons.timer_outlined, label: 'Ajak belajar bareng',
              color: AppColors.teal, onTap: () => Navigator.pop(context)),
            _OptionTile(icon: Icons.bar_chart_outlined, label: 'Lihat progress mereka',
              color: AppColors.amber, onTap: () => Navigator.pop(context)),
            _OptionTile(icon: Icons.cancel_outlined, label: 'Putuskan Pact',
              color: AppColors.coral, onTap: () {
                Navigator.pop(context);
                setState(() => _hasPact = false);
              }),
            _OptionTile(icon: Icons.person_remove_outlined, label: 'Hapus teman',
              color: AppColors.coral, onTap: () {
                Navigator.pop(context);
                Navigator.pop(context);
              }),
          ],
        ),
      ),
    );
  }
}

class _CheckInCard extends StatelessWidget {
  final String name;
  final String avatar;
  final bool   isDone;
  final int    score;
  final VoidCallback? onCheckIn;

  const _CheckInCard({
    required this.name,
    required this.avatar,
    required this.isDone,
    required this.score,
    this.onCheckIn,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDone ? AppColors.tealDim : AppColors.surface2,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDone ? AppColors.tealMid : AppColors.border),
      ),
      child: Column(
        children: [
          Text(avatar, style: const TextStyle(fontSize: 24)),
          const SizedBox(height: 6),
          Text(name,
            style: AppTypography.label.copyWith(
              color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          if (isDone)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.check_circle, size: 14, color: AppColors.teal),
                const SizedBox(width: 4),
                Text('Check-in!',
                  style: AppTypography.label.copyWith(color: AppColors.teal)),
              ],
            )
          else if (onCheckIn != null)
            GestureDetector(
              onTap: onCheckIn,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.teal,
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Text('Check-in',
                  style: AppTypography.label.copyWith(
                    color: AppColors.navy, fontWeight: FontWeight.w600)),
              ),
            )
          else
            Text('Belum check-in',
              style: AppTypography.label.copyWith(color: AppColors.textTertiary)),
        ],
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final String text;
  final String time;
  final bool   isMe;
  final String avatar;

  const _ChatBubble({
    required this.text,
    required this.time,
    required this.isMe,
    required this.avatar,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            Text(avatar, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 8),
          ],
          Column(
            crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.6),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: isMe ? AppColors.teal : AppColors.surface,
                  borderRadius: BorderRadius.only(
                    topLeft:     const Radius.circular(16),
                    topRight:    const Radius.circular(16),
                    bottomLeft:  Radius.circular(isMe ? 16 : 4),
                    bottomRight: Radius.circular(isMe ? 4 : 16),
                  ),
                  border: isMe ? null : Border.all(color: AppColors.border),
                ),
                child: Text(text,
                  style: TextStyle(
                    fontSize: 13,
                    color: isMe ? AppColors.navy : AppColors.textPrimary)),
              ),
              const SizedBox(height: 4),
              Text(time, style: AppTypography.caption.copyWith(fontSize: 10)),
            ],
          ),
          if (isMe) const SizedBox(width: 8),
        ],
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  final IconData icon;
  final String   label;
  final Color    color;
  final VoidCallback onTap;
  const _OptionTile({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) => ListTile(
    leading: Icon(icon, color: color),
    title: Text(label, style: TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.w500)),
    onTap: onTap,
  );
}
