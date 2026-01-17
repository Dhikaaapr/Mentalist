import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../services/booking_api_service.dart';

class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key});

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  List<dynamic> _allBookings = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    _fetchBookings();
  }

  Future<void> _fetchBookings() async {
    try {
      final result = await BookingApiService.getBookings(status: 'confirmed');
      if (result != null && result['success'] == true) {
        if (mounted) {
          setState(() {
            _allBookings = result['data'] ?? [];
            _isLoading = false;
          });
        }
      } else {
        if (mounted) setState(() => _isLoading = false);
      }
    } catch (e) {
      debugPrint("Error fetching bookings: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<dynamic> _getSessionsForDay(DateTime day) {
    return _allBookings.where((booking) {
      final scheduledAt = DateTime.parse(booking['scheduled_at']).toLocal();
      return isSameDay(scheduledAt, day);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = const Color(0xFF6366F1);
    final sessions = _selectedDay == null ? [] : _getSessionsForDay(_selectedDay!);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            /// HEADER & BOX INFO
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                          "Your Schedule",
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),

                  /// CALENDAR FIXED HEIGHT
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    height: 310, 
                    child: TableCalendar(
                      focusedDay: _focusedDay,
                      firstDay: DateTime.utc(2010, 1, 1),
                      lastDay: DateTime.utc(2030, 1, 1),
                      rowHeight: 40,
                      headerVisible: true,
                      availableGestures: AvailableGestures.all,
                      selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                      eventLoader: _getSessionsForDay, 
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

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    child: Text(
                      _selectedDay == null 
                          ? "Select a date" 
                          : "Sessions on ${DateFormat('EEE, d MMM').format(_selectedDay!)}",
                      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),

            /// SESSIONS LIST
            if (_isLoading)
               const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (sessions.isEmpty)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.event_busy, size: 40, color: Colors.grey),
                      SizedBox(height: 10),
                      Text(
                        "No sessions for this date",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final booking = sessions[index];
                      final date = DateTime.parse(booking['scheduled_at']).toLocal();
                      final timeStr = DateFormat('h:mm a').format(date);
                      final counselorName = booking['counselor']?['name'] ?? 'Counselor';

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
                            backgroundColor: Colors.blue.shade50,
                            child: Icon(Icons.person, color: primaryColor),
                          ),
                          title: Text(counselorName, style: const TextStyle(fontWeight: FontWeight.w600)),
                          subtitle: Text(
                            "Status: ${booking['status'].toString().toUpperCase()} • $timeStr",
                            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                          ),
                          trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
                        ),
                      );
                    },
                    childCount: sessions.length,
                  ),
                ),
              ),
            
            const SliverToBoxAdapter(child: SizedBox(height: 20)),
          ],
        ),
      ),
    );
  }
}

                
