import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserFormScreen extends StatefulWidget {
  final User? user; // Jika null = Tambah, Jika ada = Edit
  const UserFormScreen({super.key, this.user});

  @override
  State<UserFormScreen> createState() => _UserFormScreenState();
}

class _UserFormScreenState extends State<UserFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _emailCtrl;
  late TextEditingController _passCtrl;
  String _role = 'customer';
  
  final ApiService _apiService = ApiService();
  bool _isLoading = false;
  bool _isCustomerLogin = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.user?.name ?? '');
    _emailCtrl = TextEditingController(text: widget.user?.email ?? '');
    _passCtrl = TextEditingController();
    _role = widget.user?.role ?? 'customer';

    _checkLoginRole();
  }

  void _checkLoginRole() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isCustomerLogin = (prefs.getString('role') == 'customer');
    });
  }

  void _saveUser() async {
    if (_formKey.currentState!.validate()) {
      // Validasi Password untuk User Baru
      if (widget.user == null && _passCtrl.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Password wajib diisi untuk user baru"), backgroundColor: Colors.red)
        );
        return;
      }

      setState(() => _isLoading = true);
      
      Map<String, dynamic> result;

      if (widget.user == null) {
        // --- TAMBAH USER BARU ---
        final newUser = User(
          id: 0, 
          name: _nameCtrl.text, 
          email: _emailCtrl.text, 
          role: _role
        );
        // Note: createUserWithPassword perlu disesuaikan return type-nya juga jika ingin pesan error detail,
        // tapi untuk sekarang kita fokus ke Edit dulu.
        bool success = await _apiService.createUserWithPassword(newUser, _passCtrl.text);
        result = success 
            ? {'success': true, 'message': 'User berhasil ditambahkan!'}
            : {'success': false, 'message': 'Gagal menambah user.'};
            
      } else {
        // --- EDIT USER (Bagian yang Error sebelumnya) ---
        result = await _apiService.updateUser(
          widget.user!.id, 
          _nameCtrl.text, 
          _emailCtrl.text, 
          _passCtrl.text, // Password bisa kosong
          _role // Kirim role (biasanya backend user butuh ini)
        );

        // Jika sukses dan yang login adalah customer, update nama di HP
        if (result['success'] == true) {
           final prefs = await SharedPreferences.getInstance();
           int myId = prefs.getInt('userId') ?? 0;
           if (widget.user!.id == myId) {
              await prefs.setString('name', _nameCtrl.text);
              await prefs.setString('email', _emailCtrl.text);
           }
        }
      }

      setState(() => _isLoading = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: result['success'] ? Color.fromARGB(255, 235, 117, 139) : Colors.red,
            duration: const Duration(seconds: 3), // Tampil lebih lama biar terbaca
          )
        );

        if (result['success']) {
          Navigator.pop(context, true);
          // Navigator.pop(context); // Kembali ke list user hanya jika sukses
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isEdit = widget.user != null;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 247, 235, 238),
      appBar: AppBar(
        title: Text(isEdit ? "Edit User" : "Tambah User", style: TextStyle(fontWeight: FontWeight.bold),),
        backgroundColor: Color.fromARGB(255, 232, 125, 145),
        foregroundColor: const Color.fromARGB(255, 255, 255, 255),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(labelText: "Nama Lengkap", prefixIcon: Icon(Icons.person_outline)),
                validator: (v) => v!.isEmpty ? "Harus diisi" : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailCtrl,
                decoration: const InputDecoration(labelText: "Email", prefixIcon: Icon(Icons.email_outlined)),
                validator: (v) => v!.isEmpty ? "Harus diisi" : null,
              ),
              const SizedBox(height: 16),
              
              // Role (Hanya tampil info jika Edit, karena request kamu role tidak boleh diubah saat edit)
              // if (isEdit)
              //   Container(
              //     width: double.infinity,
              //     padding: const EdgeInsets.all(16),
              //     decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
              //     child: Text("Role: ${_role.toUpperCase()} (Tidak dapat diubah)", style: TextStyle(color: Colors.grey[600])),
              //   ),
              
              // // Dropdown hanya muncul jika Tambah Baru
              // if (!isEdit)
              //   Container(
              //     padding: const EdgeInsets.symmetric(horizontal: 16),
              //     decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
              //     child: DropdownButtonHideUnderline(
              //       child: DropdownButton<String>(
              //         value: _role,
              //         isExpanded: true,
              //         items: const [
              //           DropdownMenuItem(value: "customer", child: Text("Customer")),
              //           DropdownMenuItem(value: "admin", child: Text("Admin")),
              //         ],
              //         onChanged: (val) => setState(() => _role = val!),
              //       ),
              //     ),
              //   ),

              if (isEdit) 
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                  child: Text(
                    "Role: ${_role.toUpperCase()} (Tidak dapat diubah)", 
                    style: TextStyle(color: Colors.grey[600])
                  ),
                ),
              
              // 2. Tampilkan DROPDOWN hanya jika:
              //    - Tambah Baru (!isEdit) 
              //    - DAN (Opsional: Yang login Admin) - asumsikan tambah user pasti admin
              if (!isEdit)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _role,
                      isExpanded: true,
                      items: const [
                        DropdownMenuItem(value: "customer", child: Text("Customer")),
                        DropdownMenuItem(value: "admin", child: Text("Admin")),
                      ],
                      onChanged: (val) => setState(() => _role = val!),
                    ),
                  ),
                ),

              const SizedBox(height: 16),
              TextFormField(
                controller: _passCtrl,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: isEdit ? "Password Baru (Kosongkan jika tetap)" : "Password", 
                  prefixIcon: const Icon(Icons.lock_outline)
                ),
              ),
              
              const SizedBox(height: 30),
              _isLoading 
                ? const CircularProgressIndicator(color: Color(0xFFFF5C8D))
                : SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _saveUser,
                      child: const Text("SIMPAN DATA"),
                    ),
                  )
            ],
          ),
        ),
      ),
    );
  }
}