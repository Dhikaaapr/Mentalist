import 'package:flutter/material.dart';
import '../auth/onboarding_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _goToOnboarding();
  }

  Future<void> _goToOnboarding() async {
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const OnboardingPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 69, 137, 255),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset("assets/loadingmentalist.png", width: 250),
            const SizedBox(height: 30),
            const CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}
