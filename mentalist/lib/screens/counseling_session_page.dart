import 'package:flutter/material.dart';

class CounselingSessionPage extends StatefulWidget {
  const CounselingSessionPage({super.key});

  @override
  State<CounselingSessionPage> createState() => _CounselingSessionPageState();
}

class _CounselingSessionPageState extends State<CounselingSessionPage> {
  int selectedTab = 0;

  final List<Map<String, dynamic>> sessions = [
    {
      "name": "Dr. Emily Chen",
      "date": "Nov 22, 2025",
      "time": "2:00 PM",
      "online": true,
    },
    {
      "name": "Dr. Michael Roberts",
      "date": "Nov 25, 2025",
      "time": "12:00 PM",
      "online": true,
    },
    {
      "name": "Dr. Jana Rohima",
      "date": "Nov 27, 2025",
      "time": "10:00 PM",
      "online": false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        title: const Text("Counseling Session"),
      ),
      backgroundColor: const Color(0xfff5f7fb),

      body: Column(
        children: [
          /// TAB HEADER
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [_tabButton("Upcoming", 0), _tabButton("Completed", 1)],
          ),

          const SizedBox(height: 10),

          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: sessions.length,
              itemBuilder: (_, i) => _sessionCard(sessions[i]),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff5565FF),
                minimumSize: const Size(double.infinity, 52),
              ),
              onPressed: () {},
              child: const Text(
                "Book New Session",
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tabButton(String text, int index) {
    final active = selectedTab == index;
    return GestureDetector(
      onTap: () => setState(() => selectedTab = index),
      child: Container(
        padding: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: active ? const Color(0xff5565FF) : Colors.transparent,
              width: 3,
            ),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: active ? const Color(0xff5565FF) : Colors.grey,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget _sessionCard(Map data) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(radius: 24, backgroundColor: Colors.grey),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data["name"],
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.circle,
                          size: 10,
                          color: data["online"] ? Colors.green : Colors.grey,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          data["online"] ? "Online" : "Offline",
                          style: TextStyle(fontSize: 13, color: Colors.grey),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(Icons.more_horiz, color: Colors.grey.shade600),
            ],
          ),

          const SizedBox(height: 14),

          Row(
            children: [
              const Icon(Icons.calendar_month, size: 18, color: Colors.grey),
              const SizedBox(width: 8),
              Text(data["date"], style: const TextStyle(fontSize: 14)),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.access_time, size: 18, color: Colors.grey),
              const SizedBox(width: 8),
              Text(data["time"], style: const TextStyle(fontSize: 14)),
            ],
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff5565FF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: () {},
                  child: const Text("Join Session"),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey.shade300,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: () {},
                  child: const Text(
                    "Reschedule",
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
