import 'package:flutter/material.dart';
import '../services/task_service.dart';
import 'login_screen.dart';

class SecretaryHomeScreen extends StatefulWidget {
  final int currentUserId; // <-- BU EKLENDİ (Giriş yapanın ID'si)

  const SecretaryHomeScreen({super.key, required this.currentUserId});

  @override
  State<SecretaryHomeScreen> createState() => _SecretaryHomeScreenState();
}

class _SecretaryHomeScreenState extends State<SecretaryHomeScreen> {
  int _currentIndex = 0;
  List<Widget> _pages = [];

  @override
  void initState() {
    super.initState();
    // Sayfaları burada oluşturuyoruz ki ID'yi gönderebilelim
    _pages = [
      SecretaryTasksTab(userId: widget.currentUserId), // <-- ID'yi buraya aktardık
      const CreateProgramTab(),
      const SecretarySettingsTab(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5), // Arka plan rengi
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F5F5),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.black), // Sol üstteki hamburger menü
          onPressed: () {},
        ),
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        selectedItemColor: const Color(0xFF5C7CFA),
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.check_box_outlined),
            activeIcon: Icon(Icons.check_box),
            label: 'Görevler',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month_outlined),
            activeIcon: Icon(Icons.calendar_month),
            label: 'Program Oluştur',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            activeIcon: Icon(Icons.settings),
            label: 'Ayarlar',
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 1. GÖREVLER SEKMESİ (TAB BAR İÇEREN ANA KISIM)
// ---------------------------------------------------------------------------
class SecretaryTasksTab extends StatefulWidget {
  final int userId;
  const SecretaryTasksTab({super.key, required this.userId});

  @override
  State<SecretaryTasksTab> createState() => _SecretaryTasksTabState();
}

class _SecretaryTasksTabState extends State<SecretaryTasksTab> {
  final TaskService _taskService = TaskService();
  List<dynamic> _tasks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchMyTasks();
  }

  Future<void> _fetchMyTasks() async {
    var data = await _taskService.getTasksBySecretaryId(widget.userId);
    setState(() {
      _tasks = data;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          const TabBar(
            labelColor: Color(0xFF5C7CFA),
            unselectedLabelColor: Colors.grey,
            indicatorColor: Color(0xFF5C7CFA),
            tabs: [
              Tab(text: "Yeni Görevler"),
              Tab(text: "Tamamlanan Görevler"),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                // 1. Sekme: Yeni Görevler (API'den gelenler)
                _buildTaskList(isCompleted: false),
                
                // 2. Sekme: Tamamlananlar
                _buildTaskList(isCompleted: true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskList({required bool isCompleted}) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Listeyi filtrele (Yeni veya Tamamlandı durumuna göre)
    // Not: Veritabanında "Yeni" ve "Tamamlandı" diye tutuyoruz.
    String targetStatus = isCompleted ? "Tamamlandı" : "Yeni";
    var filteredList = _tasks.where((t) => t['status'] == targetStatus).toList();

    if (filteredList.isEmpty) {
      return Center(child: Text(isCompleted ? "Tamamlanan görev yok" : "Yeni görev yok"));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredList.length,
      itemBuilder: (context, index) {
        var task = filteredList[index];
        return _buildTaskItem(task);
      },
    );
  }

  Widget _buildTaskItem(dynamic task) {
    // Aciliyet Rengi Belirle
    Color urgencyColor = Colors.blue;
    if (task['urgencyLevel'] == 'Yüksek' || task['urgencyLevel'] == 'Acil') {
      urgencyColor = Colors.redAccent;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))
        ],
      ),
      child: Row(
        children: [
          // İkon Kutusu
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: urgencyColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.assignment, color: urgencyColor, size: 24),
          ),
          const SizedBox(width: 16),
          
          // Yazılar
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task['title'],
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1A1F36)),
                ),
                const SizedBox(height: 4),
                Text(
                  task['description'] ?? "",
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
                const SizedBox(height: 4),
                 Text(
                  "Aciliyet: ${task['urgencyLevel']}",
                  style: TextStyle(color: urgencyColor, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),

         // Checkbox (Görevi Tamamla)
          Checkbox(
            value: task['status'] == 'Tamamlandı',
            activeColor: const Color(0xFF5C7CFA),
            onChanged: (bool? value) async {
              // Eğer zaten tamamlanmışsa tekrar işlem yapma (veya geri al özelliği eklenebilir)
              if (task['status'] == 'Tamamlandı') return;

              // 1. API İsteği Gönder
              bool success = await _taskService.completeTask(task['id']);

              if (success) {
                // 2. Başarılıysa Listeyi Yerel Olarak Güncelle
                setState(() {
                  // Bu görevi bul ve durumunu değiştir
                  var targetTask = _tasks.firstWhere((t) => t['id'] == task['id']);
                  targetTask['status'] = 'Tamamlandı';
                });

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Görev tamamlandı!")),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("İşlem başarısız oldu.")),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
// ---------------------------------------------------------------------------
// DİĞER SAYFALAR (YER TUTUCU)
// ---------------------------------------------------------------------------
class CreateProgramTab extends StatelessWidget {
  const CreateProgramTab({super.key});
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text("Program Oluştur Sayfası"));
  }
}

class SecretarySettingsTab extends StatelessWidget {
  const SecretarySettingsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.person_outline, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              "Profil ve Ayarlar",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1A1F36)),
            ),
            const SizedBox(height: 40),

            // ÇIKIŞ YAP BUTONU
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                    (route) => false,
                  );
                },
                icon: const Icon(Icons.logout),
                label: const Text("Çıkış Yap"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}