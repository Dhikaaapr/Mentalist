import 'package:flutter/material.dart';
import 'chatroom_page.dart';
import '../services/chat_api_service.dart';

class ChatListPage extends StatefulWidget {
  const ChatListPage({super.key});

  @override
  State<ChatListPage> createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  List<dynamic> chats = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadChats();
  }

  Future<void> _loadChats() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final result = await ChatApiService.getChatList();

      if (result['success'] == true) {
        setState(() {
          chats = result['data'] ?? [];
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = result['message'] ?? 'Gagal memuat chat';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Terjadi kesalahan';
        isLoading = false;
      });
    }
  }

  String _formatTime(String? dateStr) {
    if (dateStr == null) return '';
    try {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      final diff = now.difference(date);

      if (diff.inDays == 0) {
        return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
      } else if (diff.inDays == 1) {
        return 'Kemarin';
      } else if (diff.inDays < 7) {
        const days = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
        return days[date.weekday - 1];
      } else {
        return '${date.day}/${date.month}/${date.year}';
      }
    } catch (e) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Chat",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: const Color.fromARGB(255, 110, 16, 183),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(errorMessage!, style: const TextStyle(color: Colors.grey)),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadChats,
                        child: const Text("Coba Lagi"),
                      ),
                    ],
                  ),
                )
              : chats.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.chat_bubble_outline_rounded,
                            size: 80,
                            color: Colors.grey.shade300,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "Belum ada chat",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Chat akan muncul saat ada booking dikonfirmasi",
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade400,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadChats,
                      child: ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: chats.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final chat = chats[index];
                          final otherUser = chat['other_user'] ?? {};
                          final lastMessage = chat['last_message'];
                          final unreadCount = chat['unread_count'] ?? 0;

                          return GestureDetector(
                            onTap: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ChatRoomPage(
                                    bookingId: chat['booking_id'].toString(),
                                    clientName: otherUser['name'] ?? 'Unknown',
                                    clientPicture: otherUser['picture'],
                                  ),
                                ),
                              );
                              _loadChats();
                            },
                            child: Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: Colors.grey.shade200),
                              ),
                              child: Row(
                                children: [
                                  // Avatar
                                  CircleAvatar(
                                    radius: 26,
                                    backgroundColor: const Color.fromARGB(255, 110, 16, 183),
                                    backgroundImage: otherUser['picture'] != null
                                        ? NetworkImage(otherUser['picture'])
                                        : null,
                                    child: otherUser['picture'] == null
                                        ? Text(
                                            (otherUser['name'] ?? 'U')[0].toUpperCase(),
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18,
                                            ),
                                          )
                                        : null,
                                  ),
                                  const SizedBox(width: 14),

                                  // Name & Last Message
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          otherUser['name'] ?? 'Unknown',
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: unreadCount > 0
                                                ? FontWeight.bold
                                                : FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          lastMessage != null
                                              ? (lastMessage['is_mine'] == true
                                                  ? 'Anda: ${lastMessage['content']}'
                                                  : lastMessage['content'])
                                              : 'Belum ada pesan',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: unreadCount > 0
                                                ? Colors.black87
                                                : Colors.grey.shade600,
                                            fontWeight: unreadCount > 0
                                                ? FontWeight.w500
                                                : FontWeight.normal,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Time & Unread Badge
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        lastMessage != null
                                            ? _formatTime(lastMessage['created_at'])
                                            : '',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: unreadCount > 0
                                              ? const Color.fromARGB(255, 110, 16, 183)
                                              : Colors.grey.shade500,
                                        ),
                                      ),
                                      if (unreadCount > 0) ...[
                                        const SizedBox(height: 6),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: const Color.fromARGB(255, 110, 16, 183),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            unreadCount > 99 ? '99+' : '$unreadCount',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
}
