import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../services/booking_api_service.dart';
import '../services/counselor_api_service.dart';

class CounselorDetailPage extends StatefulWidget {
  final Map<String, dynamic> data;

  const CounselorDetailPage({super.key, required this.data});

  @override
  State<CounselorDetailPage> createState() => _CounselorDetailPageState();
}

class _CounselorDetailPageState extends State<CounselorDetailPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  String? _selectedTime;
  String? _selectedSlotId; // Store the selected slot ID
  bool _isBooking = false;
  bool _isLoadingSlots = false;

  List<dynamic> _availableSlots = []; // Dynamic slots from API

  // Fetch slots when a day is selected
  Future<void> _fetchSlots(DateTime date) async {
    setState(() {
      _isLoadingSlots = true;
      _availableSlots = [];
      _selectedTime = null;
      _selectedSlotId = null;
    });

    try {
      final dateString = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
      final slots = await CounselorApiService.getAvailability(
        widget.data['id'],
        dateString,
      );

      if (mounted) {
        setState(() {
          _availableSlots = slots;
          _isLoadingSlots = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingSlots = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal memuat jadwal: $e")),
        );
      }
    }
  }

  Future<void> _bookConsultation() async {
    if (_selectedSlotId == null) return;

    setState(() => _isBooking = true);

    final result = await BookingApiService.createBooking(
      counselorId: widget.data['id'],
      slotId: _selectedSlotId!,
    );

    setState(() => _isBooking = false);

    if (!mounted) return;

    if (result != null && result['success'] == true) {
      // Show success dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green.shade600, size: 28),
              const SizedBox(width: 10),
              const Text("Berhasil!"),
            ],
          ),
          content: Text(
            "Booking berhasil! Konsultasi dengan ${widget.data['name']} "
            "pada ${_selectedDay!.day}/${_selectedDay!.month}/${_selectedDay!.year} "
            "jam $_selectedTime.",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Go back to counselor list
              },
              child: const Text("OK"),
            ),
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result?['message'] ?? 'Gagal membuat booking'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = const Color(0xff6b38f0);

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
          widget.data['name'] ?? 'Counselor',
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
                backgroundColor: primaryColor,
                backgroundImage: widget.data['picture'] != null
                    ? NetworkImage(widget.data['picture'])
                    : null,
                child: widget.data['picture'] == null
                    ? Text(
                        (widget.data['name'] ?? 'C')[0].toUpperCase(),
                        style:
                            const TextStyle(color: Colors.white, fontSize: 26),
                      )
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.data['name'] ?? 'Unknown',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.data['specialization'] ?? 'Konselor',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 25),

          /// ================= BIO =================
          if (widget.data['bio'] != null && widget.data['bio'].isNotEmpty) ...[
            const Text(
              "Tentang",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                widget.data['bio'],
                style: const TextStyle(fontSize: 14, height: 1.5),
              ),
            ),
            const SizedBox(height: 25),
          ],

          /// ================= CALENDAR =================
          const Text(
            "Pilih Tanggal",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),

          TableCalendar(
            focusedDay: _focusedDay,
            firstDay: DateTime.now(),
            lastDay: DateTime.now().add(const Duration(days: 60)),

            calendarFormat: CalendarFormat.month,
            availableCalendarFormats: const {CalendarFormat.month: 'Month'},

            rowHeight: 48,

            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),

            onDaySelected: (selectedDay, focusedDay) {
              if (!isSameDay(_selectedDay, selectedDay)) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
                _fetchSlots(selectedDay);
              }
            },

            headerStyle: const HeaderStyle(
              titleCentered: true,
              formatButtonVisible: false,
            ),

            calendarStyle: const CalendarStyle(
              outsideDaysVisible: false,
              isTodayHighlighted: false,
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
                    color: primaryColor,
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
            "Pilih Waktu",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),

          _isLoadingSlots
              ? const Center(child: CircularProgressIndicator())
              : _availableSlots.isEmpty
                  ? Center(
                      child: Text(
                        _selectedDay == null
                            ? "Pilih tanggal terlebih dahulu"
                            : "Tidak ada jadwal tersedia",
                        style: TextStyle(color: Colors.grey.shade500),
                      ),
                    )
                  : GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _availableSlots.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        childAspectRatio: 2.5,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemBuilder: (context, index) {
                        final slot = _availableSlots[index];
                        final time = slot['time'];
                        final id = slot['id'];
                        final isSelected = _selectedSlotId == id;

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedSlotId = id;
                              _selectedTime = time;
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? primaryColor
                                  : Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              time,
                              style: TextStyle(
                                color:
                                    isSelected ? Colors.white : Colors.black87,
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
                onPressed: (_selectedSlotId == null || _isBooking)
                    ? null
                    : _bookConsultation,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  disabledBackgroundColor: Colors.grey.shade300,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: _isBooking
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
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
          fontWeight:
              isSelected || isToday ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
    );
  }
}
