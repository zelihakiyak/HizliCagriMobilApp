import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class TaskService {

  final String _baseUrl = "http://10.0.2.2:5065/api/Tasks";

  Map<String, String> get _headers => {
    "Content-Type": "application/json; charset=UTF-8",
    "Accept": "application/json",
  };

  // --- 1. GÖREV / ÇAĞRI OLUŞTURMA (Müdür -> Sekreter) ---
  Future<bool> createTask(Map<String, dynamic> taskData) async {
    try {
     if (taskData['title'] == null || taskData['assignedToUserId'] == null) {
        debugPrint("Hata: Başlık veya Alıcı ID eksik.");
        return false;
      }

      final mappedData = {
        "Title": taskData['title'],
        "Description": taskData['description'] ?? "",
        "UrgencyLevel": taskData['urgencyLevel'] ?? "Normal",
        "AssignedToUserId": taskData['assignedToUserId'],
        "AssignedByUserId":taskData['assignedByUserId'],  
        "Status": "Yeni",
        "IsUrgent": taskData['isUrgent'] ?? false,
      };

      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: _headers,
        body: jsonEncode(mappedData),
      );

      _logResponse("createTask", response);
      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      _logError("createTask", e);
      return false;
    }
  }

  // --- 2. SEKRETERE ÖZEL GÖREVLERİ GETİR ---
  Future<List<dynamic>> getTasksBySecretary(int secretaryId) async {
  final url = Uri.parse("http://10.0.2.2:5065/api/Tasks/secretary/$secretaryId");
  try {
    final response = await http.get(url).timeout(const Duration(seconds: 10)); // 10 saniye limit
    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    return [];
  } catch (e) {
    debugPrint("Hata: $e");
    return [];
  }
}

  // --- 3. ADMIN: TÜM ÇAĞRI KAYITLARINI GETİR ---
Future<List<dynamic>> getAllTasksAdmin() async {
  final String adminUrl = "http://10.0.2.2:5065/api/Admin/all-logs";
  
  debugPrint("!!! İSTEĞİ ATIYORUM: $adminUrl");
  try {
    final response = await http.get(
      Uri.parse(adminUrl),
      headers: {"Accept": "application/json; charset=UTF-8"},
    ).timeout(const Duration(seconds: 10)); // Zaman aşımı ekledik

    print("Status Code: ${response.statusCode}");
    
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      print("Basarili! Gelen Kayit Sayisi: ${data.length}");
      return data;
    } else {
      print("Hata Kodlu Yanit: ${response.body}");
    
      throw Exception("Sunucu hatası: ${response.statusCode}");
    }
  } catch (e) {
    print("--- BAGLANTI HATASI DETAYI ---");
    print(e.toString());
    rethrow; // Hatayı UI katmanına ilet
  }
}

  // --- 4. GÖREV DURUMU GÜNCELLEME ---
  Future<bool> updateTaskStatus(int taskId, String status) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/$taskId/status'),
        headers: _headers,
        body: jsonEncode(status), 
      );

      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      _logError("updateTaskStatus", e);
      return false;
    }
  }

  void _logResponse(String methodName, http.Response response) {
    debugPrint("--- API LOG: $methodName ---");
    debugPrint("Statü: ${response.statusCode}");
    debugPrint("Veri: ${response.body}");
  }

  void _logError(String methodName, dynamic e) {
    debugPrint("--- API ERROR: $methodName ---");
    debugPrint("Hata Detayı: $e");
  }
}