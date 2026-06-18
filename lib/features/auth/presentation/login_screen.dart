// =============================================================
// FILE: lib/features/auth/presentation/login_screen.dart
// TANGGUNG JAWAB: Login & register NYATA. Google Sign In NYATA.
//   Tidak ada case bisa masuk tanpa isi apapun — semua tervalidasi.
// =============================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../provider/auth_provider.dart' as ap;

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  late TabController _tabs;
  final _emailCtrl    = TextEditingController();
  final _passCtrl     = TextEditingController();
  final _nameCtrl     = TextEditingController();
  final _emailRegCtrl = TextEditingController();
  final _passRegCtrl  = TextEditingController();
  bool _obscure = true;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    _emailCtrl.dispose(); _passCtrl.dispose();
    _nameCtrl.dispose(); _emailRegCtrl.dispose(); _passRegCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.navy,
      body: Consumer<ap.AuthProvider>(
        builder: (context, auth, _) {
          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                children: [
                  const SizedBox(height: 48),
                  Container(
                    width: 72, height: 72,
                    decoration: BoxDecoration(
                      color: AppColors.teal, borderRadius: BorderRadius.circular(20)),
                    child: const Icon(Icons.bolt, color: AppColors.navy, size: 40),
                  ),
                  const SizedBox(height: 20),
                  Text('FocusBlock', style: AppTypography.h1),
                  const SizedBox(height: 6),
                  Text('Smart Study Planner',
                    style: AppTypography.bodyMuted.copyWith(color: AppColors.teal)),
                  const SizedBox(height: 32),

                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface2, borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.all(4),
                    child: TabBar(
                      controller: _tabs,
                      labelColor: AppColors.textPrimary,
                      unselectedLabelColor: AppColors.textSecondary,
                      indicator: BoxDecoration(
                        color: AppColors.surface, borderRadius: BorderRadius.circular(8),
                        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)]),
                      indicatorSize: TabBarIndicatorSize.tab,
                      dividerColor: Colors.transparent,
                      labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13),
                      tabs: const [Tab(text: 'Masuk'), Tab(text: 'Daftar')],
                      onTap: (_) => auth.clearError(),
                    ),
                  ),
                  const SizedBox(height: 20),

                  if (auth.errorMessage != null) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.coralDim, borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.coral.withOpacity(0.4))),
                      child: Row(children: [
                        const Icon(Icons.error_outline, size: 16, color: AppColors.coral),
                        const SizedBox(width: 8),
                        Expanded(child: Text(auth.errorMessage!,
                          style: AppTypography.caption.copyWith(color: AppColors.coral))),
                      ]),
                    ),
                    const SizedBox(height: 14),
                  ],

                  SizedBox(
                    height: 340,
                    child: TabBarView(
                      controller: _tabs,
                      children: [_buildLogin(auth), _buildRegister(auth)],
                    ),
                  ),
                  const SizedBox(height: 20),

                  Row(children: [
                    const Expanded(child: Divider(color: AppColors.border)),
                    Padding(padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text('atau', style: AppTypography.caption)),
                    const Expanded(child: Divider(color: AppColors.border)),
                  ]),
                  const SizedBox(height: 20),

                  // Google Sign In — NYATA
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: auth.loading ? null : () async {
                        await auth.signInWithGoogle();
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.border),
                        foregroundColor: AppColors.textPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: auth.loading
                          ? const SizedBox(width: 18, height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.teal))
                          : const Icon(Icons.g_mobiledata, size: 24),
                      label: Text('Lanjutkan dengan Google',
                        style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500)),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLogin(ap.AuthProvider auth) {
    return Column(
      children: [
        _buildField(ctrl: _emailCtrl, label: 'Email',
          hint: 'email@student.telkomuniversity.ac.id', icon: Icons.email_outlined),
        const SizedBox(height: 16),
        _buildField(ctrl: _passCtrl, label: 'Password', hint: '••••••••',
          icon: Icons.lock_outline, obscure: _obscure,
          suffix: IconButton(
            icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
              size: 18, color: AppColors.textSecondary),
            onPressed: () => setState(() => _obscure = !_obscure))),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: auth.loading ? null : () async {
              await auth.signIn(email: _emailCtrl.text, password: _passCtrl.text);
            },
            child: auth.loading
                ? const SizedBox(width: 20, height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.navy))
                : const Text('Masuk'),
          ),
        ),
      ],
    );
  }

  Widget _buildRegister(ap.AuthProvider auth) {
    return Column(
      children: [
        _buildField(ctrl: _nameCtrl, label: 'Nama lengkap',
          hint: 'contoh: Tegar Imansyah', icon: Icons.person_outline),
        const SizedBox(height: 12),
        _buildField(ctrl: _emailRegCtrl, label: 'Email',
          hint: 'email@student.telkomuniversity.ac.id', icon: Icons.email_outlined),
        const SizedBox(height: 12),
        _buildField(ctrl: _passRegCtrl, label: 'Password', hint: 'minimal 6 karakter',
          icon: Icons.lock_outline, obscure: _obscure,
          suffix: IconButton(
            icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
              size: 18, color: AppColors.textSecondary),
            onPressed: () => setState(() => _obscure = !_obscure))),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: auth.loading ? null : () async {
              await auth.register(
                name: _nameCtrl.text, email: _emailRegCtrl.text, password: _passRegCtrl.text);
            },
            child: auth.loading
                ? const SizedBox(width: 20, height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.navy))
                : const Text('Buat Akun'),
          ),
        ),
      ],
    );
  }

  Widget _buildField({
    required TextEditingController ctrl, required String label, required String hint,
    required IconData icon, bool obscure = false, Widget? suffix,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(), style: AppTypography.label),
        const SizedBox(height: 8),
        TextField(
          controller: ctrl, obscureText: obscure,
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, size: 18, color: AppColors.textSecondary),
            suffixIcon: suffix,
          ),
        ),
      ],
    );
  }
}
