import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart'; 
import 'package:intl/date_symbol_data_local.dart'; 

// Kendi dosya yolların (Hata alıyorsan bu yolları kontrol et)
import 'screens/login_screen.dart';
import 'screens/admin_home_screen.dart';
import 'screens/manager_home_screen.dart';
import 'screens/secretary_home_screen.dart';

void main() async {
  // 1. Flutter motorunun asenkron işlemler için hazır olduğundan emin oluyoruz
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Türkçe tarih ve saat formatlarını başlatıyoruz (Hata buradaydı)
  await initializeDateFormatting('tr_TR', null);

  // 3. Cihaz hafızasındaki (SharedPreferences) verilere erişiyoruz
  final prefs = await SharedPreferences.getInstance();
  final bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
  final String? role = prefs.getString('role');

  // 4. Başlangıç ekranını varsayılan olarak LoginScreen yapıyoruz
  Widget startScreen = const LoginScreen();

  // 5. Eğer kullanıcı giriş yapmışsa ilgili ekrana yönlendiriyoruz
  if (isLoggedIn && role != null) {
    final int userId = prefs.getInt('userId') ?? 0;
    final int deptId = prefs.getInt('departmentId') ?? 0;

    if (role == "Admin") {
      startScreen = AdminHomeScreen(currentUserId: userId);
    } else if (role == "Mudur") {
      startScreen = ManagerHomeScreen(
        currentUserId: userId,
        currentDepartmentId: deptId,
      );
    } else if (role == "Sekreter") {
      startScreen = SecretaryHomeScreen(
        currentUserId: userId,
        currentDepartmentId: deptId,
      );
    }
  }

  // 6. Uygulamayı başlatıyoruz
  runApp(MyApp(initialScreen: startScreen));
}

class MyApp extends StatelessWidget {
  final Widget initialScreen;

  const MyApp({super.key, required this.initialScreen});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Hızlı Çağrı Sistemi',
      
      // TÜRKÇE KARAKTER VE DİL DESTEĞİ AYARLARI:
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('tr', 'TR'), 
      ],
      locale: const Locale('tr', 'TR'),
      
      theme: ThemeData(
        fontFamily: 'Poppins', 
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF637BFF),
          brightness: Brightness.light,
        ),
      ),
      home: initialScreen,
    );
  }
}