import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/task_service.dart';

class AdminLogsTab extends StatelessWidget {
  const AdminLogsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final TaskService taskService = TaskService();

    print("DEBUG: AdminLogsTab Build Edildi!");

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 20, 20, 10),
            child: Text(
              "Tüm Çağrı Kayıtları",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1D2939)),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<dynamic>>(
              future: taskService.getAllTasksAdmin(), // TaskService'i kullanıyoruz
              builder: (context, snapshot) {
                print("DEBUG: FutureBuilder Durumu: ${snapshot.connectionState}");

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text("Hata: ${snapshot.error}"));
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text("Henüz bir çağrı kaydı bulunmuyor."));
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) => _buildLogCard(snapshot.data![index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // GÖRSELDEKİ (admin_panel2.png) KART TASARIMI
  Widget _buildLogCard(dynamic log) {
    final String sender = log['senderName'] ?? "Müdür";
    final String receiver = log['receiverName'] ?? "Sekreter";
    final String description = log['description'] ?? "Açıklama yok";
    final String urgency = log['urgencyLevel'] ?? "Normal";
    final String createdAt = log['createdAt'] ?? "";

    String formattedDate = "";
    if (createdAt.isNotEmpty) {
      try {
        DateTime dt = DateTime.parse(createdAt);
        formattedDate = DateFormat('yyyy-MM-dd HH:mm').format(dt);
      } catch (e) {
        formattedDate = createdAt;
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  "Gönderen: $sender, Alıcı: $receiver",
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: Color(0xFF101828)),
                ),
              ),
              Text(formattedDate, style: const TextStyle(color: Color(0xFF667085), fontSize: 13)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            "Açıklama: $description",
            style: const TextStyle(color: Color(0xFF475467), fontSize: 14, height: 1.4),
          ),
          const SizedBox(height: 12),
          _buildUrgencyBadge(urgency),
        ],
      ),
    );
  }

  Widget _buildUrgencyBadge(String urgency) {
    Color color;
    Color bgColor;

    if (urgency == "Acil") {
      color = const Color(0xFFD92D20);
      bgColor = const Color(0xFFFEE4E2);
    } else if (urgency == "Normal" || urgency == "Orta") {
      color = const Color(0xFFB54708);
      bgColor = const Color(0xFFFFFAEB);
    } else {
      color = const Color(0xFF067647);
      bgColor = const Color(0xFFECFDF3);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(16)),
      child: Text(urgency, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }
}