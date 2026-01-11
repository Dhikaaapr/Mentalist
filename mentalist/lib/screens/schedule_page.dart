import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../services/booking_api_service.dart';
import 'package:intl/intl.dart';

class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key});

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  List<dynamic> _confirmedBookings = [];
  bool _isLoading = true;

  List<dynamic> get _filteredBookings {
    if (_selectedDay == null) {
      // If no day selected, show bookings for focused day (today) or all?
      // User said "sesuai tanggal", so likely only for the selected date.
      // Defaulting to focusedDay (today) if nothing selected.
      return _confirmedBookings.where((booking) {
        final scheduledAt = DateTime.parse(booking['scheduled_at']).toLocal();
        return isSameDay(scheduledAt, _focusedDay);
      }).toList();
    }
    return _confirmedBookings.where((booking) {
      final scheduledAt = DateTime.parse(booking['scheduled_at']).toLocal();
      return isSameDay(scheduledAt, _selectedDay);
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay; // Initialize selected day to today
    _fetchConfirmedBookings();
  }

  Future<void> _fetchConfirmedBookings() async {
    setState(() => _isLoading = true);
    try {
      final result = await BookingApiService.getBookings(status: 'confirmed');
      if (result != null && result['success'] == true) {
        setState(() {
          _confirmedBookings = result['data'] ?? [];
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = const Color(0xFF6366F1);
    final filteredList = _filteredBookings;

    return Scaffold(
      backgroundColor: Colors.white,
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
                    "Select a date to view sessions",
                    style: TextStyle(fontSize: 15, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            /// === CALENDAR FIXED HEIGHT ===
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              height: 350,
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
                "Confirmed Sessions",
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
              ),
            ),

            const SizedBox(height: 6),

            /// LIST DIBUAT SCROLLABLE
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : filteredList.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.event_busy, size: 50, color: Colors.grey.shade300),
                              const SizedBox(height: 10),
                              Text(
                                "No sessions on this date",
                                style: TextStyle(color: Colors.grey.shade500),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          itemCount: filteredList.length,
                          itemBuilder: (context, index) {
                            final session = filteredList[index];
                            final scheduledAt = DateTime.parse(session['scheduled_at']).toLocal();
                            
                            return Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.05),
                                    blurRadius: 6,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: primaryColor.withValues(alpha: 0.1),
                                  child: Icon(Icons.event_available, color: primaryColor),
                                ),
                                title: Text(
                                  session['counselor']['name'] ?? 'Counselor',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text(
                                  DateFormat('h:mm a').format(scheduledAt),
                                  style: TextStyle(color: Colors.grey.shade600),
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
}
