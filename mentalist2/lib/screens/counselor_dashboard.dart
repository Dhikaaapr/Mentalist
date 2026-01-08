// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'schedule_page.dart';
import 'profile_page.dart';
import 'counselor_list_page.dart';
import 'history_page.dart';

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
  int selectedNav = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      /// -------- TOP HEADER --------
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(120),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          decoration: const BoxDecoration(
            color: Color(0xffd9d9d9),
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  /// Profile Button
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ProfilePage()),
                    ),
                    child: CircleAvatar(
                      radius: 22,
                      backgroundColor: Colors.purple,
                      backgroundImage: widget.counselorPhotoUrl != null
                          ? NetworkImage(widget.counselorPhotoUrl!)
                          : null,
                      child: widget.counselorPhotoUrl == null
                          ? const Icon(Icons.person, color: Colors.white)
                          : null,
                    ),
                  ),

                  /// Notification
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.notifications_none_rounded,
                      color: Colors.purple,
                      size: 28,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 5),

              Text(
                "Nov 9, 2025",
                style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
              ),
              const SizedBox(height: 3),
              Text(
                "Good Day, ${widget.counselorName}!",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),

      /// -------- BODY --------
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Quick Stats",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 15),

            /// Row 1
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                statItem(number: "5", label: "Session\nThis Week"),
                statItem(number: "12", label: "Counseling\nNotes"),
              ],
            ),

            const SizedBox(height: 12),

            /// Row 2
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                statItem(
                  number: "4",
                  label: "Active Clients",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const CounselorListPage(),
                      ),
                    );
                  },
                ),
                statItem(number: "8", label: "Hours\nRemaining"),
              ],
            ),

            const SizedBox(height: 30),

            /// -------- TODAY SCHEDULE INSIDE BORDER --------
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xffe6e6e6),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// Title + View Clients Button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Today's Schedule",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const SchedulePage(),
                            ),
                          );
                        },
                        child: const Text(
                          "View Clients",
                          style: TextStyle(
                            color: Color.fromARGB(255, 110, 16, 183),
                          ),
                        ),
                      ),
                    ],
                  ),

                  Text(
                    "November 9, 2025",
                    style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                  ),

                  const SizedBox(height: 16),

                  scheduleCard(
                    "Nathaniel A",
                    "08:00 - 10:00",
                    Colors.green,
                    "Done",
                  ),
                  scheduleCard(
                    "Sarah L",
                    "11:00 - 13:00",
                    const Color.fromARGB(255, 58, 26, 243),
                    "Ongoing",
                  ),
                  scheduleCard(
                    "Timothy",
                    "14:00 - 17:00",
                    const Color.fromARGB(255, 51, 7, 128),
                    "Start",
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      /// -------- BOTTOM NAV --------
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: const BoxDecoration(
          color: Color.fromARGB(255, 110, 16, 183),
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _navItem(index: 0, icon: Icons.home),
            _navItem(index: 1, icon: Icons.calendar_month),
            _navItem(index: 2, icon: Icons.history),
          ],
        ),
      ),
    );
  }

  /// ------------ COMPONENTS ------------

  Widget _navItem({required int index, required IconData icon}) {
    bool isSelected = selectedNav == index;

    return GestureDetector(
      onTap: () {
        setState(() => selectedNav = index);

        if (index == 1) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SchedulePage()),
          );
        } else if (index == 2) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const HistoryPage()),
          );
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(8),
        child: Icon(icon, size: isSelected ? 32 : 26, color: Colors.white),
      ),
    );
  }

  /// Quick Stats Box
  Widget statItem({
    required String number,
    required String label,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 150,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 110, 16, 183),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            Text(
              number,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  /// Schedule Item UI
  Widget scheduleCard(String name, String time, Color color, String status) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          const CircleAvatar(radius: 22, child: Icon(Icons.person)),
          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  time,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                ),
              ],
            ),
          ),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(status, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
