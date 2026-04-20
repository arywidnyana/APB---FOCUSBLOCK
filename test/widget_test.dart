import 'package:flutter_test/flutter_test.dart';
// Ganti 'flutter_application_1' dengan nama project Anda jika berbeda
import 'package:flutter_application_1/app/app.dart'; 

void main() {
  testWidgets('App launch test', (WidgetTester tester) async {
    // Memanggil FocusBlockApp, bukan MyApp
    await tester.pumpWidget(const FocusBlockApp());

    // Mengecek apakah AppBar dengan judul FocusBlock berhasil dimuat
    expect(find.text('FocusBlock'), findsWidgets);
  });
}