import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/admin_api_services.dart';
import '../utils/logger.dart';
import 'schedule_approval_counselors.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  bool isLoading = true;
  List<dynamic> notifications = [];
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    if (!mounted) return;
    
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final result = await AdminApiService.getNotifications();
      
      if (!mounted) return;

      if (result['success'] == true) {
        setState(() {
          notifications = result['data'] ?? [];
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = result['message'] ?? 'Gagal memuat notifikasi';
          isLoading = false;
        });
      }
    } catch (e) {
      AppLogger.error('[NOTIFICATION_PAGE] Error: $e');
      if (mounted) {
        setState(() {
          errorMessage = 'Terjadi kesalahan jaringan';
          isLoading = false;
        });
      }
    }
  }

  Future<void> _markAsRead(String id, int index) async {
    final result = await AdminApiService.markNotificationAsRead(id);
    if (result['success'] == true) {
      setState(() {
        notifications.removeAt(index);
      });
    }
  }

  String _formatTime(String? timeStr) {
    if (timeStr == null) return "Unknown";
    try {
      final date = DateTime.parse(timeStr);
      return DateFormat('hh:mm a').format(date);
    } catch (e) {
      return timeStr;
    }
  }

  String _getTimeAgo(String? timeStr) {
    if (timeStr == null) return "";
    try {
      final date = DateTime.parse(timeStr);
      final diff = DateTime.now().difference(date);
      if (diff.inMinutes < 60) return "${diff.inMinutes}m ago";
      if (diff.inHours < 24) return "${diff.inHours}h ago";
      return "${diff.inDays}d ago";
    } catch (e) {
      return "just now";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            /// ================= HEADER =================
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 18),
              decoration: const BoxDecoration(
                color: Color(0xFFE5E5E5),
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
              ),
              child: const Center(
                child: Text(
                  "Notifications",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
            ),

            const SizedBox(height: 16),

            /// ================= LIST NOTIFICATION =================
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : errorMessage != null
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(errorMessage!),
                              const SizedBox(height: 8),
                              ElevatedButton(
                                onPressed: _loadNotifications,
                                child: const Text('Reload'),
                              ),
                            ],
                          ),
                        )
                      : notifications.isEmpty
                          ? const Center(
                              child: Text(
                                "No new notifications",
                                style: TextStyle(color: Colors.grey),
                              ),
                            )
                          : RefreshIndicator(
                              onRefresh: _loadNotifications,
                              child: ListView.builder(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                itemCount: notifications.length,
                                itemBuilder: (context, index) {
                                  final item = notifications[index];
                                  final data = item['data'] ?? {};
                                  final isUnread = item['read_at'] == null;

                                  return Dismissible(
                                    key: Key(item['id']),
                                    direction: DismissDirection.endToStart,
                                    background: Container(
                                      alignment: Alignment.centerRight,
                                      padding: const EdgeInsets.only(right: 20),
                                      decoration: BoxDecoration(
                                        color: Colors.red.shade400,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: const Icon(Icons.delete, color: Colors.white),
                                    ),
                                    onDismissed: (direction) {
                                      _markAsRead(item['id'], index);
                                    },
                                    child: GestureDetector(
                                      onTap: () {
                                        if (data['type'] == 'approval_request') {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => const ScheduleApprovalCounselors(),
                                            ),
                                          );
                                        }
                                      },
                                      child: Container(
                                        margin: const EdgeInsets.only(bottom: 12),
                                        padding: const EdgeInsets.all(14),
                                        decoration: BoxDecoration(
                                          color: isUnread ? const Color(0xFFF3E5F5) : const Color(0xFFF2F2F2),
                                          borderRadius: BorderRadius.circular(20),
                                          border: isUnread ? Border.all(color: const Color(0xFF3F3D7D).withValues(alpha: 0.3)) : null,
                                        ),
                                        child: Row(
                                          children: [
                                            CircleAvatar(
                                              radius: 22,
                                              backgroundColor: isUnread ? const Color(0xFF3F3D7D) : Colors.grey,
                                              child: const Icon(Icons.notifications_active, color: Colors.white, size: 20),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    data['title'] ?? "Notification",
                                                    style: TextStyle(
                                                      fontWeight: isUnread ? FontWeight.bold : FontWeight.normal,
                                                      fontSize: 13,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 2),
                                                  Text(
                                                    data['subtitle'] ?? "",
                                                    style: const TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.black54,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.end,
                                              children: [
                                                Text(
                                                  _getTimeAgo(item['created_at']),
                                                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                                                ),
                                                const SizedBox(height: 6),
                                                Text(
                                                  _formatTime(item['created_at']),
                                                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
            ),

            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
