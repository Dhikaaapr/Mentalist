import 'package:flutter/material.dart';

class CounselorListPage extends StatefulWidget {
  const CounselorListPage({super.key});

  @override
  State<CounselorListPage> createState() => _CounselorListPageState();
}

class _CounselorListPageState extends State<CounselorListPage> {
  List<Map<String, dynamic>> counselors = [
    {"name": "Dr. Adi", "email": "google@gmail.com", "active": true},
    {"name": "Dr. Rudi", "email": "google@gmail.com", "active": true},
    {"name": "Dr. Budi", "email": "google@gmail.com", "active": false},
    {"name": "Dr. Gina", "email": "google@gmail.com", "active": true},
    {"name": "Dr. Intan", "email": "google@gmail.com", "active": false},
    {"name": "Dr. Mia", "email": "google@gmail.com", "active": true},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back, color: Colors.black),
        ),
        centerTitle: true,
        title: const Text(
          "Counselors manage",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Counselors list",
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: counselors.length,
                itemBuilder: (context, index) {
                  return _userCard(
                    counselors[index]["name"],
                    counselors[index]["email"],
                    counselors[index]["active"],
                    (value) {
                      setState(() {
                        counselors[index]["active"] = value;
                      });
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _userCard(
    String name,
    String email,
    bool active,
    Function(bool) onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: const Color(0xFFD9D9D9),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const CircleAvatar(
            radius: 28,
            backgroundColor: Color(0xFFE0E0E0),
            child: Icon(Icons.person, size: 32, color: Color(0xFF6A1B9A)),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                  ),
                ),
                const SizedBox(height: 2),
                Text(email, style: const TextStyle(fontSize: 13)),
              ],
            ),
          ),

          const SizedBox(width: 5),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: active ? Colors.green : Colors.red,
              borderRadius: BorderRadius.circular(50),
            ),
            child: Text(
              active ? "Active" : "Inactive",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(width: 10),

          Switch(
            value: active,
            onChanged: onChanged,
            activeThumbColor: const Color(0xFF6A1B9A),
            activeTrackColor: const Color(0xFF6A1B9A).withValues(alpha: 0.4),
          ),
        ],
      ),
    );
  }
}
