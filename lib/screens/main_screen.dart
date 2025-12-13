import 'package:flutter/material.dart';
import 'product_screen.dart';
import 'user_screen.dart';
import 'review_screen.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  // Daftar halaman yang akan ditampilkan
  static List<Widget> _widgetOptions = <Widget>[
    ProductScreen(), // Index 0: Home/Produk
    UserScreen(), // Index 1: User (Pindah ke sini)
    ReviewScreen(), // Index 2: Ulasan
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: _widgetOptions.elementAt(_selectedIndex)),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          // Item 1: Produk
          BottomNavigationBarItem(icon: Icon(Icons.store), label: 'Produk'),

          // Item 2: User (Menggantikan Keranjang)
          BottomNavigationBarItem(
            icon: Icon(Icons.person_pin_rounded), // Icon User
            label: 'Akun', // Label User
          ),

          // Item 3: Ulasan
          BottomNavigationBarItem(
            icon: Icon(Icons.rate_review),
            label: 'Ulasan',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.teal,
        onTap: _onItemTapped,
      ),
    );
  }
}
