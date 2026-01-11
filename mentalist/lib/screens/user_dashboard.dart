import 'package:flutter/material.dart';
import '../theme/colors.dart';
import 'schedule_page.dart';
import 'profile_page.dart';
import 'counselor_page.dart';
import 'counseling_session_page.dart';
import 'history_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'notification_page.dart';
import '../services/booking_api_service.dart';
import 'package:intl/intl.dart';

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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 8),
      height: 65,
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 69, 137, 255),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _navItem(Icons.home_rounded, 0, "Home"),
          _navItem(Icons.calendar_month_rounded, 1, "Schedule"),
          _navItem(Icons.person_rounded, 2, "Profile"),
        ],
      ),
    );
  }

  Widget _navItem(IconData icon, int index, String label) {
    bool active = currentIndex == index;

    return GestureDetector(
      onTap: () {
        ("NAV TO INDEX → $index");
        setState(() => currentIndex = index);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.symmetric(
          horizontal: active ? 14 : 10,
          vertical: active ? 6 : 4,
        ),
        decoration: BoxDecoration(
          color: active
              ? Colors.white.withValues(alpha: 0.20)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            AnimatedScale(
              duration: const Duration(milliseconds: 220),
              scale: active ? 1.15 : 1.0,
              child: Icon(icon, size: 24, color: Colors.white),
            ),

            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: active ? 48 : 0,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 250),
                opacity: active ? 1 : 0,
                child: Padding(
                  padding: const EdgeInsets.only(left: 6),
                  child: Text(
                    label,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
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

  Map<String, String?> weeklyMood = {
    "Mon": null,
    "Tue": null,
    "Wed": null,
    "Thu": null,
    "Fri": null,
    "Sat": null,
    "Sun": null,
  };

  List<Color> weeklyColors = List.generate(7, (_) => Colors.grey.shade300);
  Map<String, dynamic>? latestBooking;
  bool isBookingLoading = true;

  void _loadLatestBooking() async {
    setState(() => isBookingLoading = true);
    final result = await BookingApiService.getLatestConfirmedBooking();
    if (result != null && result['success'] == true) {
      setState(() {
        latestBooking = result['data'];
        isBookingLoading = false;
      });
    } else {
      setState(() => isBookingLoading = false);
    }
  }

  void _loadWeeklyMood() async {
    final prefs = await SharedPreferences.getInstance();

    // Cek minggu baru
    String currentWeek = "${DateTime.now().year}-${DateTime.now().weekday}";
    String? savedWeek = prefs.getString("saved_week");

    if (savedWeek != currentWeek) {
      // reset semua mood bila minggu baru
      for (var day in weeklyLabels) {
        prefs.remove("mood_$day");
        weeklyMood[day] = null;
      }
      prefs.setString("saved_week", currentWeek);
    }

    // Load data mood
    for (int i = 0; i < weeklyLabels.length; i++) {
      String day = weeklyLabels[i];
      String? mood = prefs.getString("mood_$day");

      if (mood != null) {
        weeklyMood[day] = mood;
        weeklyColors[i] = _getMoodColor(mood);
      }
    }

    setState(() {});
  }

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

  void _selectMood(String mood) async {
    final prefs = await SharedPreferences.getInstance();
    String today = weeklyLabels[DateTime.now().weekday - 1];

    setState(() {
      selectedMood = mood;
      weeklyMood[today] = mood;
      weeklyColors[DateTime.now().weekday - 1] = _getMoodColor(mood);
    });

    // simpan ke shared prefs
    prefs.setString("mood_$today", mood);

    // CEK: widget masih mounted atau tidak
    if (!mounted) return;

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
  void initState() {
    super.initState();
    _loadWeeklyMood();
    _loadLatestBooking();
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
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const NotificationPage(),
                      ),
                    );
                  },
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
                            ? const Color.fromARGB(255, 69, 137, 255)
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
                    } else if (quickMenu[i]["label"] == "History") {
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
              "Schedule Session",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            if (isBookingLoading)
              const Center(child: CircularProgressIndicator())
            else if (latestBooking != null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 69, 137, 255),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // FOTO KONSELOR
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: latestBooking!['counselor']['picture'] != null
                          ? Image.network(
                              latestBooking!['counselor']['picture'],
                              height: 65,
                              width: 65,
                              fit: BoxFit.cover,
                            )
                          : Container(
                              height: 65,
                              width: 65,
                              color: Colors.white24,
                              child: const Icon(Icons.person, color: Colors.white),
                            ),
                    ),

                    const SizedBox(width: 14),

                    // NAMA + JADWAL
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            latestBooking!['counselor']['name'] ?? 'Konselor',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            DateFormat('EEEE, h:mm a').format(
                              DateTime.parse(latestBooking!['scheduled_at']).toLocal(),
                            ),
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color.fromARGB(255, 248, 247, 247),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // ICON NEXT
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Colors.white24,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              )
            else
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  children: [
                    Icon(Icons.calendar_today_outlined, color: Colors.grey.shade400, size: 32),
                    const SizedBox(height: 10),
                    const Text(
                      "No upcoming session",
                      style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 4),
                    TextButton(
                      onPressed: () {
                        // Navigate to find counselor
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const CounselorPage()),
                        );
                      },
                      child: const Text("Find a counselor"),
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
