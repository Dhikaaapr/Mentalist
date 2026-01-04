import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class CounselorDetailPage extends StatefulWidget {
  final Map data;

  const CounselorDetailPage({super.key, required this.data});

  @override
  State<CounselorDetailPage> createState() => _CounselorDetailPageState();
}

class _CounselorDetailPageState extends State<CounselorDetailPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  String? _selectedTime;

  final List<String> _timeSlots = [
    "09:00 AM",
    "10:00 AM",
    "11:00 AM",
    "02:00 PM",
    "03:00 PM",
    "04:00 PM",
  ];

  @override
  Widget build(BuildContext context) {
    final primaryColor = const Color.fromARGB(255, 33, 33, 228);

    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            size: 18,
            color: Colors.black87,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.data['name'],
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
      ),

      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 32),
        children: [
          /// ================= PROFILE =================
          Row(
            children: [
              CircleAvatar(
                radius: 36,
                backgroundColor: Colors.grey.shade300,
                child: Text(
                  widget.data['name'][0],
                  style: const TextStyle(color: Colors.white, fontSize: 26),
                ),
              ),
              const SizedBox(width: 16),
              Row(
                children: [
                  Icon(
                    Icons.circle,
                    size: 10,
                    color: widget.data['online'] ? Colors.green : Colors.grey,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    widget.data['online'] ? "Online" : "Offline",
                    style: TextStyle(
                      fontSize: 14,
                      color: widget.data['online'] ? Colors.green : Colors.grey,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 25),

          /// ================= SPECIALIZATION =================
          const Text(
            "Specialization",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          Text(
            widget.data['spec'] ?? "Unknown",
            style: const TextStyle(fontSize: 15),
          ),

          const SizedBox(height: 30),

          /// ================= CALENDAR =================
          const Text(
            "Select Date",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),

          TableCalendar(
            focusedDay: _focusedDay,
            firstDay: DateTime.now(),
            lastDay: DateTime.utc(2030, 12, 31),

            calendarFormat: CalendarFormat.month,
            availableCalendarFormats: const {CalendarFormat.month: 'Month'},

            rowHeight: 48,

            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),

            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
                _selectedTime = null;
              });
            },

            headerStyle: const HeaderStyle(
              titleCentered: true,
              formatButtonVisible: false,
            ),

            calendarStyle: const CalendarStyle(
              outsideDaysVisible: false,
              isTodayHighlighted: false, // 🔥 PENTING
            ),

            /// ================= CONTROL CELL RENDER =================
            calendarBuilders: CalendarBuilders(
              defaultBuilder: (context, day, focusedDay) {
                return _buildDayCell(
                  day,
                  isSelected: isSameDay(day, _selectedDay),
                  isToday: isSameDay(day, DateTime.now()),
                  primaryColor: primaryColor,
                );
              },
              selectedBuilder: (context, day, focusedDay) {
                return Container(
                  margin: const EdgeInsets.all(6),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 38, 51, 239),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${day.day}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 25),

          /// ================= TIME SLOTS =================
          const Text(
            "Select Time",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),

          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _timeSlots.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemBuilder: (context, index) {
              final time = _timeSlots[index];
              final isSelected = _selectedTime == time;

              return GestureDetector(
                onTap: _selectedDay == null
                    ? null
                    : () => setState(() => _selectedTime = time),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
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

          const SizedBox(height: 32),

          /// ================= BOOK BUTTON =================
          SafeArea(
            top: false,
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: (_selectedDay == null || _selectedTime == null)
                    ? null
                    : () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              "Session booked with ${widget.data['name']} "
                              "on ${_selectedDay!.day}/${_selectedDay!.month}/${_selectedDay!.year} "
                              "at $_selectedTime",
                            ),
                          ),
                        );
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  disabledBackgroundColor: Colors.grey.shade300,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  "Book Consultation",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// ================= DAY CELL BUILDER =================
  Widget _buildDayCell(
    DateTime day, {
    required bool isSelected,
    required bool isToday,
    required Color primaryColor,
  }) {
    Color bgColor = Colors.transparent;

    if (isSelected) {
      bgColor = primaryColor;
    } else if (isToday) {
      bgColor = primaryColor.withValues(alpha: 0.15);
    }

    return Container(
      margin: const EdgeInsets.all(6),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '${day.day}',
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.black,
          fontWeight: isSelected || isToday
              ? FontWeight.w600
              : FontWeight.normal,
        ),
      ),
    );
  }
}
