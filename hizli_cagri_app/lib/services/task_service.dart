import 'dart:convert';
import 'package:http/http.dart' as http;

class TaskService {
  // Web için localhost, Emülatör için 10.0.2.2
  final String baseUrl = "http://localhost:5065/api/Tasks";

  // Görev Oluşturma Fonksiyonu
  Future<bool> createTask({
    required String title,
    required String description,
    required String urgency,
    required int assignedToUserId, // Sekreter ID
    required int assignedByUserId, // Müdür ID
  }) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "title": title,
          "description": description,
          "urgencyLevel": urgency,
          "assignedToUserId": assignedToUserId,
          "assignedByUserId": assignedByUserId,
        }),
      );

      if (response.statusCode == 201) {
        return true; // Başarılı (201 Created)
      } else {
        print("Görev Oluşturma Hatası: ${response.body}");
        return false;
      }
    } catch (e) {
      print("Bağlantı Hatası: $e");
      return false;
    }
  }
  // Belirli bir sekretere ait görevleri getir
  Future<List<dynamic>> getTasksBySecretaryId(int secretaryId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/secretary/$secretaryId'));

      if (response.statusCode == 200) {
        return jsonDecode(response.body); // Görev listesi döner
      } else {
        print("Görev Çekme Hatası: ${response.body}");
        return [];
      }
    } catch (e) {
      print("Bağlantı Hatası: $e");
      return [];
    }
  }
  // Görevi Tamamla
  Future<bool> completeTask(int taskId) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/$taskId/complete'),
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        print("Tamamlama Hatası: ${response.body}");
        return false;
      }
    } catch (e) {
      print("Bağlanti Hatasi: $e");
      return false;
    }
  }
}