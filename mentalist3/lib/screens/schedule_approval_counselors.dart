import 'package:flutter/material.dart';
import 'approval_doctor_page.dart';
import '../services/admin_api_services.dart';
import '../utils/logger.dart';

class ScheduleApprovalCounselors extends StatefulWidget {
  const ScheduleApprovalCounselors({super.key});

  @override
  State<ScheduleApprovalCounselors> createState() =>
      _ScheduleApprovalCounselorsState();
}

class _ScheduleApprovalCounselorsState
    extends State<ScheduleApprovalCounselors> {
  bool isLoading = true;
  List<dynamic> schedules = [];
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadSchedules();
  }

  Future<void> _loadSchedules() async {
    if (!mounted) return;
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final result = await AdminApiService.getPendingSchedules();
      if (!mounted) return;

      if (result['success'] == true) {
        setState(() {
          schedules = result['data'] ?? [];
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = result['message'] ?? 'Gagal memuat data';
          isLoading = false;
        });
      }
    } catch (e) {
      AppLogger.error('[SCHEDULE_APPROVAL] Error: $e');
      if (mounted) {
        setState(() {
          errorMessage = 'Kesalahan jaringan';
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFFE5E5E5),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Schedule Approval",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
        ),
      ),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : schedules.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "No approval request",
                        style: TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: _loadSchedules,
                        child: const Text('Refresh'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadSchedules,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
                    children: [
                      const Text(
                        "PENDING REQUESTS",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 12),

                      ...List.generate(schedules.length, (index) {
                        final item = schedules[index];
                        final counselor = item['counselor'] ?? {};
                        
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _ScheduleItem(
                            name: counselor['name'] ?? 'Unknown',
                            time: "${item['start_time']} - ${item['end_time']}",
                            date: item['scheduled_date'] ?? '',
                            onView: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ApprovalDoctorPage(
                                    scheduleData: item,
                                  ),
                                ),
                              );

                              if (result == true) {
                                _loadSchedules();
                              }
                            },
                          ),
                        );
                      }),
                    ],
                  ),
                ),
    );
  }
}

/// ================= ITEM CARD =================
class _ScheduleItem extends StatelessWidget {
  final String name;
  final String time;
  final String date;
  final VoidCallback onView;

  const _ScheduleItem({
    required this.name,
    required this.time,
    required this.date,
    required this.onView,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFE0E0E0),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 22,
            backgroundColor: Color(0xFF3F3D7D),
            child: Icon(Icons.person, color: Colors.white),
          ),
          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "$date | $time",
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ],
            ),
          ),

          SizedBox(
            height: 30,
            child: ElevatedButton(
              onPressed: onView,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3F3D7D),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 0,
                ),
              ),
              child: const Text(
                "View",
                style: TextStyle(fontSize: 12, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
