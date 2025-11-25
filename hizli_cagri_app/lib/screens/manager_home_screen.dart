// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import '../services/user_service.dart';
import '../services/task_service.dart';
import 'login_screen.dart';
class ManagerHomeScreen extends StatefulWidget {
  const ManagerHomeScreen({super.key});

  @override
  State<ManagerHomeScreen> createState() => _ManagerHomeScreenState();
}

class _ManagerHomeScreenState extends State<ManagerHomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const TasksTab(),    // 0: Görevler (Aşağıda kodladığımız kısım)
    const ProgramTab(),  // 1: Program (Yer tutucu)
    const SettingsTab(), // 2: Ayarlar (Yer tutucu)
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F5F5),
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false, // Geri butonunu kaldır (Login'den geldik)
      ),
      body: _pages[_currentIndex], // Seçili sayfayı göster
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        selectedItemColor: const Color(0xFF5C7CFA), // Seçili mavi
        unselectedItemColor: Colors.grey, // Seçili olmayan gri
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment_outlined),
            activeIcon: Icon(Icons.assignment),
            label: 'Görevler',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_outlined),
            activeIcon: Icon(Icons.calendar_today),
            label: 'Program',
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

// 1. GÖREVLER SEKMESİ (TASARIMDAKİ ANA EKRAN)
class TasksTab extends StatefulWidget {
  const TasksTab({super.key});

  @override
  State<TasksTab> createState() => _TasksTabState();
}

class _TasksTabState extends State<TasksTab> {
  final UserService _userService = UserService();
  final TaskService _taskService = TaskService(); // <-- YENİ SERVİS
  
  // Controller'lar (Yazıları okumak için)
  final TextEditingController _titleController = TextEditingController(); // <-- YENİ
  final TextEditingController _descController = TextEditingController();  // <-- YENİ

  // Değişkenler
  int? _selectedSecretaryId;
  String? _selectedUrgency;
  List<dynamic> _secretaries = [];
  bool _isLoading = true;
  
  // TEST İÇİN MÜDÜR ID (Swagger'da oluşturduğun Müdürün ID'si 1 ise burası 1 kalsın)
  final int currentManagerId = 1;

  final List<String> _urgencyLevels = ['Düşük', 'Orta', 'Yüksek', 'Acil'];

  // Sayfa ilk açıldığında çalışır
  @override
  void initState() {
    super.initState();
    _fetchSecretaries();
  }

  // Sekreterleri API'den Çek
  Future<void> _fetchSecretaries() async {
    var data = await _userService.getSecretaries();
    setState(() {
      _secretaries = data;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- BÖLÜM 1: YENİ GÖREV OLUŞTUR ---
          const Text(
            'Yeni Görev Oluştur',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          _buildTextField(hintText: 'Görev Başlığı', controller: _titleController),
          const SizedBox(height: 12),

          // SEKRETER SEÇİMİ (API'den Gelen Veri)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFE8EDF2),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.withOpacity(0.2)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                value: _selectedSecretaryId,
                hint: const Text('Sekreter Seç', style: TextStyle(color: Colors.grey)),
                isExpanded: true,
                items: _secretaries.map<DropdownMenuItem<int>>((sec) {
                  return DropdownMenuItem<int>(
                    value: sec['id'], // Arka planda ID tut
                    child: Text(sec['fullName']), // Ekranda İsim Göster
                  );
                }).toList(),
                onChanged: (val) {
                  setState(() {
                    _selectedSecretaryId = val;
                  });
                },
              ),
            ),
          ),

          const SizedBox(height: 12),
          _buildTextField(hintText: 'Açıklama', maxLines: 4, controller: _descController),
          const SizedBox(height: 12),

          // Aciliyet Dropdown
          _buildDropdownString(
            hint: 'Aciliyet Düzeyi',
            value: _selectedUrgency,
            items: _urgencyLevels,
            onChanged: (val) => setState(() => _selectedUrgency = val),
          ),
          
          const SizedBox(height: 20),

          // Görevi Gönder Butonu
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () async {
                // KONTROLLER
                if (_titleController.text.isEmpty || 
                    _selectedSecretaryId == null || 
                    _selectedUrgency == null) {
                   ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Lütfen başlık, sekreter ve aciliyet seçin!')),
                  );
                  return;
                }

                // API İSTEĞİ
                bool success = await _taskService.createTask(
                  title: _titleController.text,
                  description: _descController.text,
                  urgency: _selectedUrgency!,
                  assignedToUserId: _selectedSecretaryId!,
                  assignedByUserId: currentManagerId, // Test ID'si
                );

                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Görev başarıyla atandı! ✅')),
                  );
                  // Formu Temizle
                  _titleController.clear();
                  _descController.clear();
                  setState(() {
                    _selectedSecretaryId = null;
                    _selectedUrgency = null;
                  });
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Hata oluştu!')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5C7CFA),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Görevi Gönder', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),

          const SizedBox(height: 30),

          // --- BÖLÜM 2: HIZLI ÇAĞRI LİSTESİ ---
          const Text(
            'Hızlı Çağrı',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // API'den gelen listeyi ekrana basıyoruz
          ..._secretaries.map((sec) => _buildQuickCallCard(sec['fullName'], sec['id'])),
        ],
      ),
    );
  }

  // Helper Widget'lar (TextField aynı)
  Widget _buildTextField({
    required String hintText, 
    int maxLines = 1,
    required TextEditingController controller
    }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFE8EDF2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          hintText: hintText,
          hintStyle: const TextStyle(color: Colors.grey),
        ),
      ),
    );
  }

  // String Dropdown (Aciliyet için)
  Widget _buildDropdownString({
    required String hint,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFE8EDF2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: Text(hint, style: const TextStyle(color: Colors.grey)),
          isExpanded: true,
          items: items.map((String item) {
            return DropdownMenuItem<String>(value: item, child: Text(item));
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  // Hızlı Çağrı Kartı
  Widget _buildQuickCallCard(String name, int id) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            name,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1A1F36)),
          ),
          IconButton(
            onPressed: () {
              // Hızlı Çağrı API isteği buraya gelecek
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('$name (ID: $id) çağrılıyor...')),
              );
            },
            icon: const Icon(Icons.notifications_outlined),
            color: const Color(0xFF5C7CFA),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// YER TUTUCU SAYFALAR (PROGRAM ve AYARLAR)
// ---------------------------------------------------------------------------
class ProgramTab extends StatelessWidget {
  const ProgramTab({super.key});
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Program Sayfası'));
  }
}

class SettingsTab extends StatelessWidget {
  const SettingsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.settings, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              "Ayarlar",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1A1F36)),
            ),
            const SizedBox(height: 8),
            const Text(
              "Hesap ayarlarınızı buradan yönetebilirsiniz.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 40),

            // ÇIKIŞ YAP BUTONU
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () {
                  // Tüm geçmişi silip Login sayfasına atar
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                    (route) => false,
                  );
                },
                icon: const Icon(Icons.logout),
                label: const Text("Çıkış Yap"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent, // Tehlike/Çıkış rengi
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