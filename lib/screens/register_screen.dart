import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'login_screen.dart'; // Import halaman Login

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  String _role = 'customer';
  bool _isLoading = false;
  final ApiService _apiService = ApiService();

  void _register() async {
    if (_nameCtrl.text.isEmpty || _emailCtrl.text.isEmpty || _passCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Semua data harus diisi")));
      return;
    }

    setState(() => _isLoading = true);
    final success = await _apiService.register(_nameCtrl.text, _emailCtrl.text, _passCtrl.text, _role);
    setState(() => _isLoading = false);

    if (success) {
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Registrasi Berhasil! Silakan Login."),
            backgroundColor: Color.fromARGB(255, 233, 108, 131),
          )
        );
        // Arahkan ke login setelah sukses
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
      }
    } else {
      if(mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Gagal mendaftar.")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 253, 234, 241),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF5D4037)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.person_add_alt_1_rounded, size: 60, color: Color.fromARGB(255, 233, 108, 131)),
              const SizedBox(height: 20),
              const Text(
                "Buat Akun Baru",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF5D4037)),
              ),
              const Text(
                "Bergabunglah dengan Zukira Store",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 30),

              TextField(
                controller: _nameCtrl, 
                decoration: const InputDecoration(labelText: "Nama Lengkap", prefixIcon: Icon(Icons.badge_outlined))
              ),
              const SizedBox(height: 15),
              TextField(
                controller: _emailCtrl, 
                decoration: const InputDecoration(labelText: "Email", prefixIcon: Icon(Icons.email_outlined))
              ),
              const SizedBox(height: 15),
              TextField(
                controller: _passCtrl, 
                obscureText: true, 
                decoration: const InputDecoration(labelText: "Password", prefixIcon: Icon(Icons.lock_outline))
              ),
              const SizedBox(height: 15),
              
              // Dropdown Role Custom
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(25)),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _role,
                    isExpanded: true,
                    icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color.fromARGB(255, 233, 108, 131)),
                    items: const [
                      DropdownMenuItem(value: "customer", child: Text("Daftar sebagai Pembeli")),
                      DropdownMenuItem(value: "admin", child: Text("Daftar sebagai Admin")),
                    ],
                    onChanged: (val) => setState(() => _role = val!),
                  ),
                ),
              ),
              const SizedBox(height: 30),

              _isLoading
                  ? const Center(child: CircularProgressIndicator(color: Color.fromARGB(255, 233, 108, 131)))
                  : ElevatedButton(
                      onPressed: _register,
                      child: const Text("DAFTAR SEKARANG"),
                    ),

              const SizedBox(height: 20),

              // --- TEXT BUTTON PINDAH KE LOGIN ---
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Sudah punya akun? ", style: TextStyle(color: Colors.grey)),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
                    },
                    child: const Text(
                      "Masuk disini",
                      style: TextStyle(
                        color: Color.fromARGB(255, 233, 108, 131),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}