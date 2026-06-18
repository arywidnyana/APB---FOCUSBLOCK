// =============================================================
// FILE: lib/features/block/presentation/add_block_screen.dart
// =============================================================
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../provider/block_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/constants/app_constants.dart';
import '../../collab/presentation/collab_block_screen.dart';

class AddBlockScreen extends StatefulWidget {
  const AddBlockScreen({super.key});
  @override
  State<AddBlockScreen> createState() => _AddBlockScreenState();
}

class _AddBlockScreenState extends State<AddBlockScreen> {
  final _formKey = GlobalKey<FormState>();
  String _subject = AppConstants.defaultSubjects.first;
  DateTime _startTime = DateTime.now().add(const Duration(hours: 1));
  int _duration = 60;
  bool _customSubject = false;
  final _customSubjectCtrl = TextEditingController();
  final _sessionCtrl = TextEditingController();

  @override
  void dispose() {
    _customSubjectCtrl.dispose();
    _sessionCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.navy,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: Text('Tambah Blok Belajar', style: AppTypography.h3),
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context)),
      ),
      body: Consumer<BlockProvider>(builder: (context, provider, _) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(key: _formKey, child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, children: [
            _SectionLabel('Mata kuliah'),
            const SizedBox(height: 8),
            if (!_customSubject) _buildDropdown() else _buildCustomSubjectField(),
            const SizedBox(height: 4),
            GestureDetector(onTap: () => setState(() => _customSubject = !_customSubject),
              child: Text(_customSubject ? '← Pilih dari daftar' : '+ Tambah mata kuliah baru',
                style: AppTypography.caption.copyWith(color: AppColors.teal))),
            const SizedBox(height: 20),

            _SectionLabel('Nama sesi'),
            const SizedBox(height: 8),
            TextFormField(controller: _sessionCtrl,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: const InputDecoration(hintText: 'contoh: Latihan soal bab 3'),
              validator: (v) => (v == null || v.isEmpty) ? 'Wajib diisi' : null),
            const SizedBox(height: 20),

            Row(children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _SectionLabel('Tanggal'), const SizedBox(height: 8),
                _DatePickerField(date: _startTime, onChanged: (d) => setState(() =>
                  _startTime = DateTime(d.year, d.month, d.day, _startTime.hour, _startTime.minute))),
              ])),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _SectionLabel('Jam mulai'), const SizedBox(height: 8),
                _TimePickerField(time: TimeOfDay.fromDateTime(_startTime), onChanged: (t) => setState(() =>
                  _startTime = DateTime(_startTime.year, _startTime.month, _startTime.day, t.hour, t.minute))),
              ])),
            ]),
            const SizedBox(height: 20),

            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              _SectionLabel('Durasi rencana'),
              Text('$_duration menit', style: AppTypography.monoAccent),
            ]),
            const SizedBox(height: 8),
            SliderTheme(data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppColors.teal, inactiveTrackColor: AppColors.surface3,
              thumbColor: AppColors.teal, overlayColor: AppColors.tealDim),
              child: Slider(value: _duration.toDouble(), min: 15, max: 180, divisions: 11,
                onChanged: (v) => setState(() => _duration = v.round()))),
            const SizedBox(height: 24),

            _BlockPreview(
              subject: _customSubject ? (_customSubjectCtrl.text.isEmpty ? 'Mata kuliah' : _customSubjectCtrl.text) : _subject,
              session: _sessionCtrl.text.isEmpty ? 'Nama sesi' : _sessionCtrl.text,
              startTime: _startTime, duration: _duration),
            const SizedBox(height: 24),

            if (provider.error != null) Padding(padding: const EdgeInsets.only(bottom: 12),
              child: Text(provider.error!, style: AppTypography.caption.copyWith(color: AppColors.coral))),

            SizedBox(width: double.infinity, child: OutlinedButton.icon(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CollabBlockScreen())),
              style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.tealMid),
                foregroundColor: AppColors.teal, padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              icon: const Icon(Icons.people_outline, size: 18),
              label: const Text('Buat Bersama Teman'))),
            const SizedBox(height: 12),

            SizedBox(width: double.infinity, child: ElevatedButton(
              onPressed: provider.saving ? null : _save,
              child: provider.saving
                  ? const SizedBox(height: 20, width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.navy))
                  : const Text('Simpan Blok'))),
            const SizedBox(height: 20),
          ])),
        );
      }),
    );
  }

  Widget _buildDropdown() {
    return DropdownButtonFormField<String>(value: _subject, dropdownColor: AppColors.surface2,
      style: const TextStyle(color: AppColors.textPrimary), decoration: const InputDecoration(),
      items: AppConstants.defaultSubjects.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
      onChanged: (v) => setState(() => _subject = v ?? _subject));
  }

  Widget _buildCustomSubjectField() {
    return TextFormField(controller: _customSubjectCtrl,
      style: const TextStyle(color: AppColors.textPrimary),
      decoration: const InputDecoration(hintText: 'Nama mata kuliah'),
      onChanged: (_) => setState(() {}));
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final subject = _customSubject ? _customSubjectCtrl.text.trim() : _subject;
    final ok = await context.read<BlockProvider>().saveBlock(
      subject: subject, sessionName: _sessionCtrl.text,
      startTime: _startTime, plannedDuration: _duration);
    if (ok && mounted) Navigator.pop(context);
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);
  @override
  Widget build(BuildContext context) => Text(text.toUpperCase(), style: AppTypography.label);
}

