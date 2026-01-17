import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';
import '../services/schedule_service.dart';
import '../services/task_service.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';
import 'login_screen.dart';

class SecretaryHomeScreen extends StatefulWidget {
  final int currentUserId;
  final int currentDepartmentId;

  const SecretaryHomeScreen({
    super.key,
    required this.currentUserId,
    required this.currentDepartmentId,
  });

  @override
  State<SecretaryHomeScreen> createState() => _SecretaryHomeScreenState();
}

class _SecretaryHomeScreenState extends State<SecretaryHomeScreen> {
  int _bottomNavIndex = 0;
  
  final ScheduleService _scheduleService = ScheduleService();
  final AuthService _authService = AuthService();
  final UserService _userService = UserService();
  final TaskService _taskService = TaskService();

  int? _assignedManagerId;
  String _managerName = "Yükleniyor...";
  String _secretaryFullName = "Yükleniyor...";

  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _descController = TextEditingController();

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('tr_TR', null);
    _loadInitialData(); // Başlangıçta verileri yükle
  }

  // Kullanıcı ve Müdür verilerini yükleme metodu
  Future<void> _loadInitialData() async {
    try {
      final userData = await _userService.getUserById(widget.currentUserId);
      final managerData = await _userService.getManagerByDepartment(widget.currentDepartmentId);

      if (mounted && userData != null) {
        setState(() {
          // Büyük-küçük harf duyarlılığını her iki case için de kontrol ediyoruz
          _secretaryFullName = userData['fullName'] ?? userData['FullName'] ?? "İsimsiz Sekreter";
          _managerName = managerData?['fullName'] ?? managerData?['FullName'] ?? "Müdür Atanmadı";
          _assignedManagerId = managerData?['id'] ?? managerData?['Id'];
        });
      }
    } catch (e) {
      debugPrint("Yükleme Hatası: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        title: Text(
          _bottomNavIndex == 0 ? "Görevlerim" : (_bottomNavIndex == 1 ? "Program Oluştur" : "Takip Paneli"),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true, elevation: 0,
        backgroundColor: Colors.white, foregroundColor: Colors.black,
      ),
      drawer: _buildDrawer(),
      body: IndexedStack(
        index: _bottomNavIndex,
        children: [
          _buildTasksTab(),         
          _buildCreateScheduleTab(), 
          _buildProgramTrackingTab(), 
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _bottomNavIndex,
        onTap: (index) => setState(() => _bottomNavIndex = index),
        selectedItemColor: const Color(0xFF637BFF),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.assignment), label: "Görevler"),
          BottomNavigationBarItem(icon: Icon(Icons.add_circle), label: "Oluştur"),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: "Takip"),
        ],
      ),
    );
  }

  // --- DRAWER TASARIMI ---
  Widget _buildDrawer() {
    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(color: Color(0xFF637BFF)),
            currentAccountPicture: const CircleAvatar(backgroundColor: Colors.white, child: Icon(Icons.person, size: 40)),
            accountName: Text(_secretaryFullName, style: const TextStyle(fontWeight: FontWeight.bold)),
            accountEmail: Text("Yönetici: $_managerName"),
          ),
          ListTile(
            leading: const Icon(Icons.logout), title: const Text("Çıkış Yap"), 
            onTap: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear(); await _authService.logout();
              if (mounted) Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (c) => const LoginScreen()), (r) => false);
            }
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.red), 
            title: const Text("Hesabı Sil", style: TextStyle(color: Colors.red)), 
            onTap: _showDeleteAccountDialog,
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Hesabı Sil"),
        content: const Text("Hesabınızı silmek istediğinize emin misiniz?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("İptal")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              if (await _userService.deleteUser(widget.currentUserId)) {
                await _authService.logout();
                if (mounted) Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (c) => const LoginScreen()), (r) => false);
              }
            },
            child: const Text("SİL", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // --- PROGRAM TAKİBİ SEKEMESİ ---
  Widget _buildProgramTrackingTab() {
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          const TabBar(
            labelColor: Color(0xFF637BFF), indicatorColor: Color(0xFF637BFF), 
            tabs: [Tab(text: "Bekleyen"), Tab(text: "Reddedilen"), Tab(text: "Onaylanan")]
          ),
          Expanded(child: TabBarView(children: [_buildGroupedList("pending"), _buildGroupedList("rejected"), _buildGroupedList("approved")])),
        ],
      ),
    );
  }

  Widget _buildGroupedList(String tabStatus) {
    Future<List<dynamic>> fetchMethod = _scheduleService.getPendingSchedules(_assignedManagerId ?? 0);
    if (tabStatus == "approved") fetchMethod = _scheduleService.getApprovedSchedules(_assignedManagerId ?? 0);

    return FutureBuilder<List<dynamic>>(
      future: fetchMethod,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        if (!snapshot.hasData || snapshot.data!.isEmpty) return const Center(child: Text("Kayıt bulunamadı."));

        // Filtreleme
        var data = snapshot.data!.where((item) {
          final s = (item['status'] ?? item['Status'] ?? "").toString().toLowerCase();
          DateTime today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
  
          // Kayıt tarihini parse edip saat bilgisini sıfırlıyoruz
          DateTime itemDate = DateTime.parse(item['eventDate'] ?? item['EventDate']);
          DateTime normalizedItemDate = DateTime(itemDate.year, itemDate.month, itemDate.day);
          if (tabStatus == "pending") return s == "pending";
          if (tabStatus == "rejected"){
            bool isRevision = s == "revision";
            // Tarih bugünden önce değilse (!isBefore) true döner
            bool isFutureOrToday = !normalizedItemDate.isBefore(today); 
            return isRevision && isFutureOrToday;
          }

          return s == "approved" || (item['isApproved'] ?? item['IsApproved'] ?? false) == true;
        }).toList();

        if (data.isEmpty) return const Center(child: Text("Filtrelenmiş kayıt yok."));

        // Gruplandırma
        Map<String, List<dynamic>> grouped = {};
        for (var item in data) {
          String dateStr = item['eventDate'] ?? item['EventDate'];
          String key = DateFormat('yyyy-MM-dd').format(DateTime.parse(dateStr));
          if (grouped[key] == null) grouped[key] = [];
          grouped[key]!.add(item);
        }
        var keys = grouped.keys.toList()..sort((a, b) => b.compareTo(a));

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: keys.length,
          itemBuilder: (context, i) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10), 
                child: Text(
                  DateFormat('d MMMM EEEE', 'tr_TR').format(DateTime.parse(keys[i])), 
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey)
                )
              ),
              ...grouped[keys[i]]!.map((item) => _buildScheduleCard(item, tabStatus)).toList(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildScheduleCard(dynamic item, String tabStatus) {
    Color color = tabStatus == "approved" ? Colors.green : (tabStatus == "rejected" ? Colors.red : Colors.orange);
    String feedback = item['feedback'] ?? item['Feedback'] ?? "";
    
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Container(
        decoration: BoxDecoration(border: Border(left: BorderSide(color: color, width: 5))),
        child: ListTile(
          title: Text(item['eventName'] ?? item['EventName'] ?? "Etkinlik"),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Saat: ${item['eventTime'] ?? item['EventTime'] ?? ''}"),
              if (tabStatus == "rejected" && feedback.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text("Müdür Notu: $feedback", style: const TextStyle(color: Colors.red, fontStyle: FontStyle.italic, fontSize: 12)),
                ),
            ],
          ),
          trailing: tabStatus == "rejected" 
            ? IconButton(icon: const Icon(Icons.edit_note, color: Colors.blue, size: 28), onPressed: () => _handleRevise(item))
            : Icon(tabStatus == "approved" ? Icons.check_circle : Icons.timer, color: color),
        ),
      ),
    );
  }

  // --- REVİZE ETME MODALI ---
  void _handleRevise(dynamic item) {
    DateTime selectedDate = DateTime.parse(item['eventDate'] ?? item['EventDate']);
    final TextEditingController rTitleCtrl = TextEditingController(text: item['eventName'] ?? item['EventName']);
    final TextEditingController rTimeCtrl = TextEditingController(text: item['eventTime'] ?? item['EventTime']);
    String feedback = item['feedback'] ?? item['Feedback'] ?? "Geri bildirim yok.";

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 20, left: 20, right: 20, top: 20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Programı Revize Et", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                
                // MÜDÜRÜN NOTUNU MODALDA GÖSTERME (İyileştirme)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.red[50], borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.red[100]!)),
                  child: Text("Müdür Notu: $feedback", style: TextStyle(color: Colors.red[900], fontSize: 13, fontWeight: FontWeight.w500)),
                ),
                
                const SizedBox(height: 20),
                _buildLabel("Etkinlik Adı"),
                _buildField(rTitleCtrl, "Etkinlik adı"),
                const SizedBox(height: 15),
                _buildLabel("Yeni Tarih"),
                InkWell(
                  onTap: () async {
                    final DateTime? pickedDate = await showDatePicker(
                      context: context, initialDate: selectedDate, firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 365)), locale: const Locale('tr', 'TR'),
                    );
                    if (pickedDate != null) setModalState(() => selectedDate = pickedDate);
                  },
                  child: AbsorbPointer(child: _buildField(TextEditingController(text: DateFormat('d MMMM yyyy', 'tr_TR').format(selectedDate)), "", enabled: false, prefixIcon: Icons.calendar_today)),
                ),
                const SizedBox(height: 15),
                _buildLabel("Yeni Saat"),
                _buildField(rTimeCtrl, "Saat", prefixIcon: Icons.access_time),
                const SizedBox(height: 25),
                SizedBox(
                  width: double.infinity, height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF637BFF), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                    onPressed: () async {
                      final int itemId = item['id'] ?? item['Id'];
                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                      final updatedData = {
                        "id": itemId,
                        "eventName": rTitleCtrl.text,
                        "eventDate": selectedDate.toIso8601String(),
                        "eventTime": rTimeCtrl.text,
                        "managerId": item['managerId'] ?? item['ManagerId'],
                        "secretaryId": widget.currentUserId,
                        "status": "Pending",
                        "isApproved": false,
                        "feedback": "" 
                      };

                      bool success = await _scheduleService.updateSchedule(itemId, updatedData);
                      if (success && mounted) {
                        Navigator.of(context).pop();
                        _loadInitialData();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Program yeniden onaya gönderildi."), 
                            backgroundColor: Colors.green)
                            );
                      }else if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Güncelleme başarısız oldu."), 
                            backgroundColor: Colors.red)
                            );
                      }
                    },
                    child: const Text("GÜNCELLE VE YENİDEN GÖNDER", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- GÖREVLER SEKEMESİ ---
  Widget _buildTasksTab() {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          const TabBar(labelColor: Color(0xFF637BFF), indicatorColor: Color(0xFF637BFF), tabs: [Tab(text: "Yeni"), Tab(text: "Tamamlanan")]),
          Expanded(child: TabBarView(children: [_buildTaskList(isCompleted: false), _buildTaskList(isCompleted: true)])),
        ],
      ),
    );
  }

  Widget _buildTaskList({required bool isCompleted}) {
    return FutureBuilder<List<dynamic>>(
      future: _taskService.getTasksBySecretary(widget.currentUserId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        var filtered = snapshot.data!.where((t) => isCompleted ? (t['status'] == "Tamamlandı") : (t['status'] != "Tamamlandı")).toList();
        
        if (filtered.isEmpty) return const Center(child: Text("Kayıt bulunamadı."));
        
        return ListView.builder(
          padding: const EdgeInsets.all(16), itemCount: filtered.length,
          itemBuilder: (context, index) => Card(
            child: ListTile(
              title: Text(filtered[index]['title'] ?? ""),
              subtitle: Text("Aciliyet: ${filtered[index]['urgencyLevel'] ?? 'Normal'}"),
              trailing: isCompleted 
                ? const Icon(Icons.check_circle, color: Colors.green)
                : Checkbox(value: isCompleted, onChanged: (v) => _completeTask(filtered[index]['id'])),
            ),
          ),
        );
      },
    );
  }

  void _completeTask(int id) async { 
    await _taskService.updateTaskStatus(id, "Tamamlandı"); 
    _loadInitialData(); // Yenile
  }

  // --- OLUŞTURMA SEKEMESİ ---
  Widget _buildCreateScheduleTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)]),
            child: TableCalendar(
              locale: 'tr_TR', firstDay: DateTime.now(), lastDay: DateTime.now().add(const Duration(days: 365)),
              focusedDay: _focusedDay, selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              onDaySelected: (s, f) => setState(() { _selectedDay = s; _focusedDay = f; }),
              headerStyle: const HeaderStyle(formatButtonVisible: false, titleCentered: true),
              calendarStyle: const CalendarStyle(selectedDecoration: BoxDecoration(color: Color(0xFF637BFF), shape: BoxShape.circle)),
            ),
          ),
          const SizedBox(height: 20),
          _buildLabel("Etkinlik Adı"), _buildField(_titleController, "Toplantı, Görüşme..."),
          const SizedBox(height: 15),
          _buildLabel("Saat"), _buildField(_timeController, "10:00 - 11:00"),
          const SizedBox(height: 15),
          _buildLabel("Açıklama"), _buildField(_descController, "Detaylar", maxLines: 3),
          const SizedBox(height: 25),
          SizedBox(
            width: double.infinity, height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF637BFF), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              onPressed: _submitSchedule, child: const Text("Onaya Gönder", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  void _submitSchedule() async {
    final data = {
      "eventName": _titleController.text, "eventDate": _selectedDay.toIso8601String(),
      "eventTime": _timeController.text, "managerId": _assignedManagerId,
      "secretaryId": widget.currentUserId, "status": "Pending", "isApproved": false,
    };
    if (await _scheduleService.createSchedule(data)) {
      _titleController.clear(); _timeController.clear(); _descController.clear();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Müdüre iletildi."), backgroundColor: Colors.green));
    }
  }

  Widget _buildLabel(String t) => Padding(padding: const EdgeInsets.only(bottom: 8), child: Text(t, style: const TextStyle(fontWeight: FontWeight.bold)));
  Widget _buildField(TextEditingController ctrl, String hint, {bool enabled = true, IconData? prefixIcon, int maxLines = 1}) {
    return TextField(
      controller: ctrl, enabled: enabled, maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint, prefixIcon: prefixIcon != null ? Icon(prefixIcon, size: 20) : null,
        filled: true, fillColor: const Color(0xFFF5F7FA), border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
      ),
    );
  }
}