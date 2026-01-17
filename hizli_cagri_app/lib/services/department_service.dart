import 'dart:convert';
import 'package:http/http.dart' as http;

class DepartmentService {
  final String baseUrl = "http://10.0.2.2:5065/api/Departments";

  Future<List<dynamic>> getDepartments() async {
    try {
      final response = await http.get(Uri.parse(baseUrl));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return [];
    } catch (e) {
      print("Departman getirme hatası: $e");
      return [];
    }
  }

  
  Future<bool> addDepartment(String name) async {
    try {
      print("İstek gönderiliyor: $name"); 

      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {"Content-Type": "application/json; charset=utf-8"},
      
        body: jsonEncode({"name": name}), 
      );

      print("API Yanıt Kodu: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        print("Ekleme Başarılı");
        return true;
      } else {
        print("API Hata Mesajı: ${response.body}");
        return false;
      }
    } catch (e) {
      print("Bağlantı Hatası: $e");
      return false;
    }
  }
}