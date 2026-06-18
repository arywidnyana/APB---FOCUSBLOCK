// =============================================================
// FILE: lib/features/social/presentation/social_screen.dart
// =============================================================
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/repositories/friend_repository.dart';

class SocialScreen extends StatefulWidget {
  final String friendUid;
  final String friendName;
  const SocialScreen({super.key, required this.friendUid, required this.friendName});

  @override
  State<SocialScreen> createState() => _SocialScreenState();
}

class _SocialScreenState extends State<SocialScreen> {
  final _repo = FriendRepository();
  final _msgCtrl = TextEditingController();
  String? _pactId;
  bool _loadingPact = true;

  @override
  void initState() {
    super.initState();
    _findOrCreatePact();
  }

  Future<void> _findOrCreatePact() async {
    // Cari pact aktif dengan teman ini lewat stream sekali (ambil first value)
    final pacts = await _repo.streamActivePacts().first;
    final existing = pacts.where((p) =>
      (p['uid1'] == widget.friendUid || p['uid2'] == widget.friendUid)).toList();

    if (existing.isNotEmpty) {
      setState(() { _pactId = existing.first['pactId']; _loadingPact = false; });
    } else {
      setState(() => _loadingPact = false);
    }
  }

  Future<void> _createPact() async {
    final id = await _repo.createPact(
      partnerUid: widget.friendUid, subject: 'Belajar bersama',
      sessionName: 'Sesi bersama', durationMinutes: 25);
    setState(() => _pactId = id);
  }

  @override
  void dispose() { _msgCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.navy,
      appBar: AppBar(backgroundColor: AppColors.surface,
        title: Text(widget.friendName, style: AppTypography.h4)),
      body: _loadingPact
          ? const Center(child: CircularProgressIndicator(color: AppColors.teal))
          : Column(children: [
              _buildPactRoom(),
              const Divider(color: AppColors.border, height: 1),
              Expanded(child: _pactId == null ? _buildNoPactState() : _buildChat()),
              if (_pactId != null) _buildChatInput(),
            ]),
    );
  }

  Widget _buildNoPactState() {
    return Center(child: Padding(padding: const EdgeInsets.all(24),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Icon(Icons.handshake_outlined, size: 48, color: AppColors.textTertiary),
        const SizedBox(height: 16),
        Text('Belum ada Study Pact', style: AppTypography.h4),
        const SizedBox(height: 8),
        Text('Buat pact untuk mulai belajar bersama dan menjaga streak',
          style: AppTypography.caption, textAlign: TextAlign.center),
      ])));
  }

  Widget _buildPactRoom() {
    if (_pactId == null) {
      return Container(color: AppColors.surface, padding: const EdgeInsets.all(16),
        child: SizedBox(width: double.infinity, child: ElevatedButton.icon(
          onPressed: _createPact, icon: const Icon(Icons.handshake, size: 18),
          label: const Text('Buat Study Pact'))));
    }

    return StreamBuilder<Map<String, dynamic>>(
      stream: _repo.streamTodayCheckin(_pactId!),
      builder: (context, snapshot) {
        final data = snapshot.data ?? {};
        final uid1Done = data['uid1Done'] as bool? ?? false;
        final uid2Done = data['uid2Done'] as bool? ?? false;
        final myUid = FirebaseAuth.instance.currentUser?.uid;

        return Container(color: AppColors.surface, padding: const EdgeInsets.all(16),
          child: Column(children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Row(children: [
                const Icon(Icons.handshake_outlined, size: 16, color: AppColors.teal),
                const SizedBox(width: 6),
                Text('Study Pact aktif', style: AppTypography.label.copyWith(color: AppColors.teal)),
              ]),
            ]),
            const SizedBox(height: 14),
            Row(children: [
              Expanded(child: _CheckInCard(name: 'Kamu', isDone: uid1Done,
                onCheckIn: !uid1Done ? () => _repo.checkIn(_pactId!) : null)),
              const SizedBox(width: 10),
              Expanded(child: _CheckInCard(name: widget.friendName.split(' ').first, isDone: uid2Done)),
            ]),
            const SizedBox(height: 12),
            Row(mainAxisAlignment: MainAxisAlignment.center,
              children: ['👏','🔥','💪','🎯','😎','🚀'].map((e) => GestureDetector(
                onTap: () => _repo.sendReaction(_pactId!, e),
                child: Container(margin: const EdgeInsets.symmetric(horizontal: 4), padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: AppColors.surface2, borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.border)),
                  child: Text(e, style: const TextStyle(fontSize: 20))),
              )).toList()),
          ]));
      },
    );
  }

  Widget _buildChat() {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _repo.streamMessages(_pactId!),
      builder: (context, snapshot) {
        final messages = snapshot.data ?? [];
        final myUid = FirebaseAuth.instance.currentUser?.uid;
        if (messages.isEmpty) {
          return Center(child: Text('Belum ada pesan, mulai chat!', style: AppTypography.bodyMuted));
        }
        return ListView.builder(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          itemCount: messages.length,
          itemBuilder: (_, i) {
            final m = messages[i];
            final isMe = m['senderUid'] == myUid;
            return _ChatBubble(text: m['text'] ?? '', isMe: isMe);
          });
      },
    );
  }

  Widget _buildChatInput() {
    return Container(color: AppColors.surface,
      padding: EdgeInsets.fromLTRB(16, 12, 16, MediaQuery.of(context).viewInsets.bottom + 12),
      child: Row(children: [
        Expanded(child: TextField(controller: _msgCtrl,
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
          decoration: InputDecoration(hintText: 'Tulis pesan...',
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(99),
              borderSide: const BorderSide(color: AppColors.border)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(99),
              borderSide: const BorderSide(color: AppColors.border)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(99),
              borderSide: const BorderSide(color: AppColors.teal))))),
        const SizedBox(width: 10),
        GestureDetector(onTap: () async {
          if (_msgCtrl.text.trim().isEmpty || _pactId == null) return;
          await _repo.sendMessage(_pactId!, _msgCtrl.text.trim());
          _msgCtrl.clear();
        }, child: Container(width: 44, height: 44,
          decoration: BoxDecoration(color: AppColors.teal, borderRadius: BorderRadius.circular(99)),
          child: const Icon(Icons.send, color: AppColors.navy, size: 20))),
      ]));
  }
}

