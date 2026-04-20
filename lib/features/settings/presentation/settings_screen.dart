// =============================================================
// FILE: lib/features/settings/presentation/settings_screen.dart
// TANGGUNG JAWAB: Layar pengaturan — nama pengguna, durasi
//   Pomodoro, dan toggle notifikasi. Disimpan ke SharedPreferences.
// =============================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/constants/app_constants.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _nameCtrl = TextEditingController();
  int  _focusDur   = AppConstants.defaultFocusDuration;
  int  _shortBreak = AppConstants.defaultShortBreak;
  int  _longBreak  = AppConstants.defaultLongBreak;
  bool _notifOn    = true;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _nameCtrl.text = prefs.getString(AppConstants.prefUserName) ?? '';
      _focusDur      = prefs.getInt(AppConstants.prefFocusDuration) ??
                       AppConstants.defaultFocusDuration;
      _shortBreak    = prefs.getInt(AppConstants.prefShortBreak) ??
                       AppConstants.defaultShortBreak;
      _longBreak     = prefs.getInt(AppConstants.prefLongBreak) ??
                       AppConstants.defaultLongBreak;
      _notifOn       = prefs.getBool(AppConstants.prefNotifEnabled) ?? true;
    });
  }

  Future<void> _savePrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.prefUserName, _nameCtrl.text.trim());
    await prefs.setInt(AppConstants.prefFocusDuration, _focusDur);
    await prefs.setInt(AppConstants.prefShortBreak,    _shortBreak);
    await prefs.setInt(AppConstants.prefLongBreak,     _longBreak);
    await prefs.setBool(AppConstants.prefNotifEnabled, _notifOn);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Pengaturan disimpan'),
          backgroundColor: AppColors.teal,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8)),
        ),
      );
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.navy,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: Text('Pengaturan', style: AppTypography.h3),
        actions: [
          TextButton(
            onPressed: _savePrefs,
            child: Text('Simpan',
              style: GoogleFonts.poppins(
                color: AppColors.teal, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Profil
          _SectionHeader('Profil'),
          _Card(children: [
            TextField(
              controller: _nameCtrl,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: const InputDecoration(
                labelText: 'Nama pengguna',
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
              ),
            ),
          ]),
          const SizedBox(height: 24),

          // Pomodoro
          _SectionHeader('Pomodoro timer'),
          _Card(children: [
            _SliderRow(
              label:   'Durasi fokus',
              value:   _focusDur,
              min:     15, max: 60, divisions: 9,
              unit:    'menit',
              onChanged: (v) => setState(() => _focusDur = v),
            ),
            const Divider(color: AppColors.border, height: 1),
            _SliderRow(
              label:   'Istirahat pendek',
              value:   _shortBreak,
              min:     5, max: 15, divisions: 2,
              unit:    'menit',
              onChanged: (v) => setState(() => _shortBreak = v),
            ),
            const Divider(color: AppColors.border, height: 1),
            _SliderRow(
              label:   'Istirahat panjang',
              value:   _longBreak,
              min:     10, max: 30, divisions: 4,
              unit:    'menit',
              onChanged: (v) => setState(() => _longBreak = v),
            ),
          ]),
          const SizedBox(height: 24),

          // Notifikasi
          _SectionHeader('Notifikasi'),
          _Card(children: [
            _ToggleRow(
              label:   'Pengingat blok',
              desc:    '10 menit sebelum sesi mulai',
              value:   _notifOn,
              onChanged: (v) => setState(() => _notifOn = v),
            ),
          ]),
          const SizedBox(height: 24),

          // Tentang
          _SectionHeader('Tentang'),
          _Card(children: [
            _InfoRow(label: 'Aplikasi',  value: AppConstants.appName),
            const Divider(color: AppColors.border, height: 1),
            _InfoRow(label: 'Versi',     value: '1.0.0'),
            const Divider(color: AppColors.border, height: 1),
            _InfoRow(label: 'Platform',  value: 'Flutter / Android'),
          ]),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

// ─── Sub-widgets ─────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String text;
  const _SectionHeader(this.text);

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Text(text.toUpperCase(), style: AppTypography.label),
  );
}

class _Card extends StatelessWidget {
  final List<Widget> children;
  const _Card({required this.children});

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: AppColors.border),
    ),
    child: Column(children: children),
  );
}

class _SliderRow extends StatelessWidget {
  final String label;
  final int    value;
  final double min;
  final double max;
  final int    divisions;
  final String unit;
  final ValueChanged<int> onChanged;

  const _SliderRow({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.unit,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: AppTypography.body.copyWith(fontSize: 13)),
              Text('$value $unit', style: AppTypography.monoAccent),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor:   AppColors.teal,
              inactiveTrackColor: AppColors.surface3,
              thumbColor:         AppColors.teal,
              overlayColor:       AppColors.tealDim,
              trackHeight:        3,
            ),
            child: Slider(
              value:     value.toDouble(),
              min:       min,
              max:       max,
              divisions: divisions,
              onChanged: (v) => onChanged(v.round()),
            ),
          ),
        ],
      ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  final String label;
  final String desc;
  final bool   value;
  final ValueChanged<bool> onChanged;

  const _ToggleRow({
    required this.label,
    required this.desc,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    child: Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTypography.body.copyWith(fontSize: 13)),
              const SizedBox(height: 3),
              Text(desc, style: AppTypography.caption),
            ],
          ),
        ),
        Switch(
          value:           value,
          onChanged:       onChanged,
          activeColor:     AppColors.teal,
          inactiveThumbColor: AppColors.textSecondary,
          inactiveTrackColor: AppColors.surface3,
        ),
      ],
    ),
  );
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTypography.body.copyWith(fontSize: 13)),
        Text(value, style: AppTypography.caption),
      ],
    ),
  );
}
