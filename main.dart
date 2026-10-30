import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
// Pastikan path model ini benar dan file LocalStorage ada
import 'models/item_model.dart'; 

Future<void> main() async {
  // Wajib ada agar binding Flutter siap sebelum proses async
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Berikan penanganan error jika LocalStorage gagal diinisialisasi
    await LocalStorage.initialize();
  } catch (e) {
    debugPrint('Gagal menginisialisasi LocalStorage: $e');
  }

  runApp(const TaskInventoryApp());
}

class TaskInventoryApp extends StatelessWidget {
  const TaskInventoryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Task & Inventory Manager',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
        ),
        useMaterial3: true,
      ),
      home: const LoginScreen(),
    );
  }
}