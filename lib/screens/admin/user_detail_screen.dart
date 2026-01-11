import 'package:flutter/material.dart';
import '../../models/user_model.dart';

class UserDetailScreen extends StatelessWidget {
  final User user;
  const UserDetailScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    bool isAdmin = user.role == 'admin';

    return Scaffold(
      backgroundColor: const Color(0xFFFFF0F5),
      appBar: AppBar(
        title: const Text("Detail User"),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF5D4037),
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Avatar
              Hero(
                tag: 'user-${user.id}',
                child: CircleAvatar(
                  radius: 60,
                  backgroundColor: isAdmin ? const Color(0xFFFF8FA3) : Colors.white,
                  child: Icon(
                    isAdmin ? Icons.admin_panel_settings : Icons.person,
                    size: 60,
                    color: isAdmin ? Colors.white : const Color(0xFFFF5C8D),
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
                    Text(
                      user.name,
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF5D4037)),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isAdmin ? Colors.purple[50] : Colors.green[50],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        user.role.toUpperCase(),
                        style: TextStyle(
                          color: isAdmin ? Colors.purple : Colors.green,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Divider(color: Color(0xFFFFF0F5), thickness: 2),
                    const SizedBox(height: 24),
                    
                    // Email
                    ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: const Color(0xFFFFF0F5), borderRadius: BorderRadius.circular(8)),
                        child: const Icon(Icons.email_outlined, color: Color(0xFFFF5C8D)),
                      ),
                      title: const Text("Email", style: TextStyle(fontSize: 12, color: Colors.grey)),
                      subtitle: Text(user.email, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    ),
                    
                    // ID
                    ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: const Color(0xFFFFF0F5), borderRadius: BorderRadius.circular(8)),
                        child: const Icon(Icons.fingerprint, color: Color(0xFFFF5C8D)),
                      ),
                      title: const Text("User ID", style: TextStyle(fontSize: 12, color: Colors.grey)),
                      subtitle: Text("#${user.id}", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
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