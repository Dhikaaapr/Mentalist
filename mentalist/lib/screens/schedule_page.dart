import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key});

  static List<Map<String, String>> sessions = [];

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    final primaryColor = const Color(0xFF6366F1);

    return Scaffold(
      backgroundColor: Colors.white,

      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(18),
        child: ElevatedButton(
          onPressed: _selectedDay == null ? null : () => _showTimeSelector(),
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            disabledBackgroundColor: Colors.grey.shade300,
            minimumSize: const Size(double.infinity, 55),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text(
            "Continue",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
        ),
      ),

      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// HEADER
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back, size: 22),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    "Schedule Booking",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),

            /// BOX INFO
            Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xfff6f6fa),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.calendar_today, color: primaryColor, size: 20),
                  const SizedBox(width: 10),
                  Text(
                    "Select date & time",
                    style: TextStyle(fontSize: 15, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            /// === CALENDAR FIXED HEIGHT ===
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              height: 350, // FIX OVERFLOW
              child: TableCalendar(
                focusedDay: _focusedDay,
                firstDay: DateTime.utc(2010, 1, 1),
                lastDay: DateTime.utc(2030, 1, 1),
                rowHeight: 44,
                headerVisible: true,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                },
                calendarStyle: CalendarStyle(
                  isTodayHighlighted: true,
                  outsideDaysVisible: false,
                  selectedDecoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  todayDecoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: primaryColor, width: 1.5),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            /// TITLE
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 18),
              child: Text(
                "Upcoming Sessions",
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
              ),
            ),

            const SizedBox(height: 6),

            /// LIST DIBUAT SCROLLABLE
            Expanded(
              child: SchedulePage.sessions.isEmpty
                  ? const Center(
                      child: Text(
                        "No upcoming sessions",
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      itemCount: SchedulePage.sessions.length,
                      itemBuilder: (context, index) {
                        final session = SchedulePage.sessions[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: -.05),
                                blurRadius: 6,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: ListTile(
                            leading: Icon(Icons.event, color: primaryColor),
                            title: Text(session["counselor"]!),
                            subtitle: Text(
                              "${session['date']} • ${session['time']}",
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  /// Bottom Sheet
  void _showTimeSelector() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return TimeSelector(
          date: _selectedDay!,
          onConfirm: (String time) {
            SchedulePage.sessions.add({
              "counselor": "Counseling Session",
              "date":
                  "${_selectedDay!.day}/${_selectedDay!.month}/${_selectedDay!.year}",
              "time": time,
            });

            setState(() {});
            Navigator.pop(context);
          },
        );
      },
    );
  }
}

/// =========================
/// TIME SELECTOR WIDGET
/// =========================

class TimeSelector extends StatefulWidget {
  final DateTime date;
  final Function(String) onConfirm;

  const TimeSelector({super.key, required this.date, required this.onConfirm});

  @override
  State<TimeSelector> createState() => _TimeSelectorState();
}

class _TimeSelectorState extends State<TimeSelector> {
  String? selectedTime;

  final List<String> timeSlots = [
    "09:00 AM",
    "10:00 AM",
    "11:00 AM",
    "02:00 PM",
    "03:00 PM",
    "04:00 PM",
  ];

  @override
  Widget build(BuildContext context) {
    final primaryColor = const Color(0xFF6366F1);

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 25,
          bottom: 35 + MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: const Text(
                "Select Time",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ),

            const SizedBox(height: 20),

            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: timeSlots.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 3,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
              ),
              itemBuilder: (context, index) {
                final time = timeSlots[index];
                final isSelected = selectedTime == time;

                return GestureDetector(
                  onTap: () => setState(() => selectedTime = time),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isSelected ? primaryColor : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      time,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 30),

            ElevatedButton(
              onPressed: selectedTime == null
                  ? null
                  : () => widget.onConfirm(selectedTime!),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                disabledBackgroundColor: Colors.grey.shade400,
                minimumSize: const Size(double.infinity, 55),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                "Confirm Booking",
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
