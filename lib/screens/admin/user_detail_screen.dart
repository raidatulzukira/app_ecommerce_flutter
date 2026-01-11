import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/user_model.dart';
import '../../services/api_service.dart';
import 'user_form_screen.dart';

class UserDetailScreen extends StatefulWidget {
  final User user;
  const UserDetailScreen({super.key, required this.user});

  @override
  State<UserDetailScreen> createState() => _UserDetailScreenState();
}

class _UserDetailScreenState extends State<UserDetailScreen> {
  final ApiService _apiService = ApiService();
  
  // 1. BUAT VARIABEL STATE UNTUK DATA USER YANG TAMPIL
  late User _displayUser; 
  
  int _currentUserId = 0;
  String _currentRole = '';

  @override
  void initState() {
    super.initState();
    // 2. INISIALISASI DENGAN DATA AWAL
    _displayUser = widget.user; 
    _loadSession();
  }

  void _loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentUserId = prefs.getInt('userId') ?? 0;
      _currentRole = prefs.getString('role') ?? 'customer';
    });
  }

  // 3. FUNGSI UNTUK REFRESH DATA DARI SERVER
  Future<void> _refreshData() async {
    try {
      // Ambil data terbaru user ini dari backend
      final updatedUser = await _apiService.fetchUserDetail(_displayUser.id);
      setState(() {
        _displayUser = updatedUser; // Update tampilan dengan data baru
      });
    } catch (e) {
      print("Gagal refresh data: $e");
    }
  }

  void _deleteUser() async {
    // ... (Fungsi delete biarkan sama seperti sebelumnya) ...
    // Gunakan widget.user.id atau _displayUser.id sama saja
    bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Hapus User?"),
        content: Text("Yakin ingin menghapus user ${_displayUser.name}?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Batal")),
          TextButton(
            onPressed: () => Navigator.pop(context, true), 
            child: const Text("Hapus", style: TextStyle(color: Colors.red))
          ),
        ],
      ),
    ) ?? false;

    if (confirm) {
      final result = await _apiService.deleteUser(_displayUser.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? "Proses selesai"),
            backgroundColor: (result['success'] ?? false) ? Colors.green : Colors.red,
          )
        );
        if (result['success'] == true) {
          Navigator.pop(context);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Gunakan _displayUser (Data Terbaru), JANGAN widget.user
    bool isProfileAdmin = _displayUser.role == 'admin';
    bool isMe = (_currentUserId == _displayUser.id);
    bool amIAdmin = (_currentRole == 'admin');

    return Scaffold(
      backgroundColor: const Color(0xFFFFF0F5),
      appBar: AppBar(
        title: const Text("Detail Profil", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color.fromARGB(255, 237, 125, 145),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          // Edit
          if (isMe) 
            IconButton(
              icon: const Icon(Icons.edit_rounded),
              tooltip: "Edit Profil Saya",
              onPressed: () async {
                // 4. NAVIGASI DAN TUNGGU HASIL (await)
                final bool? shouldRefresh = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => UserFormScreen(user: _displayUser)),
                );

                // 5. JIKA KEMBALI MEMBAWA 'TRUE', REFRESH DATA
                if (shouldRefresh == true) {
                  _refreshData(); // Tarik data baru dari database
                  _loadSession(); // Update session juga kalau perlu
                }
              },
            ),

          // Hapus
          if (amIAdmin && !isMe)
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded, color: Colors.white),
              onPressed: _deleteUser,
            ),
            
          const SizedBox(width: 8),
        ],
      ),
      
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Avatar
              Hero(
                tag: 'user-${_displayUser.id}',
                child: CircleAvatar(
                  radius: 60,
                  backgroundColor: isProfileAdmin ? const Color(0xFFFF8FA3) : Colors.white,
                  child: Icon(
                    isProfileAdmin ? Icons.admin_panel_settings : Icons.person,
                    size: 60,
                    color: isProfileAdmin ? Colors.white : const Color(0xFFFF5C8D),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              
              // Kartu Info
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(color: const Color(0xFFFF8FA3).withOpacity(0.1), blurRadius: 15, offset: const Offset(0, 5))
                  ],
                ),
                child: Column(
                  children: [
                    // NAMA (Gunakan _displayUser)
                    Text(
                      _displayUser.name,
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF5D4037)),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    
                    // ROLE
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isProfileAdmin ? Colors.purple[50] : Colors.green[50],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        _displayUser.role.toUpperCase(),
                        style: TextStyle(
                          color: isProfileAdmin ? Colors.purple : Colors.green,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Divider(color: Color(0xFFFFF0F5), thickness: 2),
                    const SizedBox(height: 24),
                    
                    // EMAIL (Gunakan _displayUser)
                    ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: const Color(0xFFFFF0F5), borderRadius: BorderRadius.circular(8)),
                        child: const Icon(Icons.email_outlined, color: Color(0xFFFF5C8D)),
                      ),
                      title: const Text("Email", style: TextStyle(fontSize: 12, color: Colors.grey)),
                      subtitle: Text(_displayUser.email, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    ),
                    
                    // ID
                    ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: const Color(0xFFFFF0F5), borderRadius: BorderRadius.circular(8)),
                        child: const Icon(Icons.fingerprint, color: Color(0xFFFF5C8D)),
                      ),
                      title: const Text("User ID", style: TextStyle(fontSize: 12, color: Colors.grey)),
                      subtitle: Text("#${_displayUser.id}", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}