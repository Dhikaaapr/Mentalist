import 'package:flutter/material.dart';
import 'approval_doctor_page.dart';
import 'approval_weekly_page.dart';
import '../services/admin_api_services.dart';
import '../utils/logger.dart';

class ScheduleApprovalCounselors extends StatefulWidget {
  const ScheduleApprovalCounselors({super.key});

  @override
  State<ScheduleApprovalCounselors> createState() =>
      _ScheduleApprovalCounselorsState();
}

class _ScheduleApprovalCounselorsState
    extends State<ScheduleApprovalCounselors> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool isLoading = true;
  List<dynamic> schedules = [];
  List<dynamic> weeklySchedules = []; // This will hold grouped counselor schedules
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadAllSchedules();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAllSchedules() async {
    if (!mounted) return;
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final results = await Future.wait([
        AdminApiService.getPendingSchedules(),
        AdminApiService.getPendingWeeklyAvailability(),
      ]);
      
      if (!mounted) return;

      if (results[0]['success'] == true && results[1]['success'] == true) {
        setState(() {
          schedules = results[0]['data'] ?? [];
          weeklySchedules = results[1]['data'] ?? [];
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Gagal memuat beberapa data';
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
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF3F3D7D),
          unselectedLabelColor: Colors.grey,
          indicatorColor: const Color(0xFF3F3D7D),
          tabs: const [
            Tab(text: "One-time"),
            Tab(text: "Weekly"),
          ],
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
        ),
      ),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildOneTimeList(schedules),
                _buildWeeklyList(weeklySchedules),
              ],
            ),
    );
  }

  Widget _buildOneTimeList(List<dynamic> items) {
    if (items.isEmpty) {
      return _emptyState("No approval request");
    }

    return RefreshIndicator(
      onRefresh: _loadAllSchedules,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
        children: [
          const Text(
            "ONE-TIME REQUESTS",
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 12),

          ...List.generate(items.length, (index) {
            final item = items[index];
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
                        isWeekly: false,
                      ),
                    ),
                  );

                  if (result == true) {
                    _loadAllSchedules();
                  }
                },
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildWeeklyList(List<dynamic> items) {
    if (items.isEmpty) {
      return _emptyState("No weekly approval request");
    }

    return RefreshIndicator(
      onRefresh: _loadAllSchedules,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
        children: [
          const Text(
            "WEEKLY RECURRING",
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 12),

          ...List.generate(items.length, (index) {
            final item = items[index]; // Grouped by counselor
            final schedules = item['schedules'] as List<dynamic>;
            final dayCount = schedules.length;
            
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _ScheduleItem(
                name: item['counselor_name'] ?? 'Unknown',
                time: "$dayCount days selected",
                date: "Pending Approval",
                onView: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ApprovalWeeklyPage(
                        counselorData: item,
                      ),
                    ),
                  );

                  if (result == true) {
                    _loadAllSchedules();
                  }
                },
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _emptyState(String text) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(text, style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: _loadAllSchedules,
            child: const Text('Refresh'),
          ),
        ],
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
