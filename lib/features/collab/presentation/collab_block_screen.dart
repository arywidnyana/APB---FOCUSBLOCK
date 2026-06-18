// =============================================================
// FILE: lib/features/collab/presentation/collab_block_screen.dart
// =============================================================
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/repositories/friend_repository.dart';

class CollabBlockScreen extends StatefulWidget {
  const CollabBlockScreen({super.key});
  @override
  State<CollabBlockScreen> createState() => _CollabBlockScreenState();
}

class _CollabBlockScreenState extends State<CollabBlockScreen> {
  final _repo = FriendRepository();
  String? _selectedUid;
  String? _selectedName;
  bool _sending = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.navy,
      appBar: AppBar(backgroundColor: AppColors.surface, title: Text('Blok Belajar Bersama', style: AppTypography.h3)),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _repo.streamFriends(),
        builder: (context, snapshot) {
          final friends = snapshot.data ?? [];
          if (friends.isEmpty) {
            return Center(child: Padding(padding: const EdgeInsets.all(24),
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Icon(Icons.people_outline, size: 48, color: AppColors.textTertiary),
                const SizedBox(height: 16),
                Text('Belum ada teman', style: AppTypography.h4),
                const SizedBox(height: 8),
                Text('Tambahkan teman dulu di menu Teman', style: AppTypography.caption, textAlign: TextAlign.center),
              ])));
          }
          return ListView(padding: const EdgeInsets.all(20), children: [
            Text('PILIH TEMAN', style: AppTypography.label),
            const SizedBox(height: 10),
            ...friends.map((f) => GestureDetector(
              onTap: () => setState(() { _selectedUid = f['uid']; _selectedName = f['name']; }),
              child: Container(margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: _selectedUid == f['uid'] ? AppColors.tealDim : AppColors.surface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: _selectedUid == f['uid'] ? AppColors.tealMid : AppColors.border)),
                child: Row(children: [
                  Text(f['avatar'] ?? '🧑', style: const TextStyle(fontSize: 20)),
                  const SizedBox(width: 12),
                  Expanded(child: Text(f['name'] ?? 'Pengguna', style: AppTypography.h4.copyWith(fontSize: 13))),
                  if (_selectedUid == f['uid']) const Icon(Icons.check_circle, color: AppColors.teal, size: 20),
                ]))),
            ),
            const SizedBox(height: 24),
            SizedBox(width: double.infinity, child: ElevatedButton(
              onPressed: _selectedUid == null || _sending ? null : _sendRequest,
              child: _sending
                  ? const SizedBox(width: 18, height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.navy))
                  : Text(_selectedUid == null ? 'Pilih teman dulu' : 'Buat Pact dengan $_selectedName'),
            )),
          ]);
        },
      ),
    );
  }

  Future<void> _sendRequest() async {
    if (_selectedUid == null) return;
    setState(() => _sending = true);
    await _repo.createPact(partnerUid: _selectedUid!, subject: 'Belajar bersama',
      sessionName: 'Sesi bersama', durationMinutes: 25);
    if (mounted) {
      setState(() => _sending = false);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Pact dengan $_selectedName berhasil dibuat!'),
        backgroundColor: AppColors.teal.withOpacity(0.9), behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))));
    }
  }
}
