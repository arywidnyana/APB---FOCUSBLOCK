// =============================================================
// FILE: lib/features/collab/presentation/collab_block_screen.dart
// TANGGUNG JAWAB: Layar buat blok belajar bersama teman —
//   pilih teman, tentukan waktu, kirim request. Dummy frontend.
// =============================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/constants/app_constants.dart';
import '../../friends/presentation/friends_screen.dart';

class CollabBlockScreen extends StatefulWidget {
  const CollabBlockScreen({super.key});

  @override
  State<CollabBlockScreen> createState() => _CollabBlockScreenState();
}

class _CollabBlockScreenState extends State<CollabBlockScreen> {
  final List<FriendModel> _selected = [];
  String   _subject       = AppConstants.defaultSubjects.first;
  String   _sessionName   = '';
  DateTime _startTime     = DateTime.now().add(const Duration(hours: 1));
  int      _duration      = 60;
  bool     _sending       = false;

  final _sessionCtrl = TextEditingController();

  @override
  void dispose() {
    _sessionCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.navy,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: Text('Blok Belajar Bersama', style: AppTypography.h3),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info banner
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.tealDim,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.tealMid),
              ),
              child: Row(
                children: [
                  const Icon(Icons.people_outline, color: AppColors.teal, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Buat sesi belajar bareng teman! Request dikirim ke teman pilihanmu.',
                      style: AppTypography.caption.copyWith(color: AppColors.teal)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Pilih teman
            Text('PILIH TEMAN', style: AppTypography.label),
            const SizedBox(height: 10),
            _buildFriendSelector(),
            const SizedBox(height: 22),

            // Mata kuliah
            Text('MATA KULIAH', style: AppTypography.label),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _subject,
              dropdownColor: AppColors.surface2,
              style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
              decoration: const InputDecoration(),
              items: AppConstants.defaultSubjects
                  .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                  .toList(),
              onChanged: (v) => setState(() => _subject = v ?? _subject),
            ),
            const SizedBox(height: 18),

            // Nama sesi
            Text('NAMA SESI', style: AppTypography.label),
            const SizedBox(height: 8),
            TextField(
              controller: _sessionCtrl,
              style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
              decoration: const InputDecoration(
                hintText: 'contoh: Belajar bareng bab 4'),
              onChanged: (v) => setState(() => _sessionName = v),
            ),
            const SizedBox(height: 18),

            // Waktu & durasi
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('JAM MULAI', style: AppTypography.label),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () async {
                          final t = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.fromDateTime(_startTime),
                            builder: (ctx, child) => Theme(
                              data: ThemeData.dark().copyWith(
                                colorScheme: const ColorScheme.dark(
                                  primary: AppColors.teal)),
                              child: child!),
                          );
                          if (t != null) setState(() => _startTime = DateTime(
                            _startTime.year, _startTime.month, _startTime.day,
                            t.hour, t.minute));
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 14),
                          decoration: BoxDecoration(
                            color: AppColors.surface2,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.border)),
                          child: Row(
                            children: [
                              const Icon(Icons.schedule, size: 16,
                                color: AppColors.textSecondary),
                              const SizedBox(width: 8),
                              Text(
                                '${_startTime.hour.toString().padLeft(2,'0')}:${_startTime.minute.toString().padLeft(2,'0')}',
                                style: const TextStyle(
                                  color: AppColors.textPrimary, fontSize: 13)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('DURASI', style: AppTypography.label),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        decoration: BoxDecoration(
                          color: AppColors.surface2,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.border)),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<int>(
                            value: _duration,
                            dropdownColor: AppColors.surface2,
                            style: const TextStyle(
                              color: AppColors.textPrimary, fontSize: 13),
                            isExpanded: true,
                            items: [25, 30, 45, 60, 90, 120].map((d) =>
                              DropdownMenuItem(
                                value: d,
                                child: Text('$d menit'))).toList(),
                            onChanged: (v) => setState(() => _duration = v ?? _duration),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Preview
            if (_selected.isNotEmpty) ...[
              _buildPreview(),
              const SizedBox(height: 20),
            ],

            // Tombol kirim
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _selected.isEmpty || _sending ? null : _sendRequest,
                icon: _sending
                    ? const SizedBox(width: 18, height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2, color: AppColors.navy))
                    : const Icon(Icons.send, size: 18),
                label: Text(_selected.isEmpty
                    ? 'Pilih teman dulu'
                    : 'Kirim request ke ${_selected.length} teman'),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildFriendSelector() {
    return Column(
      children: [
        // Teman yang dipilih
        if (_selected.isNotEmpty) ...[
          Wrap(
            spacing: 8, runSpacing: 8,
            children: _selected.map((f) => Chip(
              backgroundColor: AppColors.tealDim,
              side: const BorderSide(color: AppColors.tealMid),
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(f.avatar),
                  const SizedBox(width: 4),
                  Text(f.name.split(' ').first,
                    style: AppTypography.label.copyWith(color: AppColors.teal)),
                ],
              ),
              deleteIcon: const Icon(Icons.close, size: 14, color: AppColors.teal),
              onDeleted: () => setState(() => _selected.remove(f)),
            )).toList(),
          ),
          const SizedBox(height: 10),
        ],

        // List teman untuk dipilih
        ...dummyFriends.where((f) => !_selected.contains(f)).map((f) =>
          GestureDetector(
            onTap: () => setState(() => _selected.add(f)),
            child: Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border)),
              child: Row(
                children: [
                  Text(f.avatar, style: const TextStyle(fontSize: 20)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(f.name, style: AppTypography.h4.copyWith(fontSize: 13)),
                        Text(f.lastActive, style: AppTypography.caption),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.surface2,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.border)),
                    child: Text('Pilih',
                      style: AppTypography.label.copyWith(
                        color: AppColors.textSecondary)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPreview() {
    final end = _startTime.add(Duration(minutes: _duration));
    final fmt = (DateTime dt) =>
      '${dt.hour.toString().padLeft(2,'0')}:${dt.minute.toString().padLeft(2,'0')}';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('PREVIEW REQUEST', style: AppTypography.label),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                width: 3, height: 48,
                decoration: BoxDecoration(
                  color: AppColors.teal,
                  borderRadius: BorderRadius.circular(99)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_subject,
                      style: GoogleFonts.poppins(
                        fontSize: 14, fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary)),
                    Text(_sessionName.isEmpty ? 'Nama sesi...' : _sessionName,
                      style: AppTypography.bodyMuted.copyWith(fontSize: 12)),
                    Text('${fmt(_startTime)} — ${fmt(end)} · $_duration menit',
                      style: AppTypography.mono.copyWith(fontSize: 11)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text('Dikirim ke:',
            style: AppTypography.label),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6, runSpacing: 6,
            children: _selected.map((f) => Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(f.avatar, style: const TextStyle(fontSize: 14)),
                const SizedBox(width: 4),
                Text(f.name.split(' ').first,
                  style: AppTypography.caption),
              ],
            )).toList(),
          ),
        ],
      ),
    );
  }

  Future<void> _sendRequest() async {
    setState(() => _sending = true);
    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted) {
      setState(() => _sending = false);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          'Request dikirim ke ${_selected.map((f) => f.name.split(' ').first).join(', ')}!'),
        backgroundColor: AppColors.teal.withOpacity(0.9),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ));
    }
  }
}
