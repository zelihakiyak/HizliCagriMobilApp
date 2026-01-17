import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
class AuthService {
  // Android Emülatör: "http://10.0.2.2:5065/api/Auth" //web için "http://localhost:5065/api/Auth"
  final String baseUrl = "http://10.0.2.2:5065/api/Auth";


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
        
        return jsonDecode(response.body);
      } else {
       
        print("Giriş Hatası: ${response.body}");
        return null;
      }
    } catch (e) {
      print("Bağlantı Hatası: $e");
      return null;
    }
  }


  Future<bool> register({
    required String fullName,
    required String email,
    required String password,
    required int departmentId,
    required String role,
  }) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/register"), 
        headers: {
          "Content-Type": "application/json; charset=UTF-8", 
          "Accept": "application/json",
        },
        body: jsonEncode({
          "FullName": fullName, 
          "Email": email,
          "Password": password,
          "DepartmentId": departmentId,
          "Role": role,
        }),
      );

      print("Kayıt Yanıt Kodu: ${response.statusCode}");
      print("Kayıt Yanıtı: ${response.body}");

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print("Kayıt sırasında istisna: $e");
      return false;
    }
  }
 
  Future<void> saveUser(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
    await prefs.setInt('userId', userData['id']);
    await prefs.setString('role', userData['role']);
    if (userData['departmentId'] != null) {
      await prefs.setInt('departmentId', userData['departmentId']);
    }
  }
  
  Future<void> saveUserLogin(int userId, int departmentId, String role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('userId', userId);
    await prefs.setInt('deptId', departmentId);
    await prefs.setString('role', role);
    await prefs.setBool('isLoggedIn', true);
  }
  
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}