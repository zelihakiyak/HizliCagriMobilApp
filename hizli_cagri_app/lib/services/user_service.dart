import 'dart:convert';
import 'package:http/http.dart' as http;

class UserService {
  // Web için:  "http://localhost:5065/api/Users" , Emülatör için: "http://10.0.2.2:5065/api/Users"
  final String baseUrl ="http://10.0.2.2:5065/api/Users";

  // Onay bekleyen sekreterleri getir (IsApproved = false)
  Future<List<dynamic>> getPendingUsers() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/pending'));
      if (response.statusCode == 200) return jsonDecode(response.body);
      return [];
    } catch (e) {
      return [];
    }
  }

  // Kullanıcıyı onayla (PUT isteği)
  Future<bool> approveUser(int userId) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/$userId/approve'));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // Admin tarafından yeni Müdür eklenmesi
  Future<bool> addManager(Map<String, dynamic> managerData) async {
    try {
      print("Müdür ekleme isteği gönderiliyor: ${managerData['fullName']}");

      final response = await http.post(
        Uri.parse("$baseUrl/add-manager"), 
        headers: {      
          "Content-Type": "application/json; charset=UTF-8",
          "Accept": "application/json",
        },
        body: jsonEncode(managerData),
      );

      print("API Yanıt Kodu: ${response.statusCode}");
      print("API Yanıtı: ${response.body}");

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print("Müdür ekleme servisi hatası: $e");
      return false;
    }
  }

  //Belirli bir şirkete ait sekreterleri getir 
  Future<List<dynamic>> getSecretariesByDept(int companyId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/secretaries/$companyId'));

      if (response.statusCode == 200) {
        return jsonDecode(response.body); // JSON listesini döndürür
      } else {
        print("Veri Çekme Hatası: ${response.body}");
        return [];
      }
    } catch (e) {
      print("Bağlantı Hatası: $e");
      return [];
    }
  }

  Future<Map<String, dynamic>?> getManagerByDepartment(int departmentId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/manager-of-dept/$departmentId'),
        headers: {"Accept": "application/json"},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body); 
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<Map<String, dynamic>?> getUserById(int userId) async {
    final String url = "http://10.0.2.2:5065/api/Users/$userId"; 
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return null;
    } catch (e) {
      print("Kullanıcı bilgisi çekilemedi: $e");
      return null;
    }
  }
  Future<Map<String, dynamic>?> getDepartmentById(int deptId) async {
    final String url = "http://10.0.2.2:5065/api/Departments/$deptId";
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return null;
    } catch (e) {
      print("Departman bilgisi çekilemedi: $e");
      return null;
    }
  }

  Future<bool> deleteUser(int userId) async {
    final String url = "http://10.0.2.2:5065/api/Users/$userId";
    try {
      print("Kullanıcı siliniyor... ID: $userId");
      final response = await http.delete(Uri.parse(url));
      
      // 200 (OK) veya 204 (No Content) başarılı sayılır
      if (response.statusCode == 200 || response.statusCode == 204) {
        print("Kullanıcı başarıyla silindi.");
        return true;
      } else {
        print("Silme hatası. Status Code: ${response.statusCode}");
        return false;
      }
    } catch (e) {
      print("User Service Silme Hatası: $e");
      return false;
    }
  }

}