class _CheckInCard extends StatelessWidget {
  final String name;
  final bool isDone;
  final VoidCallback? onCheckIn;
  const _CheckInCard({required this.name, required this.isDone, this.onCheckIn});

  @override
  Widget build(BuildContext context) {
    return Container(padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: isDone ? AppColors.tealDim : AppColors.surface2,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: isDone ? AppColors.tealMid : AppColors.border)),
      child: Column(children: [
        Text(name, style: AppTypography.label.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        if (isDone) Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Icon(Icons.check_circle, size: 14, color: AppColors.teal),
          const SizedBox(width: 4),
          Text('Check-in!', style: AppTypography.label.copyWith(color: AppColors.teal)),
        ]) else if (onCheckIn != null) GestureDetector(onTap: onCheckIn,
          child: Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: AppColors.teal, borderRadius: BorderRadius.circular(99)),
            child: Text('Check-in', style: AppTypography.label.copyWith(
              color: AppColors.navy, fontWeight: FontWeight.w600))))
        else Text('Belum check-in', style: AppTypography.label.copyWith(color: AppColors.textTertiary)),
      ]));
  }
}

class _ChatBubble extends StatelessWidget {
  final String text;
  final bool isMe;
  const _ChatBubble({required this.text, required this.isMe});

  @override
  Widget build(BuildContext context) {
    return Padding(padding: const EdgeInsets.only(bottom: 12),
      child: Row(mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start, children: [
        Container(constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.6),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(color: isMe ? AppColors.teal : AppColors.surface,
            borderRadius: BorderRadius.only(topLeft: const Radius.circular(16), topRight: const Radius.circular(16),
              bottomLeft: Radius.circular(isMe ? 16 : 4), bottomRight: Radius.circular(isMe ? 4 : 16)),
            border: isMe ? null : Border.all(color: AppColors.border)),
          child: Text(text, style: TextStyle(fontSize: 13, color: isMe ? AppColors.navy : AppColors.textPrimary))),
      ]));
  }
}
