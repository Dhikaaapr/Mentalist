import 'package:flutter/material.dart';
import '../services/admin_api_services.dart';
import 'report_page.dart';
import 'admin_management_page.dart';
import 'admin_user_management_page.dart';
import 'notification_page.dart';
import 'schedule_approval_counselors.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  String _adminName = 'Admin';
  String? _adminPicture;
  bool _isLoading = true;

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
      'page': const AdminManagementPage(),
    },
    {
      'icon': Icons.calendar_month_rounded,
      'title': "Setting Session",
      'page': const AdminUserManagementPage(),
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadAdminProfile();
  }

  Future<void> _loadAdminProfile() async {
    final result = await AdminApiService.getProfile();

    if (result['success'] == true && result['user'] != null) {
      final user = result['user'];
      setState(() {
        _adminName = user['name'] ?? 'Admin';
        _adminPicture = user['picture'];
      });
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    // Define menu items inside build or move them to state if they need context access,
    // but here they seem static enough or can be rebuilt.
    // Ideally, keep them where they were or ensure ScheduleApprovalCounselors is const if possible.
    final List<Map<String, dynamic>> menuItems = [
      {
        'icon': Icons.storage_rounded,
        'title': "Report & analysis",
        'page': const ReportPage(),
      },
      {
        'icon': Icons.phone_android_rounded,
        'title': "Approval",
        'page': const ScheduleApprovalCounselors(),
      },
      {
        'icon': Icons.groups_rounded,
        'title': "Management",
        'page': const AdminManagementPage(),
      },
      {
        'icon': Icons.calendar_month_rounded,
        'title': "Setting Session",
        'page': const AdminUserManagementPage(),
      },
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),

              // Header with profile
              Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: const Color(0xFFE0E0E0),
                    backgroundImage: _adminPicture != null
                        ? NetworkImage(_adminPicture!)
                        : null,
                    child: _adminPicture == null
                        ? const Icon(
                            Icons.person,
                            size: 34,
                            color: Color(0xFF3F3D7D),
                          )
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _isLoading ? '...' : _adminName,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
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
                        if (item['page'] != null) {
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
}
