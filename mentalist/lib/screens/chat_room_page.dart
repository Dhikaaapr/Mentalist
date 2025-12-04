import 'package:flutter/material.dart';

class ChatRoomPage extends StatefulWidget {
  final String counselorName;

  const ChatRoomPage({super.key, required this.counselorName});

  @override
  State<ChatRoomPage> createState() => _ChatRoomPageState();
}

class _ChatRoomPageState extends State<ChatRoomPage> {
  final TextEditingController _chatController = TextEditingController();

  final List<Map<String, dynamic>> messages = [
    {
      "fromUser": false,
      "text": "Halo, bagaimana perasaanmu hari ini?",
      "time": "09:00",
    },
    {
      "fromUser": true,
      "text": "Saya merasa agak cemas belakangan ini.",
      "time": "09:01",
    },
    {
      "fromUser": false,
      "text": "Baik, bisa ceritakan lebih detail apa yang membuatmu cemas?",
      "time": "09:02",
    },
  ];

  void sendMessage() {
    final text = _chatController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      messages.add({"fromUser": true, "text": text, "time": "Now"});
    });

    _chatController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5f7fb),
      appBar: AppBar(
        backgroundColor: Colors.pinkAccent,
        elevation: 1,
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                widget.counselorName[0],
                style: const TextStyle(color: Colors.pinkAccent),
              ),
            ),
            const SizedBox(width: 10),
            Text(widget.counselorName),
          ],
        ),
      ),

      body: Column(
        children: [
          // ======= CHAT LIST =======
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];
                bool fromUser = msg["fromUser"] == true;

                return Align(
                  alignment: fromUser
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding: const EdgeInsets.all(12),
                    constraints: const BoxConstraints(maxWidth: 250),
                    decoration: BoxDecoration(
                      color: fromUser
                          ? Colors.pinkAccent
                          : Colors.grey.shade300,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(fromUser ? 16 : 0),
                        topRight: Radius.circular(fromUser ? 0 : 16),
                        bottomLeft: const Radius.circular(16),
                        bottomRight: const Radius.circular(16),
                      ),
                    ),
                    child: Text(
                      msg["text"],
                      style: TextStyle(
                        color: fromUser ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // ======= INPUT AREA =======
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  blurRadius: 4,
                  offset: const Offset(0, -1),
                  color: Colors.black.withValues(alpha: 0.05),
                ),
              ],
            ),

            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _chatController,
                    decoration: InputDecoration(
                      hintText: "Ketik pesan...",
                      fillColor: Colors.grey.shade100,
                      filled: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                GestureDetector(
                  onTap: sendMessage,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                      color: Colors.pinkAccent,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.send,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
