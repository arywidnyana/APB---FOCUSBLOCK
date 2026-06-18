// FILE: lib/core/theme/app_colors.dart
import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color navy        = Color(0xFF0D1117);
  static const Color surface     = Color(0xFF161B22);
  static const Color surface2    = Color(0xFF21262D);
  static const Color surface3    = Color(0xFF30363D);

  static const Color teal        = Color(0xFF00D4AA);
  static const Color tealDim     = Color(0x2200D4AA);
  static const Color tealMid     = Color(0x6600D4AA);
  static const Color coral       = Color(0xFFFF6B6B);
  static const Color coralDim    = Color(0x22FF6B6B);
  static const Color amber       = Color(0xFFFFD93D);
  static const Color amberDim    = Color(0x22FFD93D);

  static const Color textPrimary   = Color(0xFFE6EDF3);
  static const Color textSecondary = Color(0xFF8B949E);
  static const Color textTertiary  = Color(0xFF484F58);

  static const Color border      = Color(0xFF30363D);

  static Color statusColor(String status) {
    switch (status) {
      case 'done':    return teal;
      case 'missed':  return coral;
      case 'ongoing': return amber;
      default:        return surface3;
    }
  }

  static Color statusBg(String status) {
    switch (status) {
      case 'done':    return tealDim;
      case 'missed':  return coralDim;
      case 'ongoing': return amberDim;
      default:        return surface3;
    }
  }
}
