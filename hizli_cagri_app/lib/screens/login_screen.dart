import 'package:flutter/material.dart';
import 'register_screen.dart';
import 'manager_home_screen.dart';
import 'secretary_home_screen.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService(); // Servisi çağırdık
  bool _rememberMe = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Text(
                  'Hoş Geldiniz',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1F36),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              _buildTextField(hintText: 'E-posta', controller: _emailController),
              const SizedBox(height: 16),
              _buildTextField(hintText: 'Şifre', obscureText: true, controller: _passwordController),
              const SizedBox(height: 16),
              Row(
                children: [
                  SizedBox(
                    height: 24,
                    width: 24,
                    child: Checkbox(
                      value: _rememberMe,
                      activeColor: const Color(0xFF5C7CFA),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      side: const BorderSide(color: Colors.grey),
                      onChanged: (value) {
                        setState(() {
                          _rememberMe = value!;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Beni Hatırla',
                    style: TextStyle(color: Color(0xFF4A4A4A)),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                 onPressed: () async {
                  
                  String email = _emailController.text.trim();
                  String password = _passwordController.text.trim();

                  if (email.isEmpty || password.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Lütfen tüm alanları doldurun")),
                    );
                    return;
                  }

                  // API'ye soruyoruz...
                  var user = await _authService.login(email, password);

                  if (user != null) {
                    // Giriş Başarılı!
                    String role = user['role']; // API'den gelen rol (Mudur/Sekreter)
                    int userId = user['id'];
                    // Gelen verideki ID'yi ileride kullanmak için saklayabiliriz (şimdilik geçiyoruz)
                    
                    if (role == "Mudur") {
                      Navigator.pushReplacement(
                        context, 
                        MaterialPageRoute(builder: (context) => const ManagerHomeScreen())
                      );
                    } else {
                      Navigator.pushReplacement(
                        context, 
                        MaterialPageRoute(builder: (context) => SecretaryHomeScreen(currentUserId: userId))
                      );
                    }
                  } else {
                    // Giriş Başarısız
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("E-posta veya şifre hatalı!")),
                    );
                  }
                },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5C7CFA),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Giriş Yap',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Hesabınız yok mu? ',
                    style: TextStyle(color: Color(0xFF4A4A4A)),
                  ),
                  
                  GestureDetector(
                    onTap: () {
                      // Login sayfasından Register sayfasına geçiş kodu:
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const RegisterScreen()),
                      );
                    },
                    child: const Text(
                      'Kaydol',
                      style: TextStyle(
                        color: Color(0xFF5C7CFA),
                        fontWeight: FontWeight.w500,
                      ),
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

  Widget _buildTextField({
    required String hintText, 
    bool obscureText = false,
    required TextEditingController controller
    }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFE8EDF2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          hintText: hintText,
          hintStyle: const TextStyle(color: Colors.grey),
        ),
      ),
    );
  }
}