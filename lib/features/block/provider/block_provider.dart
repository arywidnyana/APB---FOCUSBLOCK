// =============================================================
// FILE: lib/features/block/provider/block_provider.dart
// VERSI: DUMMY — tanpa database
// =============================================================

import 'package:flutter/foundation.dart';

class BlockProvider extends ChangeNotifier {
  bool    _saving = false;
  String? _error;

  bool    get saving => _saving;
  String? get error  => _error;

  Future<bool> saveBlock({
    required String   subject,
    required String   sessionName,
    required DateTime startTime,
    required int      plannedDuration,
  }) async {
    if (subject.isEmpty || sessionName.isEmpty) {
      _error = 'Semua field wajib diisi';
      notifyListeners();
      return false;
    }

    _saving = true;
    _error  = null;
    notifyListeners();

    // Simulasi delay simpan
    await Future.delayed(const Duration(milliseconds: 500));

    _saving = false;
    notifyListeners();
    return true; // selalu berhasil untuk demo
  }
}