import 'package:flutter/material.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // Dropdown seçimlerini tutacak değişkenler
  String? _selectedRole;
  String? _selectedCompany;

  // Örnek veriler (Gerçek uygulamada veritabanından gelebilir)
  final List<String> _roles = ['Yönetici', 'Personel', 'Tekniker'];
  final List<String> _companies = ['Teknoloji A.Ş.', 'Lojistik Ltd.', 'Sağlık Grubu'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F5F5), // Gövde ile aynı renk
        elevation: 0, // Gölgeyi kaldır
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context), // Geri dönme işlevi
        ),
        title: const Text(
          'Kayıt Ol',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10),
        child: Column(
          children: [
            const SizedBox(height: 20),

            // 1. Ad Alanı
            _buildTextField(hintText: 'Ad'),
            const SizedBox(height: 16),

            // 2. E-posta Alanı
            _buildTextField(hintText: 'E-posta'),
            const SizedBox(height: 16),

            // 3. Şifre Alanı
            _buildTextField(hintText: 'Şifre', obscureText: true),
            const SizedBox(height: 16),

            // 4. Rol Dropdown
            _buildDropdown(
              hint: 'Rol',
              value: _selectedRole,
              items: _roles,
              onChanged: (value) {
                setState(() {
                  _selectedRole = value;
                });
              },
            ),
            const SizedBox(height: 16),

            // 5. Şirket Dropdown
            _buildDropdown(
              hint: 'Şirket',
              value: _selectedCompany,
              items: _companies,
              onChanged: (value) {
                setState(() {
                  _selectedCompany = value;
                });
              },
            ),
            const SizedBox(height: 32),

            // 6. Kaydol Butonu
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  // Kayıt işlemleri buraya
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5C7CFA),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Kaydol',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // 7. Giriş Yap Linki
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Zaten bir hesabınız var mı? ',
                  style: TextStyle(color: Color(0xFF4A4A4A)),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context); // Giriş sayfasına geri dön
                  },
                  child: const Text(
                    'Giriş yap',
                    style: TextStyle(
                      color: Color(0xFF5C7CFA),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
             const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // Metin Giriş Kutusu Yardımcısı
  Widget _buildTextField({required String hintText, bool obscureText = false}) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFE8EDF2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextField(
        obscureText: obscureText,
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          hintText: hintText,
          hintStyle: const TextStyle(color: Colors.grey),
        ),
      ),
    );
  }

  // Dropdown Menü Yardımcısı
  Widget _buildDropdown({
    required String hint,
    required String? value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFE8EDF2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: Text(hint, style: const TextStyle(color: Colors.grey)),
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
          isExpanded: true, // Sağa yaslanması için
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}