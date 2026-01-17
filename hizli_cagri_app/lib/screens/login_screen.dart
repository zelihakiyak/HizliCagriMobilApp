import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';
import 'admin_home_screen.dart';
import 'manager_home_screen.dart';
import 'secretary_home_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _rememberMe = false; 
  bool _isLoading = false;
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB), 
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // BAŞLIK
              const Text(
                "Hoş Geldiniz",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1D2939), 
                ),
              ),
              const SizedBox(height: 48),

              // KULLANICI ADI (E-POSTA) ALANI
              _buildInputLabelField(
                hint: "Kullanıcı Adı",
                controller: _emailController,
              ),
              const SizedBox(height: 20),

              // ŞİFRE ALANI
              _buildInputLabelField(
                hint: "Şifre",
                controller: _passwordController,
                isPassword: true,
              ),
              const SizedBox(height: 12),

              // BENİ HATIRLA
              Row(
                children: [
                  SizedBox(
                    height: 24,
                    width: 24,
                    child: Checkbox(
                      value: _rememberMe,
                      onChanged: (val) => setState(() => _rememberMe = val!),
                      activeColor: const Color(0xFF6366F1),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    "Beni Hatırla",
                    style: TextStyle(color: Color(0xFF475467), fontSize: 14),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // GİRİŞ YAP BUTONU
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF637BFF), // Görseldeki canlı mavi
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          "Giriş Yap",
                          style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.w600),
                        ),
                ),
              ),
              const SizedBox(height: 24),

              // KAYDOL LİNKİ
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Hesabınız yok mu? ", style: TextStyle(color: Color(0xFF475467))),
                  GestureDetector(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const RegisterScreen())),
                    child: const Text(
                      "Kaydol",
                      style: TextStyle(color: Color(0xFF637BFF), fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputLabelField({required String hint, required TextEditingController controller, bool isPassword = false}) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFE9EDF5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Color(0xFF98A2B3)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Future<void> _handleLogin() async {
    print("Giriş butonu tıklandı!");

    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Lütfen tüm alanları doldurun.")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      print("AuthService çağrılıyor...");
      var user = await _authService.login(email, password);

      if (user != null) {
        print("Giriş başarılı, Rol: ${user['role']}");

        // 1. OTURUM BİLGİLERİNİ KAYDET
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
        await prefs.setString('role', user['role']);
        await prefs.setInt('userId', user['id']);
        
        if (user['departmentId'] != null) {
          await prefs.setInt('departmentId', user['departmentId']);
        }
        // BENİ HATIRLA 
        if (_rememberMe) { 
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('isLoggedIn', true);
          await prefs.setInt('userId', user['id']);
          await prefs.setInt('deptId', user['departmentId'] ?? 0);
          await prefs.setString('role', user['role']);
        }
        // 2. RÖLE GÖRE EKRANLARA YÖNLENDİR
        if (!mounted) return;

        Widget nextScreen;
        
        switch (user['role']) {
          case "Admin":
            nextScreen = AdminHomeScreen(
              currentUserId: user['id'],
            );
            break;
          case "Mudur":
            nextScreen = ManagerHomeScreen(
              currentUserId: user['id'],
              currentDepartmentId: user['departmentId'] ?? 0,
            );
            break;
          case "Sekreter":
            nextScreen = SecretaryHomeScreen(
              currentUserId: user['id'],
              currentDepartmentId: user['departmentId'] ?? 0,
            );
            break;
          default:
            nextScreen = const LoginScreen(); // Bilinmeyen rol durumu
        }

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => nextScreen),
          (route) => false,
        );

      } else {
        print("Kullanıcı null döndü");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Giriş Başarısız! E-posta veya şifre hatalı.")),
        );
      }
    } catch (e) {
      print("LoginScreen Hatası: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Sunucuya bağlanırken bir hata oluştu.")),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}