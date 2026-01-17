import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/department_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
 
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  final AuthService _authService = AuthService();
  final DepartmentService _deptService = DepartmentService();

 
  int? _selectedDepartmentId;
  List<dynamic> _departments = [];
  bool _isLoadingDepts = true;
  bool _isLoading = false; 

  @override
  void initState() {
    super.initState();
    _fetchDepartments();
  }

  Future<void> _fetchDepartments() async {
    try {
      var data = await _deptService.getDepartments();
      if (mounted) {
        setState(() {
          _departments = data;
          _isLoadingDepts = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingDepts = false);
      }
      print("Departmanlar yüklenirken hata oluştu: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB), 
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: const Color(0xFF1D2939),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Kayıt Ol",
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF1D2939)),
              ),
              const SizedBox(height: 8),
              const Text(
                "Sekreter hesabı oluşturmak için bilgileri girin.",
                style: TextStyle(color: Color(0xFF475467)),
              ),
              const SizedBox(height: 32),

              _buildInputLabelField(hint: "Ad Soyad", controller: _nameController),
              const SizedBox(height: 16),
              _buildInputLabelField(hint: "E-posta", controller: _emailController),
              const SizedBox(height: 16),
              _buildInputLabelField(hint: "Telefon", controller: _phoneController, keyboardType: TextInputType.phone),
              const SizedBox(height: 16),
              _buildInputLabelField(hint: "Şifre", controller: _passwordController, isPassword: true),
              const SizedBox(height: 24),

              const Text("Bağlı Olduğunuz Departman", style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF344054))),
              const SizedBox(height: 8),
              
              _isLoadingDepts
                  ? const Center(child: CircularProgressIndicator())
                  : Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE9EDF5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<int>(
                          isExpanded: true,
                          value: _selectedDepartmentId,
                          hint: const Text("Departman Seçiniz", style: TextStyle(color: Color(0xFF98A2B3))),
                          items: _departments.map((dept) {
                            return DropdownMenuItem<int>(
                              value: dept['id'],
                              child: Text(dept['name']), 
                            );
                          }).toList(),
                          onChanged: (val) => setState(() => _selectedDepartmentId = val),
                        ),
                      ),
                    ),

              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleRegister,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF637BFF),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Kayıt Ol',
                          style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleRegister() async {
    
    if (_selectedDepartmentId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Lütfen bir departman seçin!")));
      return;
    }

    setState(() => _isLoading = true);

    bool success = await _authService.register(
      fullName: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
      departmentId: _selectedDepartmentId!, 
      role: "Sekreter",
    );

    if (mounted) setState(() => _isLoading = false);

    if (success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Kayıt başarılı! Admin onayı bekleniyor."), backgroundColor: Colors.green),
        );
        Navigator.pop(context);
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Kayıt sırasında hata oluştu. Türkçe karakterleri ve bilgileri kontrol edin."), backgroundColor: Colors.red),
        );
      }
    }
  }

  Widget _buildInputLabelField({required String hint, required TextEditingController controller, bool isPassword = false, TextInputType keyboardType = TextInputType.text}) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFE9EDF5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Color(0xFF98A2B3)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          border: InputBorder.none,
        ),
      ),
    );
  }
}