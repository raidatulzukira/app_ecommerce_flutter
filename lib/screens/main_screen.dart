import 'package:flutter/material.dart';
import 'admin/admin_product_screen.dart'; // Pastikan file ini ada (List Produk Customer)
import 'user_screen.dart';    // Pastikan file ini ada
import 'review_screen.dart';  // Pastikan file ini ada
import 'login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'admin/admin_product_screen.dart';
import 'admin/admin_user_screen.dart';
import 'cart_screen.dart';
import '../models/user_model.dart';       // <--- TAMBAHKAN INI
import 'admin/user_form_screen.dart';
import 'review_screen.dart';
import 'review_detail_screen.dart';
import 'add_review_screen.dart';
import 'admin/user_detail_screen.dart';

class MainScreen extends StatefulWidget {
  final String role;
  const MainScreen({super.key, required this.role});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  int _userId = 0;
  String _userName = '';
  String _userEmail = '';
  String _role = 'customer';

  // --- MENU KHUSUS CUSTOMER ---
  // late final List<Widget> _customerPages;

  // --- MENU KHUSUS ADMIN ---
  // Untuk Admin, kita buat Dashboard sederhana berupa Grid Menu
  Widget _buildAdminDashboard() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: GridView.count(
        crossAxisCount: 2,
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
        children: [
          _buildAdminCard("Manage Products", Icons.inventory_2, const Color(0xFFFF5C8D), () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminProductScreen()));
          }),
          _buildAdminCard("Manage Users", Icons.people, const Color(0xFFBA68C8), () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminUserScreen()));
          }),
          _buildAdminCard("Moderasi Reviews", Icons.rate_review, const Color(0xFFFFB74D), () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const ReviewScreen()));
          }),
          _buildAdminCard("My Cart (Admin)", Icons.shopping_cart, const Color(0xFF4DB6AC), () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const CartScreen()));
          }),
        ],
      ),
    );
  }

  Widget _buildAdminCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.pink.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(radius: 30, backgroundColor: color.withOpacity(0.2), child: Icon(icon, color: color, size: 30)),
            const SizedBox(height: 15),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _loadSession();
    // Inisialisasi halaman customer
    // _customerPages = [
    //   ProductScreen(),
    //   UserScreen(), // Atau CartScreen jika sudah ada
    //   ReviewScreen(),
    // ];
  }

  void _loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userId = prefs.getInt('userId') ?? 0;
      _role = prefs.getString('role') ?? 'customer';
      _userName = prefs.getString('name') ?? 'User';
      _userEmail = prefs.getString('email') ?? 'Email';
    });
  }

  void _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (mounted) {
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const LoginScreen()), (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Cek Role (bisa dari widget.role atau _role dari session)
    bool isAdmin = widget.role == 'admin';

    // --- LIST HALAMAN CUSTOMER ---
    final List<Widget> customerPages = [
      const AdminProductScreen(), 
      const CartScreen(),
      const ReviewScreen(), 
      UserDetailScreen(
        user: User(
          id: _userId, 
          name: _userName, 
          email: _userEmail, 
          role: _role
        )
      ),
      // UserFormScreen(
      //   user: User(id: _userId, name: _userName, email: _userEmail, role: _role)
      // ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(isAdmin ? "Admin Dashboard" : "Zukira Store"),
        backgroundColor: Colors.white,
        elevation: 0,
        titleTextStyle: const TextStyle(color: Color.fromARGB(255, 239, 88, 116), fontSize: 22, fontWeight: FontWeight.bold),
        actions: [
          IconButton(onPressed: _logout, icon: const Icon(Icons.logout, color: Color.fromARGB(255, 233, 108, 131))),
        ],
      ),
      
      // Body: Jika Admin pakai Grid, Jika Customer pakai List customerPages
      body: isAdmin 
          ? _buildAdminDashboard() 
          : customerPages[_selectedIndex],

      bottomNavigationBar: isAdmin ? null : Container(
        decoration: BoxDecoration(
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.white,
          selectedItemColor: const Color.fromARGB(255, 233, 108, 131),
          unselectedItemColor: Colors.grey[400],
          currentIndex: _selectedIndex,
          onTap: (index) => setState(() => _selectedIndex = index),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.storefront_rounded), label: 'Belanja'),
            BottomNavigationBarItem(icon: Icon(Icons.shopping_bag_outlined), label: 'Keranjang'),
            BottomNavigationBarItem(icon: Icon(Icons.star_rounded), label: 'Ulasan'),
            BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profil Saya'),

            // BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Shop'),
            // BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: 'Profile'), // Atau Cart
            // BottomNavigationBarItem(icon: Icon(Icons.star_rounded), label: 'Reviews'),
          ],
        ),
      ),
    );
  }
}