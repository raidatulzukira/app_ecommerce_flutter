import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../services/api_service.dart';
import 'user_form_screen.dart';   // Pastikan file ini ada
import 'user_detail_screen.dart'; // Pastikan file ini ada

class AdminUserScreen extends StatefulWidget {
  const AdminUserScreen({super.key});

  @override
  State<AdminUserScreen> createState() => _AdminUserScreenState();
}

class _AdminUserScreenState extends State<AdminUserScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<User>> _usersFuture;

  @override
  void initState() {
    super.initState();
    _refreshUsers();
  }

  void _refreshUsers() {
    setState(() {
      _usersFuture = _apiService.fetchUsers();
    });
  }

  // Fungsi Hapus User
  void _deleteUser(int id) async {
    // 1. Tampilkan Dialog Konfirmasi
    bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Hapus User?"),
        content: const Text("Yakin ingin menghapus user ini?"),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Batal"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Hapus", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    ) ?? false; // Default false jika dialog ditutup paksa

    // 2. Jika user menekan Hapus
    if (confirm) {
      // Panggil API delete (yang sudah kita update return-nya jadi Map)
      final result = await _apiService.deleteUser(id);
      
      // Refresh tampilan list
      _refreshUsers();
      
      if (mounted) {
        // Tampilkan pesan sukses/gagal dari backend
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? "Proses selesai"),
            backgroundColor: (result['success'] ?? false) ? Color.fromARGB(255, 227, 115, 136) : Colors.red,
            behavior: SnackBarBehavior.floating,
          )
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255), // Background Pink Muda
      
      appBar: AppBar(
        title: const Text("Manage Users", style: TextStyle(fontWeight: FontWeight.bold),),
        backgroundColor: Color.fromARGB(255, 237, 125, 145),
        foregroundColor: const Color.fromARGB(255, 255, 255, 255),
        elevation: 0,
        centerTitle: true,
      ),

      // Tombol Tambah User (+)
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color.fromARGB(255, 233, 108, 131),
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () async {
          // Pindah ke Form Tambah
          await Navigator.push(context, MaterialPageRoute(builder: (_) => const UserFormScreen()));
          // Refresh setelah kembali
          _refreshUsers();
        },
      ),

      body: FutureBuilder<List<User>>(
        future: _usersFuture,
        builder: (context, snapshot) {
          // Loading State
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFFFF5C8D)));
          }
          
          // Error State
          if (snapshot.hasError) {
             return Center(child: Text("Error: ${snapshot.error}"));
          }

          // Empty State
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people_outline, size: 60, color: Colors.grey),
                  SizedBox(height: 10),
                  Text("Belum ada user.", style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }
          
          // List Data State
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final user = snapshot.data![index];
              final isAdmin = user.role == 'admin';

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: InkWell(
                  borderRadius: BorderRadius.circular(15),
                  // --- 1. KLIK KARTU KE HALAMAN DETAIL ---
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => UserDetailScreen(user: user)));
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      children: [
                        // Avatar Icon
                        Hero(
                          tag: 'user-${user.id}',
                          child: CircleAvatar(
                            backgroundColor: isAdmin ? const Color(0xFFFF8FA3) : Colors.grey[200],
                            child: Icon(
                              isAdmin ? Icons.admin_panel_settings : Icons.person, 
                              color: isAdmin ? Colors.white : Colors.grey
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        
                        // Nama & Email
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user.name, 
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                user.email, 
                                style: TextStyle(color: Colors.grey[600], fontSize: 13),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        
                        // Tombol Aksi (Edit & Delete)
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit_rounded, color: Colors.orange, size: 22),
                              onPressed: () async {
                                // Pindah ke Form Edit
                                await Navigator.push(
                                  context, 
                                  MaterialPageRoute(builder: (_) => UserFormScreen(user: user))
                                );
                                // Refresh setelah kembali dari edit
                                _refreshUsers();
                              },
                            ),
                            
                            // --- 3. TOMBOL DELETE ---
                            IconButton(
                              icon: const Icon(Icons.delete_outline_rounded, color: Colors.red, size: 22),
                              onPressed: () => _deleteUser(user.id),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}