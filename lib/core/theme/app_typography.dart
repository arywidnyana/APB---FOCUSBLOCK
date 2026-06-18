// FILE: lib/core/theme/app_typography.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTypography {
  AppTypography._();

  static TextStyle get h1 => GoogleFonts.poppins(
    fontSize: 28, fontWeight: FontWeight.w700, color: AppColors.textPrimary);
  static TextStyle get h2 => GoogleFonts.poppins(
    fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.textPrimary);
  static TextStyle get h3 => GoogleFonts.poppins(
    fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary);
  static TextStyle get h4 => GoogleFonts.poppins(
    fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary);

  static TextStyle get body => GoogleFonts.inter(
    fontSize: 14, fontWeight: FontWeight.w400, color: AppColors.textPrimary);
  static TextStyle get bodyMuted => GoogleFonts.inter(
    fontSize: 14, fontWeight: FontWeight.w400, color: AppColors.textSecondary);
  static TextStyle get caption => GoogleFonts.inter(
    fontSize: 12, fontWeight: FontWeight.w400, color: AppColors.textSecondary);
  static TextStyle get label => GoogleFonts.inter(
    fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.textTertiary,
    letterSpacing: 0.08);

  static TextStyle get mono => GoogleFonts.jetBrainsMono(
    fontSize: 12, color: AppColors.textSecondary);
  static TextStyle get monoAccent => GoogleFonts.jetBrainsMono(
    fontSize: 12, color: AppColors.teal);

  static TextStyle get scoreHuge => GoogleFonts.poppins(
    fontSize: 52, fontWeight: FontWeight.w700, color: AppColors.teal, height: 1.0);
}
