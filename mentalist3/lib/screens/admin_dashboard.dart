import 'package:flutter/material.dart';
import 'report_page.dart';
import 'admin_management_page.dart'; // Import the new page
import 'admin_user_management_page.dart'; // Import user management page
import 'notification_page.dart';
import 'schedule_approval_counselors.dart'; // ✅ FIX
import 'schedule_management_users.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  final List<Map<String, dynamic>> menuItems = [
    {
      'icon': Icons.storage_rounded,
      'title': "Report & analysis",
      'page': const ReportPage(),
    },
    {'icon': Icons.phone_android_rounded, 'title': "Approval", 'page': null},
    {
      'icon': Icons.groups_rounded,
      'title': "Management",
      'page': const AdminManagementPage(), // Updated to new page
    },
    {
      'icon': Icons.calendar_month_rounded,
      'title': "Setting Session",
      'page': const AdminUserManagementPage(), // Updated to user management
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),

              Row(
                children: [
                  const CircleAvatar(
                    radius: 30,
                    backgroundColor: Color(0xFFE0E0E0),
                    child: Icon(
                      Icons.person,
                      size: 34,
                      color: Color(0xFF3F3D7D),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    "Sarah Lee",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(
                      Icons.notifications,
                      color: Color(0xFF3F3D7D),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const NotificationPage(),
                        ),
                      );
                    },
                  ),
                ],
              ),

              const SizedBox(height: 16),

              Container(
                height: 42,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFE0E0E0),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.search, color: Colors.grey),
                    SizedBox(width: 8),
                    Text("Search", style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ),

              const SizedBox(height: 22),
              const Text(
                "Menu",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              Expanded(
                child: GridView.builder(
                  itemCount: menuItems.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 0.9,
                  ),
                  itemBuilder: (context, index) {
                    final item = menuItems[index];
                    return GestureDetector(
                      onTap: () {
                        if (item['title'] == "Approval") {
                          showApprovalPopup(context);
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => item['page']),
                          );
                        }
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFE0E0E0),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              radius: 36,
                              backgroundColor: const Color(0xFF3F3D7D),
                              child: Icon(
                                item['icon'],
                                size: 34,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 14),
                            Text(
                              item['title'],
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void showApprovalPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _popupButton(
              context,
              "Schedule Approval counselors",
              const ScheduleApprovalCounselors(), // ✅ FIX
            ),
            const SizedBox(height: 16),
            _popupButton(
              context,
              "Schedule Management users",
              const ScheduleManagementUsers(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _popupButton(BuildContext context, String text, Widget page) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF3F3D7D),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: () {
          Navigator.pop(context);
          Navigator.push(context, MaterialPageRoute(builder: (_) => page));
        },
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
