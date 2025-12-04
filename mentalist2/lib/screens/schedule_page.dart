import 'package:flutter/material.dart';

class SchedulePage extends StatelessWidget {
  const SchedulePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      /// ------------------ CUSTOM HEADER ------------------
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Back + Title
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new, size: 22),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Spacer(),
                  const Text(
                    "Schedule",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(flex: 2),
                ],
              ),

              const SizedBox(height: 10),

              /// ------------------ CALENDAR ------------------
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 110, 16, 183),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "November 2025",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 15),

                    /// Calendar grid mockup
                    GridView.count(
                      crossAxisCount: 7,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      children: List.generate(35, (index) {
                        final day = index - 2;
                        bool isToday = day == 9;

                        return Container(
                          decoration: BoxDecoration(
                            color: isToday
                                ? Colors.white
                                : Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            day > 0 ? "$day" : "",
                            style: TextStyle(
                              color: isToday
                                  ? const Color.fromARGB(255, 36, 13, 165)
                                  : Colors.white,
                              fontWeight: isToday
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              /// ------------------ UPCOMING SESSION ------------------
              const Text(
                "Upcoming Session",
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 10),

              _sessionCard(
                name: "Timothy",
                time: "14:00 - 17:00",
                buttonText: "Chat",
                buttonColor: const Color.fromARGB(255, 36, 13, 165),
              ),

              const SizedBox(height: 25),

              /// ------------------ TODAY'S SESSION ------------------
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Today's Sessions",
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 36, 13, 165),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    onPressed: () {},
                    child: const Text(
                      "View Clients",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),

              Text(
                "November 9, 2025",
                style: TextStyle(color: Colors.grey.shade600),
              ),

              const SizedBox(height: 14),

              /// ---- Session List ----
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xffe8e8e8),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  children: [
                    _sessionCard(
                      name: "Nathaniel A",
                      time: "08:00 - 10:00",
                      buttonText: "Done",
                      buttonColor: Colors.green,
                    ),
                    _sessionCard(
                      name: "Sarah L",
                      time: "11:00 - 13:00",
                      buttonText: "Ongoing",
                      buttonColor: Colors.blue,
                    ),
                    _sessionCard(
                      name: "Timothy",
                      time: "14:00 - 17:00",
                      buttonText: "Start",
                      buttonColor: const Color.fromARGB(255, 36, 13, 165),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// ------------------ CUSTOM CARD BUILDER ------------------
  Widget _sessionCard({
    required String name,
    required String time,
    required String buttonText,
    required Color buttonColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 238, 238, 238),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 22,
            backgroundColor: Color.fromARGB(255, 36, 13, 165),
            child: Icon(Icons.person, color: Colors.white),
          ),
          const SizedBox(width: 12),

          /// Text Section
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                Row(
                  children: [
                    const Icon(Icons.circle, size: 8, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(time, style: TextStyle(color: Colors.grey.shade700)),
                  ],
                ),
              ],
            ),
          ),

          /// Button
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
            decoration: BoxDecoration(
              color: buttonColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              buttonText,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
