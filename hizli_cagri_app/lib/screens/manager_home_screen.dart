import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';
import '../services/task_service.dart';
import '../services/schedule_service.dart';
import 'login_screen.dart';

class ManagerHomeScreen extends StatefulWidget {
  final int currentUserId;
  final int currentDepartmentId;

  const ManagerHomeScreen({
    super.key,
    required this.currentUserId,
    required this.currentDepartmentId,
  });

  @override
  State<ManagerHomeScreen> createState() => _ManagerHomeScreenState();
}

class _ManagerHomeScreenState extends State<ManagerHomeScreen> {
  final UserService _userService = UserService();
  final TaskService _taskService = TaskService();
  final AuthService _authService = AuthService();
  final ScheduleService _scheduleService = ScheduleService();

  int _currentIndex = 1; 
  DateTime _selectedDate = DateTime.now();
  final DateTime _today = DateTime.now();

  Future<List<dynamic>>? _pendingFuture;
  Future<List<dynamic>>? _approvedFuture;

  String _managerFullName = "Yükleniyor...";
  String _deptName = "Yükleniyor...";

  @override
  void initState() {
    super.initState();
    _refreshAllData();
    _loadManagerProfile();
  }

  void _refreshAllData() {
    setState(() {
      _pendingFuture = _scheduleService.getPendingSchedules(widget.currentUserId);
      _approvedFuture = _scheduleService.getApprovedSchedules(widget.currentUserId);
    });
  }

  Future<void> _loadManagerProfile() async {
    try {
      print("DEBUG: Profil bilgileri çekiliyor... ID: ${widget.currentUserId}");
      
      final userData = await _userService.getUserById(widget.currentUserId);
      print("DEBUG: User API'den gelen ham veri: $userData");

      final deptData = await _userService.getDepartmentById(widget.currentDepartmentId);
      print("DEBUG: Dept API'den gelen ham veri: $deptData");

      if (mounted) {
        setState(() {
         
          _managerFullName = userData?['fullName'] ?? userData?['FullName'] ?? "İsimsiz Müdür";
          _deptName = deptData?['name'] ?? deptData?['Name'] ?? "Departman Bilgisi Yok";
        });
        print("DEBUG: Arayüze set edilen isim: $_managerFullName");
      }
    } catch (e) {
      print("DEBUG: Drawer veri yükleme hatası: $e");
      if (mounted) {
        setState(() {
          _managerFullName = "Hata oluştu";
          _deptName = "Veri alınamadı";
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      drawer: _buildFullSideDrawer(),
      appBar: AppBar(
        title: Text(
          _currentIndex == 0 ? "Sekreter Yönetimi" : (_currentIndex == 1 ? "Anasayfa" : "Ajanda Onayları"),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildSecretaryListTab(),   
          _buildHomeTab(),            
          _buildPendingApprovalTab(), 
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: const Color(0xFF637BFF),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.people_alt_rounded), label: "Sekreterler"),
          BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: "Anasayfa"),
          BottomNavigationBarItem(icon: Icon(Icons.pending_actions_rounded), label: "Onaylar"),
        ],
      ),
    );
  }

