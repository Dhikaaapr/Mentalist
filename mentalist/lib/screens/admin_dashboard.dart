import 'package:flutter/material.dart';
import 'user_list_page.dart';
import 'counselor_list_page.dart';
import 'schedule_management_page.dart';
import 'counselor_rating_page.dart';

class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> menuItems = [
      {
        'icon': Icons.people,
        'title': 'Daftar User',
        'page': const UserListPage(),
      },
      {
        'icon': Icons.psychology,
        'title': 'Daftar Konselor',
        'page': const CounselorListPage(),
      },
      {
        'icon': Icons.calendar_today,
        'title': 'Pengelolaan Jadwal',
        'page': const ScheduleManagementPage(),
      },
      {
        'icon': Icons.star_rate,
        'title': 'Penilaian Konselor',
        'page': const CounselorRatingPage(),
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Dashboard Admin',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF283E51), Color(0xFF485563)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: menuItems.length,
            itemBuilder: (context, index) {
              final item = menuItems[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => item['page']),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha:25),//0.1*255 = 25
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha:25),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(item['icon'], color: Colors.blueAccent, size: 50),
                      const SizedBox(height: 12),
                      Text(
                        item['title'],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
