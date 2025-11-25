import 'dart:convert';
import 'package:http/http.dart' as http;

class UserService {
  // Web için localhost, Emülatör için 10.0.2.2
  final String baseUrl = "http://localhost:5065/api/Users";

  // Sekreterleri Getirme Fonksiyonu
  Future<List<dynamic>> getSecretaries() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/secretaries'));

      if (response.statusCode == 200) {
        // Gelen JSON listesini döndürür (Örn: [{"id": 2, "fullName": "Ayşe"}, ...])
        return jsonDecode(response.body);
      } else {
        print("Veri Çekme Hatası: ${response.body}");
        return [];
      }
    } catch (e) {
      print("Bağlantı Hatası: $e");
      return [];
    }
  }
}