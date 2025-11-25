import 'package:flutter/material.dart';
import 'screens/login_screen.dart'; // LoginScreen dosyasını buraya dahil ediyoruz

// lib/main.dart içinde import ekleyin
//import 'screens/manager_home_screen.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Login Demo',
      theme: ThemeData(
        fontFamily: 'Poppins',
        useMaterial3: true,
      ),
      // Uygulama açıldığında gösterilecek ilk ekran:
      // home kısmını değiştirin:
      home: const LoginScreen(),
    );
  }
}