import 'package:flutter/material.dart';
import 'auth/counselor_login_page.dart'; // pastikan path benar

void main() {
  runApp(const MentalistApp());
}

class MentalistApp extends StatelessWidget {
  const MentalistApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mentalist Counselor',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const CounselorLoginPage(), // 👈 ini halaman pertama
    );
  }
}
