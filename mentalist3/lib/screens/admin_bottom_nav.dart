import 'package:flutter/material.dart';

import 'admin_dashboard.dart';
import 'profile_page.dart';
import 'notification_page.dart';
import 'therapy_session_page.dart'; // ✅ TAMBAHAN

class AdminBottomNav extends StatefulWidget {
  const AdminBottomNav({super.key});

  @override
  State<AdminBottomNav> createState() => _AdminBottomNavState();
}

class _AdminBottomNavState extends State<AdminBottomNav> {
  int _currentIndex = 1;

  // ❗ HANYA TAB ASLI
  final List<Widget> _pages = const [
    AdminProfilePage(),
    AdminDashboardPage(),
    NotificationPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],

      bottomNavigationBar: Container(
        height: 70,
        decoration: const BoxDecoration(
          color: Color(0xFF3F3D7D),
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _item(icon: Icons.person, index: 0),
            _item(icon: Icons.home, index: 1),
            _therapyItem(), // 🧠 KHUSUS
          ],
        ),
      ),
    );
  }

  // ================= TAB NORMAL =================
  Widget _item({required IconData icon, required int index}) {
    final active = _currentIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() => _currentIndex = index);
      },
      child: Icon(
        icon,
        size: 28,
        color: active ? Colors.white : Colors.white70,
      ),
    );
  }

  // ================= ICON OTAK =================
  Widget _therapyItem() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const TherapySessionPage()),
        );
      },
      child: const Icon(
        Icons.psychology_alt_rounded,
        size: 28,
        color: Colors.white70,
      ),
    );
  }
}