  // --- 1. SOL SEKME: SEKRETERLER ---
  Widget _buildSecretaryListTab() {
    return FutureBuilder<List<dynamic>>(
      future: _userService.getSecretariesByDept(widget.currentDepartmentId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        if (!snapshot.hasData || snapshot.data!.isEmpty) return const Center(child: Text("Sekreter bulunamadı."));

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            var sec = snapshot.data![index];
            return Card(
              color: Colors.white,
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: const Color.fromARGB(255, 255, 255, 255),
                  child: Text(sec['fullName'][0].toUpperCase(), style: const TextStyle(color: Color(0xFF637BFF))),
                ),
                title: Text(sec['fullName'], style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text("Sekreter"),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(icon: const Icon(Icons.post_add, color: Colors.black87), onPressed: () => _showTaskAssignmentDialog(sec)),
                    IconButton(icon: const Icon(Icons.campaign, color: Colors.redAccent), onPressed: () => _sendUrgentCall(sec['id'], sec['fullName'])),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // --- 2. ORTA SEKME: MODERN TAKVİMLİ ANASAYFA ---
  Widget _buildHomeTab() {
    return Column(
      children: [
        _buildHorizontalCalendar(), 
        Expanded(
          child: FutureBuilder<List<dynamic>>(
            future: _approvedFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
             
              final dailyItems = snapshot.data?.where((item) {
                DateTime date = DateTime.parse(item['eventDate'] ?? item['EventDate']);
                return date.year == _selectedDate.year && date.month == _selectedDate.month && date.day == _selectedDate.day;
              }).toList() ?? [];

              if (dailyItems.isEmpty) {
                
                 bool isTodaySelected = _selectedDate.day == _today.day && _selectedDate.month == _today.month && _selectedDate.year == _today.year;
                 return Center(child: Text(isTodaySelected ? "Bugün için henüz bir program yok." : "Seçili tarihte program bulunmuyor."));
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: dailyItems.length,
                itemBuilder: (context, index) => _buildApprovedProgramCard(dailyItems[index]),
              );
            },
          ),
        ),
      ],
    );
  }

  // --- GÜNCELLENEN YATAY TAKVİM ŞERİDİ ---
  Widget _buildHorizontalCalendar() {
    return Container(
      height: 100,
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 14, 
        itemBuilder: (context, index) {
         
          DateTime date = DateTime.now().add(Duration(days: index - 2));
          
         
          bool isSelected = date.day == _selectedDate.day && date.month == _selectedDate.month && date.year == _selectedDate.year;
          
       
          bool isToday = date.day == _today.day && date.month == _today.month && date.year == _today.year;

          return GestureDetector(
            onTap: () => setState(() => _selectedDate = date),
            child: Container(
              width: 60,
              margin: const EdgeInsets.symmetric(horizontal: 5),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF637BFF) : Colors.transparent,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: isSelected ? const Color(0xFF637BFF) : Colors.grey.withOpacity(0.2)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
          
                  Text(DateFormat('EEE', 'tr_TR').format(date).toUpperCase(), 
                    style: TextStyle(color: isSelected ? Colors.white : Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 5),
                
                  Text("${date.day}", 
                    style: TextStyle(color: isSelected ? Colors.white : Colors.black, fontSize: 18, fontWeight: FontWeight.bold)),
                  
                
                  if (isToday)
                    Container(
                      margin: const EdgeInsets.only(top: 5),
                      width: 6, height: 6,
                      decoration: BoxDecoration(
                      
                        color: isSelected ? Colors.white : const Color(0xFF637BFF),
                        shape: BoxShape.circle
                      ),
                    )
                  else
                 
                    const SizedBox(height: 11), 
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildApprovedProgramCard(dynamic item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(item['eventTime'] ?? "Belirtilmedi", style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w600)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                child: const Text("ONAYLANDI", style: TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(item['eventName'] ?? "Etkinlik", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(item['description'] ?? "Açıklama yok", style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  // --- 3. SAĞ SEKME: ONAY BEKLEYENLER ---
  Widget _buildPendingApprovalTab() {
    return FutureBuilder<List<dynamic>>(
      future: _pendingFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        
        final allItems = snapshot.data ?? [];

    
        DateTime today = DateTime(_today.year, _today.month, _today.day);

        final filteredItems = allItems.where((item) {
          
          DateTime itemDate = DateTime.parse(item['eventDate'] ?? item['EventDate']);
          DateTime normalizedItemDate = DateTime(itemDate.year, itemDate.month, itemDate.day);

        
          String status = (item['status'] ?? item['Status'] ?? "").toString();

       
          
          bool isNotPast = !normalizedItemDate.isBefore(today);
          bool isNotRevision = status != "Revision";
          bool isPending = status == "Pending"; 

          return isNotPast && isNotRevision && isPending;
        }).toList();

        if (filteredItems.isEmpty) {
          return const Center(child: Text("Onaylanabilecek güncel bir program bulunamadı."));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: filteredItems.length,
          itemBuilder: (context, index) => _buildApprovalActionCard(filteredItems[index]),
        );
      },
    );
  }

  Widget _buildApprovalActionCard(dynamic item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          const Icon(Icons.event_note_rounded, color: Color(0xFF637BFF)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item['eventName'] ?? "Etkinlik", style: const TextStyle(fontWeight: FontWeight.bold)),
                Text("Zaman: ${item['eventDate'].toString().split('T')[0]} | ${item['eventTime']}"),
              ],
            ),
          ),
          IconButton(icon: const Icon(Icons.cancel, color: Colors.red, size: 30), onPressed: () => _showFeedbackDialog(item['id'])),
          IconButton(icon: const Icon(Icons.check_circle, color: Colors.green, size: 30), onPressed: () => _handleStatusUpdate(item['id'], true)),
        ],
      ),
    );
  }

  // --- MANTIK VE DİYALOGLAR (ACİLİYET DROPDOWN DAHİL) ---

 void _showTaskAssignmentDialog(dynamic secretary) {
  final titleCtrl = TextEditingController();
  final descCtrl = TextEditingController();
  String urgency = "Normal";
  final int targetSecId = secretary['id'] ?? secretary['Id'] ?? 0;

  showDialog(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setDialogState) => AlertDialog(
        title: Text("${secretary['fullName']} için Görev"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: titleCtrl, decoration: const InputDecoration(hintText: "Görev Başlığı")),
            TextField(controller: descCtrl, decoration: const InputDecoration(hintText: "Açıklama")),
            const SizedBox(height: 15),
            DropdownButtonFormField<String>(
              value: urgency,
              decoration: const InputDecoration(labelText: "Aciliyet Durumu", border: OutlineInputBorder()),
              items: ["Düşük", "Normal", "Acil"].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
              onChanged: (val) => setDialogState(() => urgency = val!),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("İptal")),
          ElevatedButton(
            onPressed: () async {
              debugPrint("DEBUG: Görev gönderiliyor... Başlık: ${titleCtrl.text}");
              
              bool ok = await _taskService.createTask({
                "assignedByUserId": widget.currentUserId,
                "assignedToUserId": targetSecId,
                "title": titleCtrl.text,
                "description": descCtrl.text,
                "urgencyLevel": urgency,
                "isUrgent": urgency == "Acil", 
              });

              if (ok && mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Görev başarıyla iletildi!"), backgroundColor: Colors.green)
                );
              } else {
                debugPrint("DEBUG: Görev atama başarısız.");
              }
            },
            child: const Text("Gönder"),
          )
        ],
      ),
    ),
  );
}

  void _handleStatusUpdate(int id, bool approve, {String? feedback}) async {
    bool ok = await _scheduleService.updateScheduleStatus(id, approve, feedback: feedback);
    if (ok) _refreshAllData();
  }

  void _showFeedbackDialog(int id) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Revizyon Notu"),
        content: TextField(controller: ctrl, decoration: const InputDecoration(hintText: "Sekretere notunuz..."), maxLines: 3),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("İptal")),
          ElevatedButton(onPressed: () { _handleStatusUpdate(id, false, feedback: ctrl.text); Navigator.pop(context); }, child: const Text("Gönder")),
        ],
      ),
    );
  }
