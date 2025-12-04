import 'package:flutter/material.dart';
import '../theme/colors.dart';
import 'schedule_page.dart';
import 'chat_list_page.dart';
import 'profile_page.dart';
import 'counselor_page.dart';
import 'counseling_session_page.dart';
import 'history_page.dart';

class UserDashboardPage extends StatefulWidget {
  final String userName;
  final String userEmail;
  final String? userPhotoUrl;

  const UserDashboardPage({
    super.key,
    required this.userName,
    required this.userEmail,
    this.userPhotoUrl,
  });

  @override
  State<UserDashboardPage> createState() => _UserDashboardPageState();
}

class _UserDashboardPageState extends State<UserDashboardPage> {
  int currentIndex = 0;

  late final List<Widget> pages = [
    HomeView(name: widget.userName, photo: widget.userPhotoUrl),
    const SchedulePage(),
    const ChatListPage(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(index: currentIndex, children: pages),
      bottomNavigationBar: _bottomNav(),
    );
  }

  Widget _bottomNav() {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (index) => setState(() => currentIndex = index),
      selectedItemColor: AppColors.primary,
      unselectedItemColor: Colors.grey,
      backgroundColor: Colors.white,
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: "Home"),
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_month),
          label: "Schedule",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.chat_bubble_outline),
          label: "Chat",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          label: "Profile",
        ),
      ],
    );
  }
}

class HomeView extends StatefulWidget {
  final String name;
  final String? photo;

  const HomeView({super.key, required this.name, this.photo});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  String? selectedMood;

  List<Color> weeklyColors = List.generate(7, (_) => Colors.grey.shade300);

  final moods = ["😄", "😊", "😐", "😕", "😭"];
  final weeklyLabels = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];

  final quickMenu = [
    {"icon": Icons.local_hospital_rounded, "label": "Counseling"},
    {"icon": Icons.event_available, "label": "Schedule"},
    {"icon": Icons.search_rounded, "label": "Find Counselor"},
    {"icon": Icons.history, "label": "History"},
  ];

  final newsData = [
    {
      "title": "How to manage anxiety?",
      "img": "https://picsum.photos/200/300?1",
    },
    {
      "title": "Breathing exercises to relax",
      "img": "https://picsum.photos/200/300?2",
    },
    {"title": "Signs of burnout?", "img": "https://picsum.photos/200/300?3"},
  ];

  void _selectMood(String mood) {
    setState(() {
      selectedMood = mood;
      weeklyColors[DateTime.now().weekday - 1] = _getMoodColor(mood);
    });

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Mood Saved 😊"),
        content: Text("Mood kamu hari ini: $mood"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Oke"),
          ),
        ],
      ),
    );
  }

  Color _getMoodColor(String mood) {
    switch (mood) {
      case "😄":
        return Colors.greenAccent.shade200;
      case "😊":
        return Colors.lightGreen.shade200;
      case "😐":
        return Colors.amber.shade200;
      case "😕":
        return Colors.orange.shade300;
      case "😭":
        return Colors.red.shade300;
      default:
        return Colors.grey.shade300;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HEADER
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 26,
                      backgroundImage: widget.photo != null
                          ? NetworkImage(widget.photo!)
                          : null,
                      child: widget.photo == null
                          ? const Icon(Icons.person, size: 30)
                          : null,
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      "Mentalist",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.notifications),
                ),
              ],
            ),

            const SizedBox(height: 25),

            // MOOD SECTION
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: moods.map((m) {
                final selected = m == selectedMood;
                return GestureDetector(
                  onTap: () => _selectMood(m),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: selected
                            ? Colors.blueAccent
                            : Colors.grey.shade300,
                        width: selected ? 3 : 1,
                      ),
                      color: selected
                          ? Colors.blue.shade50
                          : Colors.transparent,
                    ),
                    child: Text(m, style: const TextStyle(fontSize: 22)),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 30),

            const Text(
              "Mood Tracker",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 14),

            SizedBox(
              height: 90,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(7, (i) {
                  return Column(
                    children: [
                      Container(
                        height: 50,
                        width: 30,
                        decoration: BoxDecoration(
                          color: weeklyColors[i],
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        weeklyLabels[i],
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ),

            const SizedBox(height: 25),
            Divider(color: Colors.grey.shade300),
            const SizedBox(height: 18),

            // QUICK MENU
            const Text(
              "Quick Menu",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),

            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: quickMenu.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                childAspectRatio: 1.15,
              ),
              itemBuilder: (context, i) {
                return GestureDetector(
                  onTap: () {
                    if (quickMenu[i]["label"] == "Find Counselor") {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const CounselorPage(),
                        ),
                      );
                    } else if (quickMenu[i]["label"] == "Schedule") {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SchedulePage()),
                      );
                    } else if (quickMenu[i]["label"] == "Counseling") {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const CounselingSessionPage(),
                        ),
                      );
                    }
                    /// 👇 FITUR BARU HISTORY
                    else if (quickMenu[i]["label"] == "History") {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => HistoryPage(userId: widget.name),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            "${quickMenu[i]["label"]} Coming soon 🚧",
                          ),
                        ),
                      );
                    }
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          quickMenu[i]["icon"] as IconData,
                          size: 35,
                          color: AppColors.primary,
                        ),

                        const SizedBox(height: 10),
                        Text(
                          quickMenu[i]["label"].toString(),
                          style: const TextStyle(fontSize: 15),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 30),

            // UPCOMING SESSION
            const Text(
              "Upcoming Session",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Row(
                children: const [
                  Icon(Icons.calendar_month, color: Colors.blue, size: 28),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "Next counseling with Dr. Maya\nToday at 4:00 PM",
                      style: TextStyle(fontSize: 15),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // NEWS
            const Text(
              "Recommended for you",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 14),

            SizedBox(
              height: 170,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: newsData.length,
                separatorBuilder: (_, __) => const SizedBox(width: 14),
                itemBuilder: (_, i) {
                  return Container(
                    width: 150,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      image: DecorationImage(
                        image: NetworkImage(newsData[i]["img"]!),
                        fit: BoxFit.cover,
                        opacity: .8,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Align(
                      alignment: Alignment.bottomLeft,
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Text(
                          newsData[i]["title"]!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            shadows: [
                              Shadow(color: Colors.black, blurRadius: 6),
                            ],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 30),

            // DAILY QUOTE
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Text(
                "“Sometimes the smallest step in the right direction ends up being the biggest step of your life.” 💙",
                style: TextStyle(fontSize: 15, fontStyle: FontStyle.italic),
              ),
            ),

            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }
}
