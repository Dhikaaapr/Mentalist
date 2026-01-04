import 'dart:async';
import 'package:flutter/material.dart';
import '../auth/counselor_login_page.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _controller = PageController();
  int index = 0;

  @override
  void initState() {
    super.initState();

    // SPLASH 1 → AUTO PINDAH 3 DETIK
    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        _controller.animateToPage(
          1,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _controller,
        physics: const NeverScrollableScrollPhysics(), // ⬅️ MATI TOTAL
        onPageChanged: (i) => setState(() => index = i),
        children: [_splash1(), _splash2(), _splash3(), _splash4()],
      ),
    );
  }

  // ================= SPLASH 1 =================
  Widget _splash1() {
    return Container(
      color: const Color(0xFF6A0DAD),
      child: Center(child: Image.asset("assets/splash1.png", height: 200)),
    );
  }

  // ================= SPLASH 2 =================
  Widget _splash2() {
    return _basePage(
      bgColor: Colors.white,
      image: Image.asset("assets/splash2.png", height: 200),
      title: "Welcome to Mentalist",
      desc:
          "This platform is designed to support counselors in managing sessions, client information, and counseling documentation in a structured and professional environment.",
      leftText: "Skip",
      rightText: "Next",
      onLeft: _goToLast,
      onRight: _next,
    );
  }

  // ================= SPLASH 3 =================
  Widget _splash3() {
    return _basePage(
      bgColor: const Color(0xFF6A0DAD),
      forceWhiteContent: true,
      image: SizedBox(
        height: 220,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // 🧠 Otak - agak kiri atas
            Positioned(
              left: 50,
              top: 10,
              child: Image.asset("assets/splash3.png", height: 130),
            ),

            // 📋 Kotak - kanan bawah
            Positioned(
              right: 45,
              bottom: 10,
              child: Image.asset("assets/splash4.png", height: 120),
            ),
          ],
        ),
      ),
      title: "Manage your counseling workflow",
      desc:
          "Organize schedules, conduct counseling sessions, document session notes, and communicate with clients through one integrated system.",
      leftText: "Back",
      rightText: "Next",
      onLeft: _back,
      onRight: _next,
    );
  }

  // ================= SPLASH 4 =================
  Widget _splash4() {
    return _basePage(
      bgColor: Colors.white,
      image: Transform.translate(
        offset: const Offset(20, 0), // kompensasi logo tidak simetris
        child: Image.asset("assets/splash5.png", height: 200),
      ),
      title: "Confidentiality and Responsibility",
      desc:
          "All client information and counseling records are securely protected. Please use this platform responsibly and in accordance with professional counseling standards.",
      leftText: "Back",
      rightText: "Enter Login",
      onLeft: _back,
      onRight: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const CounselorLoginPage()),
        );
      },
    );
  }

  // ================= BASE PAGE (FIX LAYOUT) =================
  Widget _basePage({
    required Color bgColor,
    required Widget image,
    required String title,
    required String desc,
    required String leftText,
    required String rightText,
    required VoidCallback onLeft,
    required VoidCallback onRight,
    bool forceWhiteContent = false,
  }) {
    final titleColor = forceWhiteContent
        ? Colors.white
        : (bgColor == Colors.white ? Colors.black : Colors.white);

    final descColor = forceWhiteContent
        ? Colors.white70
        : (bgColor == Colors.white ? Colors.black54 : Colors.white70);

    final dotActive = forceWhiteContent ? Colors.white : Colors.deepPurple;
    final dotInactive = forceWhiteContent ? Colors.white54 : Colors.grey;

    final buttonColor = forceWhiteContent
        ? Colors.white
        : (bgColor == Colors.white ? Colors.black : Colors.white);

    return Container(
      color: bgColor,
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Spacer(),

          // ===== KONTEN UTAMA (CENTER SEBENARNYA) =====
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: titleColor,
            ),
          ),
          const SizedBox(height: 24),
          image,
          const SizedBox(height: 24),
          Text(
            desc,
            textAlign: TextAlign.center,
            style: TextStyle(color: descColor),
          ),

          const Spacer(),

          // ===== DOT =====
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              4,
              (dot) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: index == dot ? 16 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: index == dot ? dotActive : dotInactive,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // ===== BUTTON =====
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: onLeft,
                child: Text(leftText, style: TextStyle(color: buttonColor)),
              ),
              TextButton(
                onPressed: onRight,
                child: Text(rightText, style: TextStyle(color: buttonColor)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ================= HELPERS =================
  void _next() => _controller.nextPage(
    duration: const Duration(milliseconds: 400),
    curve: Curves.easeInOut,
  );

  void _back() => _controller.previousPage(
    duration: const Duration(milliseconds: 400),
    curve: Curves.easeInOut,
  );

  void _goToLast() => _controller.animateToPage(
    3,
    duration: const Duration(milliseconds: 500),
    curve: Curves.easeInOut,
  );
}
