// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'counselor_login_page.dart';
import 'schedule_page.dart';
import 'profile_page.dart';

class CounselorDashboardPage extends StatefulWidget {
  final String counselorName;
  final String counselorEmail;
  final String? counselorPhotoUrl;

  const CounselorDashboardPage({
    super.key,
    required this.counselorName,
    required this.counselorEmail,
    this.counselorPhotoUrl,
  });

  @override
  State<CounselorDashboardPage> createState() => _CounselorDashboardPageState();
}

class _CounselorDashboardPageState extends State<CounselorDashboardPage> {
  int _selectedIndex = 0;

  void _logout(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const CounselorLoginPage()),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [_buildDashboard(context), const ProfilePage()];

    return Scaffold(
      backgroundColor: const Color(0xfff5f7fb),
      appBar: AppBar(
        title: Text(
          _selectedIndex == 0 ? "Dashboard Konselor" : "Profil Konselor",
        ),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          if (_selectedIndex == 0)
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () => _logout(context),
            ),
        ],
      ),
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.deepPurple,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: "Dashboard",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profil"),
        ],
      ),
    );
  }

  Widget _buildDashboard(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildWelcomeCard(),
          const SizedBox(height: 20),
          _buildDashboardMenu(context),
        ],
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.deepPurple,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(2, 2)),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.white,
            backgroundImage: widget.counselorPhotoUrl != null
                ? NetworkImage(widget.counselorPhotoUrl!)
                : null,
            child: widget.counselorPhotoUrl == null
                ? const Icon(Icons.person, color: Colors.deepPurple, size: 35)
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Selamat Datang,",
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 14,
                  ),
                ),
                Text(
                  widget.counselorName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.counselorEmail,
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardMenu(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      children: [
        _buildMenuCard(Icons.edit_note, "Catatan Konseling", () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Fitur Catatan Konseling belum tersedia"),
            ),
          );
        }),
        _buildMenuCard(Icons.calendar_today, "Jadwal Konseling", () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SchedulePage()),
          );
        }),
        _buildMenuCard(Icons.chat, "Chat", () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Fitur Chat akan segera hadir")),
          );
        }),
        _buildMenuCard(Icons.people, "Daftar Klien", () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Fitur Daftar Klien belum tersedia")),
          );
        }),
      ],
    );
  }

  Widget _buildMenuCard(IconData icon, String title, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(2, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.deepPurple),
            const SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
