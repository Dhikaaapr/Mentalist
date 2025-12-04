import 'package:flutter/material.dart';

class UserListPage extends StatefulWidget {
  const UserListPage({super.key});

  @override
  State<UserListPage> createState() => _UserListPageState();
}

class _UserListPageState extends State<UserListPage> {
  List<Map<String, dynamic>> users = [
    {"name": "Tami", "email": "google@gmail.com", "active": true},
    {"name": "Angga", "email": "google@gmail.com", "active": true},
    {"name": "Naila", "email": "google@gmail.com", "active": false},
    {"name": "Dina", "email": "google@gmail.com", "active": true},
    {"name": "Bella", "email": "google@gmail.com", "active": true},
    {"name": "Zahra", "email": "google@gmail.com", "active": false},
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
          "Users manage",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Users list",
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: users.length,
                itemBuilder: (context, index) {
                  return _userCard(
                    users[index]["name"],
                    users[index]["email"],
                    users[index]["active"],
                    (value) {
                      setState(() {
                        users[index]["active"] = value;
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
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
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
