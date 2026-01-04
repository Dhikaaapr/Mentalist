import 'package:flutter/material.dart';
import 'approval_doctor_page.dart';

class ScheduleApprovalCounselors extends StatefulWidget {
  const ScheduleApprovalCounselors({super.key});

  @override
  State<ScheduleApprovalCounselors> createState() =>
      _ScheduleApprovalCounselorsState();
}

class _ScheduleApprovalCounselorsState
    extends State<ScheduleApprovalCounselors> {
  /// DATA LIST (MUTABLE → BISA DIHAPUS SETELAH APPROVE)
  final List<Map<String, String>> schedules = [
    {"name": "Dr. Adi", "time": "14.00 - 17.00", "date": "Monday, Nov 3, 2025"},
    {
      "name": "Dr. Rudi",
      "time": "18.00 - 20.00",
      "date": "Monday, Nov 3, 2025",
    },
    {
      "name": "Dr. Budi",
      "time": "08.00 - 10.00",
      "date": "Monday, Nov 3, 2025",
    },
    {
      "name": "Dr. Gina",
      "time": "11.00 - 13.00",
      "date": "Monday, Nov 3, 2025",
    },
  ];

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
          "Schedule Approval Counselors",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
        ),
      ),

      body: schedules.isEmpty
          ? const Center(
              child: Text(
                "No approval request",
                style: TextStyle(color: Colors.grey),
              ),
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
              children: [
                const Text(
                  "TODAY",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  "Monday, Nov 3",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),

                ...List.generate(schedules.length, (index) {
                  final item = schedules[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _ScheduleItem(
                      name: item["name"]!,
                      time: item["time"]!,
                      onView: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ApprovalDoctorPage(
                              name: item["name"]!,
                              date: item["date"]!,
                              time: item["time"]!,
                            ),
                          ),
                        );

                        /// JIKA APPROVE = TURE → HAPUS DARI LIST
                        if (result == true || result == false) {
                          setState(() {
                            schedules.removeAt(index);
                          });
                        }
                      },
                    ),
                  );
                }),
              ],
            ),
    );
  }
}

/// ================= ITEM CARD =================
class _ScheduleItem extends StatelessWidget {
  final String name;
  final String time;
  final VoidCallback onView;

  const _ScheduleItem({
    required this.name,
    required this.time,
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
                  time,
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
