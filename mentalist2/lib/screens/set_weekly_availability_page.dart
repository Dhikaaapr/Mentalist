import 'package:flutter/material.dart';
import 'counselor_dashboard.dart';

class SetWeeklyAvailabilityPage extends StatefulWidget {
  final String counselorId;
  final String counselorName;
  final String counselorEmail;

  const SetWeeklyAvailabilityPage({
    super.key,
    required this.counselorId,
    required this.counselorName,
    required this.counselorEmail,
  });

  @override
  State<SetWeeklyAvailabilityPage> createState() =>
      _SetWeeklyAvailabilityPageState();
}

class _SetWeeklyAvailabilityPageState extends State<SetWeeklyAvailabilityPage> {
  final List<String> days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

  final Map<String, bool> selectedDays = {
    'Sun': false,
    'Mon': true,
    'Tue': false,
    'Wed': false,
    'Thu': false,
    'Fri': false,
    'Sat': false,
  };

  final Map<String, bool> timeSlots = {
    '08:00 — 10:00': true,
    '11:00 — 13:00': true,
    '14:00 — 17:00': true,
    '19:00 — 20:00': true,
  };

  bool repeatWeekly = true;

  void _saveSchedule() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => CounselorDashboardPage(
          counselorName: widget.counselorName,
          counselorEmail: widget.counselorEmail,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            /// ================= CONTENT (SCROLLABLE) =================
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 140),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// ===== TITLE (CENTERED, TIDAK MEPET) =====
                  Center(
                    child: Column(
                      children: const [
                        SizedBox(height: 16),
                        Text(
                          'Set Weekly Availability',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Select your regular working days and hours each week',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 13, color: Colors.black54),
                        ),
                        SizedBox(height: 32),
                      ],
                    ),
                  ),

                  /// ===== DAYS PICKER =====
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF5A2FC8),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: days.map((day) {
                        final isSelected = selectedDays[day]!;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedDays[day] = !isSelected;
                            });
                          },
                          child: Column(
                            children: [
                              Text(
                                day,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white.withValues(alpha: 0.9),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.white.withValues(alpha: 0.25),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: isSelected
                                    ? const Icon(
                                        Icons.check,
                                        size: 18,
                                        color: Color(0xFF5A2FC8),
                                      )
                                    : null,
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  const SizedBox(height: 32),

                  /// ===== WORKING HOURS =====
                  const Text(
                    'Set Working Hours',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Clients can book during your set hours each week',
                    style: TextStyle(fontSize: 13, color: Colors.black54),
                  ),

                  const SizedBox(height: 16),

                  ...timeSlots.keys.map((time) {
                    final active = timeSlots[time]!;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: active
                            ? const Color(0xFFEAE6F8)
                            : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(time, style: const TextStyle(fontSize: 14)),
                          Switch(
                            value: active,
                            onChanged: (val) {
                              setState(() => timeSlots[time] = val);
                            },
                            activeThumbColor: const Color(0xFF5A2FC8),
                            inactiveTrackColor: Colors.grey.shade400,
                          ),
                        ],
                      ),
                    );
                  }),

                  const SizedBox(height: 12),

                  /// ===== REPEAT WEEKLY =====
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF5A2FC8),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Repeat Weekly',
                          style: TextStyle(color: Colors.white),
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              repeatWeekly = !repeatWeekly;
                            });
                          },
                          child: Container(
                            width: 26,
                            height: 26,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: repeatWeekly
                                ? const Icon(
                                    Icons.check,
                                    size: 18,
                                    color: Color(0xFF5A2FC8),
                                  )
                                : null,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            /// ================= BOTTOM BUTTON (FIXED) =================
            Positioned(
              left: 24,
              right: 24,
              bottom: 24,
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveSchedule,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6A2FF8),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(22),
                    ),
                  ),
                  child: const Text(
                    'Save & Go to Dashboard',
                    style: TextStyle(color: Colors.white, fontSize: 15),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
