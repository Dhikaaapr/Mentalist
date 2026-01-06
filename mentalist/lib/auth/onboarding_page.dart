import 'package:flutter/material.dart';
import '../auth/login_page.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _controller = PageController();
  int index = 0;

  static const Color primary = Color(0xFF5C63D8);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _controller,
        physics: const NeverScrollableScrollPhysics(),
        onPageChanged: (i) => setState(() => index = i),
        children: [
          _page(
            bg: Colors.white,
            image: "assets/splash1.png",
            title: "Welcome to Mentalist",
            desc:
                "This platform helps you reflect on your emotional well-being and connect with professional counselors when you need support.",
            left: "Skip",
            right: "Next",
            onLeft: _skip,
            onRight: _next,
            darkText: true,
          ),
          _page(
            bg: primary,
            image: "assets/splash2.png",
            title: "Connect with a Counselor",
            desc:
                "Book counseling sessions and communicate with professional counselors in a safe and supportive space.",
            left: "Back",
            right: "Next",
            onLeft: _back,
            onRight: _next,
          ),
          _page(
            bg: Colors.white,
            image: "assets/splash3.png",
            title: "Get Support When It Matters",
            desc:
                "Schedule sessions, share openly, and receive guidance to support your emotional well-being.",
            left: "Back",
            right: "Next",
            onLeft: _back,
            onRight: _next,
            darkText: true,
          ),
          _page(
            bg: primary,
            image: "assets/splash4.png",
            title: "You're all set",
            desc:
                "Start exploring the platform and connect with a counselor whenever you need support.",
            left: "Back",
            right: "Get Started",
            onLeft: _back,
            onRight: _finish,
          ),
        ],
      ),
    );
  }

  // ================= PAGE TEMPLATE =================
  Widget _page({
    required Color bg,
    required String image,
    required String title,
    required String desc,
    required String left,
    required String right,
    required VoidCallback onLeft,
    required VoidCallback onRight,
    bool darkText = false,
  }) {
    final titleColor = darkText ? Colors.black : Colors.white;
    final descColor = darkText ? Colors.black54 : Colors.white70;
    final btnColor = darkText ? primary : Colors.white;

    return Container(
      padding: const EdgeInsets.all(24),
      color: bg,
      child: Column(
        children: [
          const Spacer(),

          Image.asset(image, height: 200),
          const SizedBox(height: 32),

          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: titleColor,
            ),
          ),
          const SizedBox(height: 16),

          Text(
            desc,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: descColor),
          ),

          const Spacer(),

          _indicator(bg),
          const SizedBox(height: 20),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: onLeft,
                child: Text(left, style: TextStyle(color: btnColor)),
              ),
              TextButton(
                onPressed: onRight,
                child: Text(right, style: TextStyle(color: btnColor)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ================= DOT INDICATOR (FIX WARNA) =================
  Widget _indicator(Color bg) {
    final active = bg == Colors.white ? primary : Colors.white;
    final inactive = bg == Colors.white ? Colors.grey : Colors.white54;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        4,
        (i) => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: index == i ? 18 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: index == i ? active : inactive,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  // ================= ACTIONS =================
  void _next() => _controller.nextPage(
    duration: const Duration(milliseconds: 400),
    curve: Curves.easeInOut,
  );

  void _back() => _controller.previousPage(
    duration: const Duration(milliseconds: 400),
    curve: Curves.easeInOut,
  );

  void _skip() => _controller.animateToPage(
    3,
    duration: const Duration(milliseconds: 500),
    curve: Curves.easeInOut,
  );

  void _finish() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  }
}
