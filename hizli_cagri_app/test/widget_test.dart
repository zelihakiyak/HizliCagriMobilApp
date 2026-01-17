import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hizli_cagri/main.dart';
import 'package:hizli_cagri/screens/login_screen.dart';

void main() {
  testWidgets('Uygulama başlatma testi', (WidgetTester tester) async {
    // MyApp artık 'initialScreen' parametresi beklediği için buraya başlangıç ekranını veriyoruz.
    await tester.pumpWidget(const MyApp(initialScreen: LoginScreen()));

    // Örnek: Giriş ekranında "Hoş Geldiniz" metninin olup olmadığını kontrol edelim
    // (Kendi tasarımındaki bir metni buraya yazmalısın)
    expect(find.text('Hoş Geldiniz'), findsOneWidget);
  });
}