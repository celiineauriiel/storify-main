import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:stockit/launchpage.dart';
import 'package:stockit/loginpage.dart'; // Import LoginPage

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Launchpage(),
      routes: {
        '/login': (context) => LoginPage(), // Menambahkan rute login
        // Tambahkan rute lain sesuai kebutuhan
      },
    );
  }
}
