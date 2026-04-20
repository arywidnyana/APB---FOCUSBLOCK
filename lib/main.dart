// FILE: lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart'; // ← tambah ini
import 'app/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ← tambah baris ini — wajib sebelum pakai DateFormat('id_ID')
  await initializeDateFormatting('id_ID', null);

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor:           Colors.transparent,
      statusBarIconBrightness:  Brightness.light,
      systemNavigationBarColor: Color(0xFF161B22),
    ),
  );

  runApp(const FocusBlockApp());
}