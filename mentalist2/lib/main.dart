import 'package:flutter/material.dart';
import 'auth/onboarding_page.dart'; // ✅ PATH BENAR

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
      home: const OnboardingPage(), // ✅ CLASS ADA
    );
  }
}
