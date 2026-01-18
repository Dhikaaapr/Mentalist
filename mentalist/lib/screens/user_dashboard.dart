import 'package:flutter/material.dart';
import '../theme/colors.dart';
import 'schedule_page.dart';
import 'profile_page.dart';
import 'counselor_page.dart';
import 'counseling_session_page.dart';
import 'history_page.dart';

import 'notification_page.dart';
import '../services/booking_api_service.dart';
import '../services/api_service.dart';
import 'package:intl/intl.dart';
import 'chat_list_page.dart';
import '../services/mood_api_service.dart';

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
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navItem(Icons.home_rounded, 0, "Home"),
          _navItem(Icons.calendar_month_rounded, 1, "Schedule"),
          _navItem(Icons.chat_bubble_rounded, 2, "Chat"),
          _navItem(Icons.person_rounded, 3, "Profile"),
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
  String currentUserName = "User"; // Default
  String? currentUserPhoto;

  void _loadUserProfile() async {
    final result = await ApiService.getProfile();
    if (result != null && result['success'] == true) {
      if (mounted) {
        setState(() {
          currentUserName = result['data']['name'] ?? "User";
          currentUserPhoto = result['data']['picture']; // Assuming 'picture' field
        });
      }
    }
  }

  void _loadLatestBooking() async {
    setState(() => isBookingLoading = true);
    final result = await BookingApiService.getLatestConfirmedBooking();
    if (result != null && result['success'] == true) {
      if (mounted) { // Check mounted
          setState(() {
            latestBooking = result['data'];
            isBookingLoading = false;
          });
      }
    } else {
      if (mounted) setState(() => isBookingLoading = false);
    }
  }

  void _loadWeeklyMood() async {
    // Panggil API
    final result = await MoodApiService.getWeeklyMood();
    
    debugPrint('🔍 [MOOD] API Response: $result');
    
    if (result['success'] == true && result['data'] != null) {
      List data = result['data'];
      debugPrint('📊 [MOOD] Found ${data.length} mood entries');
      
      // Build new data structures FIRST (don't reset UI yet)
      Map<String, String?> newWeeklyMood = {
        "Mon": null,
        "Tue": null,
        "Wed": null,
        "Thu": null,
        "Fri": null,
        "Sat": null,
        "Sun": null,
      };
      List<Color> newWeeklyColors = List.generate(7, (_) => Colors.grey.shade300);
      
      // Mapping data API ke UI
      for (var item in data) {
        String entryDate = item['entry_date']; // "2026-01-19"
        String mood = item['mood_label'];
        
        debugPrint('  📅 [MOOD] Processing: $entryDate -> $mood');

        DateTime date = DateTime.parse(entryDate);
        // Cari hari apa (Senin=1 -> Mon)
        // weeklyLabels = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
        // date.weekday: 1=Senin, 7=Minggu. Index array = weekday - 1
        
        int dayIndex = date.weekday - 1;
        if (dayIndex >= 0 && dayIndex < 7) {
          String dayLabel = weeklyLabels[dayIndex];
          newWeeklyMood[dayLabel] = mood;
          newWeeklyColors[dayIndex] = _getMoodColor(mood);
        }
      }
      
      // SINGLE setState with all new data at once
      if (mounted) {
        setState(() {
          weeklyMood = newWeeklyMood;
          weeklyColors = newWeeklyColors;
        });
        debugPrint('✅ [MOOD] Graph updated with ${data.length} moods');
      }
    } else {
      debugPrint('❌ [MOOD] Failed to load moods: ${result['message']}');
    }
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
    // 1. Update UI Langsung (Optimistic UI)
    String todayLabel = weeklyLabels[DateTime.now().weekday - 1]; // "Mon"
    int todayIndex = DateTime.now().weekday - 1;

    setState(() {
      selectedMood = mood;
      weeklyMood[todayLabel] = mood;
      weeklyColors[todayIndex] = _getMoodColor(mood);
    });

    // 2. Kirim ke Backend
    final result = await MoodApiService.saveMood(mood, DateTime.now());

    // 3. Feedback Dialog
    if (!mounted) return;

    if (result['success']) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Mood Saved 😊"),
          content: Text("Mood kamu hari ini: $mood\nData tersimpan di cloud!"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Oke"),
            ),
          ],
        ),
      );
    } else {
       ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal menyimpan mood: ${result['message']}")),
      );
    }
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
    currentUserName = widget.name;
    currentUserPhoto = widget.photo;
    
    _loadWeeklyMood();
    _loadLatestBooking();
    _loadUserProfile(); // Load profile data
  }

  // Convert mood emoji to numeric value for graph
  double _getMoodValue(String? mood) {
    if (mood == null) return 0;
    switch (mood) {
      case "😄":
        return 2.0;  // Very Happy
      case "😊":
        return 1.0;  // Happy
      case "😐":
        return 0.0;  // Neutral
      case "😕":
        return -1.0; // Sad
      case "😭":
        return -2.0; // Very Sad
      default:
        return 0.0;
    }
  }

  // Build mood graph widget with Y-axis
  Widget _buildMoodGraph() {
    const double graphHeight = 180;
    const double barWidth = 32;
    const double unitHeight = 35; // Height per unit (1 point = 35px)
    
    return SizedBox(
      height: graphHeight + 40, // Extra space for labels
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Y-AXIS LABELS
          SizedBox(
            width: 30,
            height: graphHeight,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text("+2", style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                Text("+1", style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                Text("0", style: TextStyle(fontSize: 11, color: Colors.grey.shade600, fontWeight: FontWeight.bold)),
                Text("-1", style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                Text("-2", style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
              ],
            ),
          ),
          
          const SizedBox(width: 8),
          
          // GRAPH AREA
          Expanded(
            child: Column(
              children: [
                // Graph bars
                SizedBox(
                  height: graphHeight,
                  child: Stack(
                    children: [
                      // ZERO LINE (Reference line)
                      Positioned(
                        top: graphHeight / 2,
                        left: 0,
                        right: 0,
                        child: Container(
                          height: 1.5,
                          color: Colors.grey.shade400,
                        ),
                      ),
                      
                      // BARS
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: List.generate(7, (i) {
                          String dayLabel = weeklyLabels[i];
                          String? mood = weeklyMood[dayLabel];
                          double moodValue = _getMoodValue(mood);
                          double barHeight = moodValue.abs() * unitHeight;
                          bool isPositive = moodValue >= 0;
                          
                          return SizedBox(
                            width: barWidth,
                            height: graphHeight,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                if (moodValue != 0)
                                  Positioned(
                                    // Position bar relative to center (zero line)
                                    top: isPositive 
                                        ? (graphHeight / 2) - barHeight
                                        : graphHeight / 2,
                                    child: Container(
                                      width: barWidth,
                                      height: barHeight,
                                      decoration: BoxDecoration(
                                        color: weeklyColors[i],
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 10),
                
                // DAY LABELS
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: weeklyLabels.map((label) {
                    return SizedBox(
                      width: barWidth,
                      child: Text(
                        label,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
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
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Hi,",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                        Text(
                          currentUserName, // Dynamic Name
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
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

            // MOOD SECTION HEADER
            const Text(
              "How are you feeling today?",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 14),

            // MOOD SELECTION ICONS
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

            // GRAPH TITLE
            const Text(
              "Daily Mood (7 Weeks)",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 14),

            // WEEKLY MOOD GRAPH WITH Y-AXIS
            _buildMoodGraph(),

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
                              child: const Icon(
                                Icons.person,
                                color: Colors.white,
                              ),
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
                              DateTime.parse(
                                latestBooking!['scheduled_at'],
                              ).toLocal(),
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
                    Icon(
                      Icons.calendar_today_outlined,
                      color: Colors.grey.shade400,
                      size: 32,
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "No upcoming session",
                      style: TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    TextButton(
                      onPressed: () {
                        // Navigate to find counselor
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const CounselorPage(),
                          ),
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
