import 'dart:convert';
import 'package:http/http.dart' as http;

class ScheduleService {

  final String _baseUrl = "http://10.0.2.2:5065/api/Schedules";

  // --- 1. PROGRAM OLUŞTURMA (Sekreter için) ---
  Future<bool> createSchedule(Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {"Content-Type": "application/json"},
        body: json.encode(data),
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print("Program oluşturma hatası: $e");
      return false;
    }
  }

  // --- 2. ONAY BEKLEYEN PROGRAMLARI GETİR (Müdür için) ---
  Future<List<dynamic>> getPendingSchedules(int managerId) async {
    final String url = "$_baseUrl/pending/$managerId";
    
    try {
      final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return [];
    } catch (e) {
      print("Bağlantı Hatası: $e");
      return [];
    }
  }

  // --- 3. PROGRAM ONAY DURUMUNU GÜNCELLE (Müdür için) ---
  Future<bool> updateScheduleStatus(int id, bool isApproved, {String? feedback}) async {
    try {
      final response = await http.put(
        Uri.parse("$_baseUrl/$id/status"),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "isApproved": isApproved,
          "feedback": feedback
        }),
      );
      return response.statusCode == 200;
    } catch (e) {
      print("Güncelleme Hatası: $e");
      return false;
    }
  }

  // --- 4. ONAYLI PROGRAMLARI GETİR (Sekreter/Müdür Takvimi için) ---
  Future<List<dynamic>> getApprovedSchedules(int departmentId) async {
    try {
      final response = await http.get(
        Uri.parse("$_baseUrl/approved/$departmentId"),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return [];
    } catch (e) {
      print("Onaylı programlar çekilemedi: $e");
      return [];
    }
  }
  Future<List<dynamic>> getRejectedSchedules(int departmentId) async {
    final String url = "$_baseUrl/rejected/$departmentId";
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return [];
    } catch (e) {
      print("Reddedilen programlar çekilemedi: $e");
      return [];
    }
  }
  // --- 5. PROGRAMI GÜNCELLE (Sekreter için) ---
  Future<bool> updateSchedule(int id, Map<String, dynamic> data) async {
    try {
      final response = await http.put(
        Uri.parse("$_baseUrl/$id"), 
        headers: {"Content-Type": "application/json"},
        body: json.encode(data),
      );

      print("API Yanıt Kodu: ${response.statusCode}");
      print("API Yanıt Gövdesi: ${response.body}");

      // API 200 veya 201 döndüğünde başarılı kabul et
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print("Güncelleme hatası: $e");
      return false;
    }
  }
}