import 'package:flutter/material.dart';
import 'login_page.dart';
import 'schedule_page.dart';
import 'profile_page.dart';

class CounselorDashboardPage extends StatefulWidget {
  const CounselorDashboardPage({super.key});

  @override
  State<CounselorDashboardPage> createState() => _CounselorDashboardPageState();
}

class _CounselorDashboardPageState extends State<CounselorDashboardPage> {
  bool _showProfile = false;

  void _logout(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_showProfile ? "Profil Konselor" : "Dashboard Konselor"),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(_showProfile ? Icons.close : Icons.logout),
            onPressed: () {
              if (_showProfile) {
                setState(() {
                  _showProfile = false;
                });
              } else {
                _logout(context);
              }
            },
          ),
        ],
      ),

      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _showProfile ? const ProfilePage() : _buildDashboard(context),
      ),

      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        child: SizedBox(
          height: 60,
          child: Center(
            child: IconButton(
              icon: Icon(
                _showProfile ? Icons.person : Icons.person_outline,
                color: Colors.deepPurple,
                size: 32,
              ),
              onPressed: () {
                setState(() {
                  _showProfile = !_showProfile;
                });
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDashboard(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: GridView.count(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        children: [
          _buildMenuCard(Icons.edit_note, "Catatan Konseling", () {}),

          _buildMenuCard(Icons.calendar_today, "Jadwal Konseling", () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SchedulePage()),
            );
          }),
          _buildMenuCard(Icons.chat, "Chat", () {}),
          _buildMenuCard(Icons.person, "Profil Saya", () {
            setState(() {
              _showProfile = true;
            });
          }),
        ],
      ),
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
              blurRadius: 5,
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
