import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';

class AddUserScreen extends StatefulWidget {
  @override
  _AddUserScreenState createState() => _AddUserScreenState();
}

class _AddUserScreenState extends State<AddUserScreen> {
  final ApiService apiService = ApiService();
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  String _selectedRole = 'customer'; // Default role

  void _submitUser() async {
    if (_formKey.currentState!.validate()) {
      User newUser = User(
        id: 0, //
        name: _nameController.text,
        email: _emailController.text,
        role: _selectedRole,
      );

      bool success = await apiService.createUser(newUser);

      if (success) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('User berhasil ditambahkan!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menambah user'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tambah Pengguna Baru'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Input Nama
              _buildLabel("Nama Lengkap"),
              TextFormField(
                controller: _nameController,
                decoration: _inputDecoration("Contoh: Diana Prince"),
                validator:
                    (val) => val!.isEmpty ? "Nama tidak boleh kosong" : null,
              ),
              SizedBox(height: 20),

              // Input Email
              _buildLabel("Alamat Email"),
              TextFormField(
                controller: _emailController,
                decoration: _inputDecoration("Contoh: diana@example.com"),
                validator:
                    (val) => val!.isEmpty ? "Email tidak boleh kosong" : null,
              ),
              SizedBox(height: 20),

              // Dropdown Role
              _buildLabel("Role Pengguna"),
              DropdownButtonFormField<String>(
                value: _selectedRole,
                decoration: _inputDecoration("Pilih Role"),
                items:
                    ['customer', 'seller', 'admin'].map((role) {
                      return DropdownMenuItem(
                        value: role,
                        child: Text(
                          role.toUpperCase(),
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      );
                    }).toList(),
                onChanged: (val) => setState(() => _selectedRole = val!),
              ),
              SizedBox(height: 40),

              // Tombol Simpan
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _submitUser,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    "Simpan Data",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper Widget untuk Label
  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
      ),
    );
  }

  // Helper Style Input
  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }
}
