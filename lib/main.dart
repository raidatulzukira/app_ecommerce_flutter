import 'package:flutter/material.dart';
import 'screens/get_started_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pink Boutique',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Poppins', // Pastikan font ini ada atau gunakan default
        
        // --- SKEMA WARNA LOVELY ---
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFFF8FA3), // Pink Utama (Lovely Pink)
          primary: const Color.fromARGB(255, 233, 108, 131),   // Pink lebih tua untuk Tombol/Aksen
          secondary: const Color(0xFF5D4037), // Coklat tua untuk Teks (Kontras cantik dengan pink)
          surface: const Color(0xFFFFF0F5),   // Lavender Blush (Background sangat muda)
          background: const Color(0xFFFFF0F5),
        ),
        
        scaffoldBackgroundColor: const Color.fromARGB(255, 254, 234, 238), // Background aplikasi

        // Styling Input Form
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: const BorderSide(color: Colors.white),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: const BorderSide(color: Color.fromARGB(255, 233, 108, 131), width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
          labelStyle: const TextStyle(color: Colors.grey),
        ),

        // Styling Tombol Utama (Elevated)
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromARGB(255, 233, 108, 131), // Warna Tombol Pink
            foregroundColor: Colors.white, // Warna Teks Tombol
            elevation: 8,
            shadowColor: const Color(0xFFFF5C8D).withOpacity(0.4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16),
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ),
      home: const GetStartedScreen(),
    );
  }
}