void _sendUrgentCall(int secId, String secName) async {
  debugPrint("DEBUG: Hızlı Çağrı Gönderiliyor. Sekreter Id: $secId");

  bool ok = await _taskService.createTask({
    "assignedByUserId": widget.currentUserId, 
    "assignedToUserId": secId,
    "title": "HIZLI ÇAĞRI",
    "description": "Müdür odasına bekleniyorsunuz.",
    "urgencyLevel": "Acil",
    "isUrgent": true,
  });

  if (ok && mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("$secName odaya çağrıldı!"), 
        backgroundColor: Colors.orange,
        behavior: SnackBarBehavior.floating,
      )
    );
  } else {
    debugPrint("DEBUG: Hızlı Çağrı Başarısız Oldu.");
  }
}

  Widget _buildFullSideDrawer() {
    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(color: Color(0xFF637BFF)),
         
            accountName: Text(
              _managerFullName, 
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)
            ),
           
            accountEmail: Text("Departman: $_deptName"),
            currentAccountPicture: const CircleAvatar(
              backgroundColor: Colors.white, 
              child: Icon(Icons.person, color: Color(0xFF637BFF), size: 40)
            ),
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.black), 
            title: const Text("Çıkış Yap"), 
            onTap: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear(); 
              await _authService.logout(); 
              if (mounted) {
                Navigator.pushAndRemoveUntil(
                  context, 
                  MaterialPageRoute(builder: (c) => const LoginScreen()), 
                  (r) => false
                );
              }
            }
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.red), 
            title: const Text("Hesabı Sil", style: TextStyle(color: Colors.red)), 
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text("Hesabı Sil"),
                  content: const Text("Hesabınızı silmek istediğinize emin misiniz? Bu işlem geri alınamaz."),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context), child: const Text("İptal")),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      onPressed: () async {
                        bool deleted = await _userService.deleteUser(widget.currentUserId);
                        if (deleted && mounted) {
                          Navigator.pop(context); 
                          final prefs = await SharedPreferences.getInstance();
                          await prefs.clear(); 
                          await _authService.logout(); 
                          if (mounted) {
                            Navigator.pushAndRemoveUntil(
                              context, 
                              MaterialPageRoute(builder: (c) => const LoginScreen()), 
                              (r) => false
                            );
                          }
                        }
                      },
                      child: const Text("Hesabı Sil"),
                    ),
                  ],
                ),
              );
            }
          ),
        ],
      ),
    );
  }
}