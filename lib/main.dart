// lib/main.dart
import 'package:flutter/material.dart';
import 'screens/main_screen.dart'; // Import MainScreen

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'E-Commerce App',
      debugShowCheckedModeBanner: false, // Menghilangkan banner debug
      // --- TEMA APLIKASI ---
      theme: ThemeData(
        useMaterial3: true,

        // Skema warna utama (Teal)
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
          brightness: Brightness.light,
          primary: Colors.teal,
          // Memberikan sentuhan warna sekunder
          secondary: Colors.tealAccent,
        ),

        // Warna latar belakang global (Soft White/Grey) agar nyaman di mata
        scaffoldBackgroundColor: Colors.grey[50],

        // Styling AppBar Global (agar konsisten di semua halaman)
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.teal,
          foregroundColor: Colors.white, // Warna teks/icon putih
          centerTitle: true, // Judul di tengah (gaya modern/iOS style)
          elevation: 0, // Menghilangkan bayangan agar terlihat flat & modern
          titleTextStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
            letterSpacing: 0.5,
          ),
        ),

        // Styling Card Global
        cardTheme: CardTheme(
          color: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        ),
      ),

      // Halaman awal aplikasi
      home: MainScreen(),
    );
  }
}
