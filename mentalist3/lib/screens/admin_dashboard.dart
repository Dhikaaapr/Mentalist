import 'package:flutter/material.dart';
import 'profile_page.dart';
import 'user_list_page.dart';
import 'counselor_list_page.dart';
import 'schedule_management_counselors.dart';
import 'schedule_management_users.dart';
import 'report_page.dart';
import 'notification_page.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  final TextEditingController _searchController = TextEditingController();

  late List<Map<String, dynamic>> filteredMenuItems;

  final List<Map<String, dynamic>> menuItems = [
    {
      'icon': Icons.bar_chart_rounded,
      'title': "Report & analysis",
      'page': const ReportPage(),
    },
    {'icon': Icons.calendar_month, 'title': "Booking", 'page': null},
    {
      'icon': Icons.groups_rounded,
      'title': "Counselors manage",
      'page': const CounselorListPage(),
    },
    {
      'icon': Icons.person_rounded,
      'title': "Users manage",
      'page': const UserListPage(),
    },
  ];

  @override
  void initState() {
    super.initState();
    filteredMenuItems = List.from(menuItems);
  }

  void _filterMenu(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredMenuItems = List.from(menuItems);
      } else {
        filteredMenuItems = menuItems
            .where(
              (item) =>
                  item['title'].toLowerCase().contains(query.toLowerCase()),
            )
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () =>
          FocusScope.of(context).unfocus(), // close keyboard when tap outside
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// HEADER
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AdminProfilePage(),
                          ),
                        );
                      },
                      child: Row(
                        children: const [
                          CircleAvatar(
                            radius: 26,
                            backgroundColor: Color(0xFFE0E0E0),
                            child: Icon(
                              Icons.person,
                              size: 30,
                              color: Color(0xFF6A1B9A),
                            ),
                          ),
                          SizedBox(width: 12),
                          Text(
                            "Sarah Lee",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Spacer(),

                    IconButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const NotificationPage(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.notifications),
                      color: Color(0xFF6A1B9A),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                /// SEARCH FIELD
                TextField(
                  controller: _searchController,
                  onChanged: _filterMenu,
                  decoration: InputDecoration(
                    hintText: "Search",
                    prefixIcon: const Icon(Icons.search),
                    fillColor: Colors.grey.shade200,
                    filled: true,
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              _filterMenu('');
                              FocusScope.of(context).unfocus();
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                const Text(
                  "Menu",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 15),

                /// MENU GRID
                Expanded(
                  child: filteredMenuItems.isEmpty
                      ? const Center(
                          child: Text(
                            "No menu found",
                            style: TextStyle(color: Colors.grey),
                          ),
                        )
                      : GridView.builder(
                          itemCount: filteredMenuItems.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 0.78,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                              ),
                          itemBuilder: (context, index) {
                            final item = filteredMenuItems[index];

                            return GestureDetector(
                              onTap: () {
                                if (item['title'] == "Booking") {
                                  showBookingPopup(context);
                                } else {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => item['page'],
                                    ),
                                  );
                                }
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CircleAvatar(
                                      radius: 30,
                                      backgroundColor: Colors.white,
                                      child: Icon(
                                        item['icon'],
                                        size: 35,
                                        color: const Color(0xFF6A1B9A),
                                      ),
                                    ),
                                    const SizedBox(height: 15),
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
      ),
    );
  }

  /// POPUP BOOKING
  void showBookingPopup(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: 300,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFE4E4E4),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _popupButton(
                    context,
                    "Schedule Management counselors",
                    const ScheduleManagementCounselors(),
                  ),
                  const SizedBox(height: 20),
                  _popupButton(
                    context,
                    "Schedule Management users",
                    const ScheduleManagementUsers(),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _popupButton(BuildContext context, String text, Widget page) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF6A1B9A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: () {
          Navigator.pop(context);
          Navigator.push(context, MaterialPageRoute(builder: (_) => page));
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                text,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13, color: Colors.white),
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward, size: 18, color: Colors.white),
          ],
        ),
      ),
    );
  }
}