class _DatePickerField extends StatelessWidget {
  final DateTime date;
  final ValueChanged<DateTime> onChanged;
  const _DatePickerField({required this.date, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(onTap: () async {
      final picked = await showDatePicker(context: context, initialDate: date,
        firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 365)),
        builder: (ctx, child) => Theme(data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(primary: AppColors.teal)), child: child!));
      if (picked != null) onChanged(picked);
    }, child: Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(color: AppColors.surface2, borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border)),
      child: Row(children: [
        const Icon(Icons.calendar_today, size: 14, color: AppColors.textSecondary),
        const SizedBox(width: 8),
        Text('${date.day}/${date.month}/${date.year}',
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 13)),
      ])));
  }
}

class _TimePickerField extends StatelessWidget {
  final TimeOfDay time;
  final ValueChanged<TimeOfDay> onChanged;
  const _TimePickerField({required this.time, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(onTap: () async {
      final picked = await showTimePicker(context: context, initialTime: time,
        builder: (ctx, child) => Theme(data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(primary: AppColors.teal)), child: child!));
      if (picked != null) onChanged(picked);
    }, child: Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(color: AppColors.surface2, borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border)),
      child: Row(children: [
        const Icon(Icons.schedule, size: 14, color: AppColors.textSecondary),
        const SizedBox(width: 8),
        Text('${time.hour.toString().padLeft(2,'0')}:${time.minute.toString().padLeft(2,'0')}',
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 13)),
      ])));
  }
}

class _BlockPreview extends StatelessWidget {
  final String subject, session;
  final DateTime startTime;
  final int duration;
  const _BlockPreview({required this.subject, required this.session, required this.startTime, required this.duration});

  @override
  Widget build(BuildContext context) {
    final end = startTime.add(Duration(minutes: duration));
    final fmt = (DateTime dt) => '${dt.hour.toString().padLeft(2,'0')}:${dt.minute.toString().padLeft(2,'0')}';
    return Container(padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.tealDim, borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.tealMid)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('PREVIEW BLOK', style: AppTypography.label.copyWith(color: AppColors.teal, fontSize: 10)),
        const SizedBox(height: 10),
        Row(children: [
          Container(width: 3, height: 40, decoration: BoxDecoration(
            color: AppColors.teal, borderRadius: BorderRadius.circular(99))),
          const SizedBox(width: 12),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(subject, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
            const SizedBox(height: 3),
            Text('${fmt(startTime)} — ${fmt(end)} · $duration menit · $session',
              style: AppTypography.mono.copyWith(fontSize: 11)),
          ]),
        ]),
      ]));
  }
}
