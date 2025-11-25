import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  // Android Emülatör için localhost yerine 10.0.2.2 kullanılır. "http://10.0.2.2:5065/api/Auth"
  // Eğer gerçek cihazdaysanız bilgisayarınızın IP adresini yazmalısınız (örn: 192.168.1.35)
  // Port numaranızı (5065) buraya yazdığınızdan emin olun.
  final String baseUrl = "http://localhost:5065/api/Auth";

  // Giriş Yapma Fonksiyonu
  Future<Map<String, dynamic>?> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": email,
          "password": password,
        }),
      );

      if (response.statusCode == 200) {
        // Başarılı ise gelen veriyi (User ID, Role vb.) döndür
        return jsonDecode(response.body);
      } else {
        // Hata varsa null döndür veya hatayı konsola bas
        print("Giriş Hatası: ${response.body}");
        return null;
      }
    } catch (e) {
      print("Bağlantı Hatası: $e");
      return null;
    }
  }

  // Kayıt Olma Fonksiyonu
  Future<bool> register(String fullName, String email, String password, String role, String company) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "fullName": fullName,
          "email": email,
          "password": password,
          "role": role,
          "company": company,
        }),
      );

      if (response.statusCode == 200) {
        return true; // Kayıt başarılı
      } else {
        print("Kayıt Hatası: ${response.body}");
        return false;
      }
    } catch (e) {
      print("Bağlantı Hatası: $e");
      return false;
    }
  }
}