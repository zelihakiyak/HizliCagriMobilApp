import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';
import '../services/department_service.dart';
import '../services/task_service.dart';
import 'login_screen.dart';

class AdminHomeScreen extends StatefulWidget {
   final int currentUserId;

  const AdminHomeScreen({
    super.key,
    required this.currentUserId,});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  int _currentIndex = 0;
  final AuthService _authService = AuthService();
  final UserService _userService = UserService();

  
  final List<Widget> _pages = [
    const AdminLogsTab(),        
    const AdminUsersTab(),       
    const AdminDepartmentsTab(),  
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        title: Text(
          _currentIndex == 0 ? "Çağrı Kayıtları" : 
          _currentIndex == 1 ? "Kullanıcı Yönetimi" : "Departmanlar",
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black), 
      ),
      
      drawer: Drawer(
        child: Column(
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Color(0xFF637BFF)),
              child: Center(
                child: Text(
                  "Admin Paneli",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
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
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: const Color(0xFF637BFF),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Kayıtlar'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Kullanıcılar'),
          BottomNavigationBarItem(icon: Icon(Icons.domain), label: 'Departmanlar'),
        ],
      ),
    );
  }
}

// --- 1. ÇAĞRI KAYITLARI SEKEMESİ ---
class AdminLogsTab extends StatelessWidget {
  const AdminLogsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: TaskService().getAllTasksAdmin(), 
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        if (!snapshot.hasData || snapshot.data!.isEmpty) return const Center(child: Text("Henüz kayıt yok."));

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            var log = snapshot.data![index];
            return _buildLogCard(log);
          },
        );
      },
    );
  }

  Widget _buildLogCard(dynamic log) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        title: Text("Gönderen: ${log['senderName']}, Alıcı: ${log['receiverName']}", style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text("Görev: ${log['title']}\n${log['description']}"),
        trailing: Text(log['urgencyLevel'] ?? "Normal", style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold)),
      ),
    );
  }
}

// --- 2. KULLANICI YÖNETİMİ SEKEMESİ ---
class AdminUsersTab extends StatefulWidget {
  const AdminUsersTab({super.key});
  @override
  State<AdminUsersTab> createState() => _AdminUsersTabState();
}

class _AdminUsersTabState extends State<AdminUsersTab> {
  final UserService _userService = UserService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddManagerDialog(context), 
        backgroundColor: const Color(0xFF637BFF),
        child: const Icon(Icons.person_add),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _userService.getPendingUsers(), 
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (!snapshot.hasData || snapshot.data!.isEmpty) return const Center(child: Text("Onay bekleyen kullanıcı yok."));

          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              var user = snapshot.data![index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(user['fullName']),
                  subtitle: Text("Rol: ${user['role']}"),
                  trailing: TextButton(
                    onPressed: () async {
                      if (await _userService.approveUser(user['id'])) setState(() {});
                    },
                    child: const Text("ONAYLA", style: TextStyle(color: Colors.green)),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showAddManagerDialog(BuildContext context) async {
    final DepartmentService deptService = DepartmentService();
    final AuthService authService = AuthService();
    
    List<dynamic> depts = await deptService.getDepartments();
    
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final passCtrl = TextEditingController();
    int? selectedDeptId;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text("Yeni Müdür Ekle"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: nameCtrl, decoration: const InputDecoration(hintText: "Ad Soyad")),
                TextField(controller: emailCtrl, decoration: const InputDecoration(hintText: "E-posta")),
                TextField(controller: passCtrl, decoration: const InputDecoration(hintText: "Şifre"), obscureText: true),
                const SizedBox(height: 15),
                DropdownButtonFormField<int>(
                  value: selectedDeptId,
                  hint: const Text("Departman Seçin"),
                  items: depts.map((d) => DropdownMenuItem<int>(value: d['id'], child: Text(d['name']))).toList(),
                  onChanged: (val) => setDialogState(() => selectedDeptId = val),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("İptal")),
            ElevatedButton(
              onPressed: () async {
                if (selectedDeptId != null) {
                 
                  bool ok = await authService.register(
                    fullName: nameCtrl.text.trim(),
                    email: emailCtrl.text.trim(),
                    password: passCtrl.text.trim(),
                    departmentId: selectedDeptId!,
                    role: "Mudur",
                  );
                  if (ok && context.mounted) {
                    Navigator.pop(context);
                    setState(() {}); 
                  }
                }
              },
              child: const Text("Kaydet"),
            )
          ],
        ),
      ),
    );
  }
}

// --- 3. DEPARTMAN YÖNETİMİ SEKEMESİ ---
class AdminDepartmentsTab extends StatefulWidget {
  const AdminDepartmentsTab({super.key});
  @override
  State<AdminDepartmentsTab> createState() => _AdminDepartmentsTabState();
}

class _AdminDepartmentsTabState extends State<AdminDepartmentsTab> {
  final DepartmentService _deptService = DepartmentService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent, 
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDeptDialog(context), 
        backgroundColor: Colors.orange,
        child: const Icon(Icons.add_business, color: Colors.white),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _deptService.getDepartments(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Henüz bir departman tanımlanmamış."));
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 12),
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              var dept = snapshot.data![index];
              return _buildDepartmentCard(dept);
            },
          );
        },
      ),
    );
  }

  // TEMİZ VE MODERN KART TASARIMI
  Widget _buildDepartmentCard(dynamic dept) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03), 
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.orange.withOpacity(0.1), 
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.domain, color: Colors.orange, size: 24), 
        ),
        title: Text(
          dept['name'] ?? "Bilinmeyen Departman",
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1D2939)),
        ),
        subtitle: Text(
          "Departman ID: ${dept['id']}",
          style: const TextStyle(color: Color(0xFF667085), fontSize: 13),
        ),
      ),
    );
  }

  // DEPARTMAN EKLEME DİYALOĞU
  void _showAddDeptDialog(BuildContext context) {
    final TextEditingController nameCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Yeni Departman Ekle", style: TextStyle(fontWeight: FontWeight.bold)),
        content: TextField(
          controller: nameCtrl,
          decoration: InputDecoration(
            hintText: "Departman Adı (Örn: Muhasebe)",
            filled: true,
            fillColor: const Color(0xFFF5F7FA),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("İptal")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () async {
              String deptName = nameCtrl.text.trim();
              if (deptName.isNotEmpty) {
                
                bool ok = await _deptService.addDepartment(deptName); 
                
                if (ok && context.mounted) {
                  Navigator.pop(context);
                  setState(() {}); 
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Departman başarıyla eklendi."),
                      backgroundColor: Colors.green,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              }
            },
            child: const Text("Ekle", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}