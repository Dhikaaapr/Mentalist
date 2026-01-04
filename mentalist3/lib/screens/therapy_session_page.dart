import 'package:flutter/material.dart';

class TherapySessionPage extends StatelessWidget {
  const TherapySessionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // ================= APP BAR =================
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Color.fromARGB(197, 229, 225, 225),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Therapy Session",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
        ),
      ),

      // ================= BODY =================
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Last Month",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 12),

            Expanded(
              child: ListView(
                children: const [
                  TherapySessionItem(
                    name: "Tami",
                    time: "14:00 - 17:00",
                    status: SessionStatus.ongoing,
                  ),
                  TherapySessionItem(
                    name: "Angga",
                    time: "09:00 - 12:00",
                    status: SessionStatus.ongoing,
                  ),
                  TherapySessionItem(
                    name: "Putri",
                    time: "08:00 - 10:00",
                    status: SessionStatus.upcoming,
                  ),
                  TherapySessionItem(
                    name: "Dino",
                    time: "11:00 - 13:00",
                    status: SessionStatus.completed,
                  ),
                  TherapySessionItem(
                    name: "Tina",
                    time: "08:00 - 10:00",
                    status: SessionStatus.completed,
                  ),
                  TherapySessionItem(
                    name: "Michael",
                    time: "11:00 - 13:00",
                    status: SessionStatus.upcoming,
                  ),
                  TherapySessionItem(
                    name: "Timothy",
                    time: "14:00 - 17:00",
                    status: SessionStatus.upcoming,
                  ),
                  TherapySessionItem(
                    name: "Natasha",
                    time: "08:00 - 10:00",
                    status: SessionStatus.ongoing,
                  ),
                  TherapySessionItem(
                    name: "Giselle",
                    time: "11:00 - 13:00",
                    status: SessionStatus.completed,
                  ),
                  TherapySessionItem(
                    name: "Rayhan",
                    time: "14:00 - 17:00",
                    status: SessionStatus.upcoming,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ================= MODEL =================

enum SessionStatus { upcoming, ongoing, completed }

// ================= ITEM CARD =================

class TherapySessionItem extends StatelessWidget {
  final String name;
  final String time;
  final SessionStatus status;

  const TherapySessionItem({
    super.key,
    required this.name,
    required this.time,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color.fromARGB(223, 220, 214, 214),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.13),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 42,
            height: 42,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color.fromARGB(172, 109, 0, 235),
            ),
            child: const Icon(
              Icons.person,
              color: Color.fromARGB(255, 247, 246, 246),
            ),
          ),

          const SizedBox(width: 12),

          // Name & Time
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  time,
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ],
            ),
          ),

          _statusChip(),
        ],
      ),
    );
  }

  Widget _statusChip() {
    Color color;
    String text;

    switch (status) {
      case SessionStatus.upcoming:
        color = const Color.fromARGB(255, 81, 0, 161);
        text = "Upcoming";
        break;
      case SessionStatus.ongoing:
        color = const Color.fromARGB(255, 12, 3, 195);
        text = "Ongoing";
        break;
      case SessionStatus.completed:
        color = const Color.fromARGB(255, 0, 137, 5);
        text = "Completed";
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 80), // 🔥 FIX UTAMA
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: const Color.fromARGB(255, 253, 255, 253),

          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
