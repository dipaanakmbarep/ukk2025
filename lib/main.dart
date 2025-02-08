import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login.dart';
import 'home.dart';
import 'screens/tambahuser.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://bdeygksvpbxpifpwpzpl.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJkZXlna3N2cGJ4cGlmcHdwenBsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzgyODA3MTQsImV4cCI6MjA1Mzg1NjcxNH0.vc5Ka6i_KiJT2pQd2I_5sYI2K8wO6ejSvAGrTVICxqc',
  );

  // Cek koneksi Supabase sebelum aplikasi berjalan
  try {
    final response = await Supabase.instance.client
        .from('users')
        .select('*')
        .limit(1);
    print("Cek koneksi Supabase: $response");
  } catch (e) {
    print("Error koneksi Supabase: $e");
  }

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Login App',
      theme: ThemeData(
        primarySwatch: Colors.brown,
        scaffoldBackgroundColor: Colors.lightBlue[50],
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black54, // Warna hitam transparan
          iconTheme: IconThemeData(color: Colors.white),
          titleTextStyle: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
          bodyMedium: TextStyle(
            fontFamily: 'Roboto',
            fontSize: 16,
            fontStyle: FontStyle.italic,
            color: Colors.black,
          ),
          labelLarge: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.brown[400],
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(color: Colors.brown, width: 2),
            ),
            shadowColor: Colors.brown[200],
          ),
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: Colors.black54, // Warna hitam transparan
          selectedItemColor: Colors.brown[800],
          unselectedItemColor: Colors.grey[600],
          selectedIconTheme: IconThemeData(size: 30),
          unselectedIconTheme: IconThemeData(size: 24),
        ),
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/home': (context) => HomePage(username: '', email: ''), // Tidak perlu const di sini
        '/tambahuser': (context) => const TambahUserPage(),
      },
    );
  }
}
