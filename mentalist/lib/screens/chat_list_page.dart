import 'package:flutter/material.dart';
import 'chat_room_page.dart';

class ChatListPage extends StatelessWidget {
  const ChatListPage({super.key});

  final List<Map<String, String>> chats = const [
    {"name": "Dr. Ratna", "last": "Bagaimana perasaanmu hari ini?"},
    {"name": "Budi Putra", "last": "Siap untuk sesi besok?"},
    {"name": "Sinta", "last": "Baik, saya lihat jadwal dulu ya."},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5f7fb),
      appBar: AppBar(
        title: const Text("Chat List"),
        backgroundColor: Colors.pinkAccent,
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: chats.map((c) {
          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 2,
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.pinkAccent,
                child: Text(
                  c['name']![0],
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              title: Text(c['name']!),
              subtitle: Text(c['last']!),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ChatRoomPage(counselorName: c['name']!),
                  ),
                );
              },
            ),
          );
        }).toList(),
      ),
    );
  }
}
