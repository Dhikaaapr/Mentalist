import 'package:flutter/material.dart';
import '../services/booking_api_service.dart';

class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key});

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  bool isLoading = true;
  String? errorMessage;
  List<Map<String, dynamic>> pendingBookings = [];

  @override
  void initState() {
    super.initState();
    _loadPendingBookings();
  }

  Future<void> _loadPendingBookings() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    final result = await BookingApiService.getBookings(status: 'pending');

    if (result != null && result['success'] == true) {
      final data = result['data'] as List;
      setState(() {
        pendingBookings =
            data.map((e) => Map<String, dynamic>.from(e)).toList();
      });
    } else {
      setState(() {
        errorMessage = result?['message'] ?? 'Gagal memuat jadwal';
      });
    }

    setState(() => isLoading = false);
  }

  Future<void> _cancelBooking(String bookingId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Batalkan Booking?"),
        content: const Text("Apakah Anda yakin ingin membatalkan booking ini?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Tidak"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text("Ya, Batalkan"),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final result = await BookingApiService.cancelBooking(bookingId);

    if (!mounted) return;

    if (result != null && result['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Booking berhasil dibatalkan"),
          backgroundColor: Colors.green,
        ),
      );
      _loadPendingBookings();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result?['message'] ?? 'Gagal membatalkan booking'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => Navigator.pop(context),
          color: Colors.black87,
        ),
        title: const Text(
          "Pending Bookings",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black87),
            onPressed: _loadPendingBookings,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
              ? _buildErrorState()
              : pendingBookings.isEmpty
                  ? _buildEmptyState()
                  : _buildBookingList(),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            errorMessage!,
            style: TextStyle(color: Colors.grey.shade600),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _loadPendingBookings,
            icon: const Icon(Icons.refresh),
            label: const Text("Coba Lagi"),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xff6b38f0),
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.hourglass_empty, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            "Tidak ada booking pending",
            style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            "Semua booking sudah dikonfirmasi atau selesai",
            style: TextStyle(color: Colors.grey.shade400, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingList() {
    return RefreshIndicator(
      onRefresh: _loadPendingBookings,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: pendingBookings.length,
        itemBuilder: (context, index) {
          return _buildBookingCard(pendingBookings[index]);
        },
      ),
    );
  }

  Widget _buildBookingCard(Map<String, dynamic> booking) {
    final primaryColor = const Color(0xff6b38f0);
    final counselor = booking['counselor'] ?? {};
    final scheduledAt = DateTime.tryParse(booking['scheduled_at'] ?? '');

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: primaryColor,
                  backgroundImage: counselor['picture'] != null
                      ? NetworkImage(counselor['picture'])
                      : null,
                  child: counselor['picture'] == null
                      ? Text(
                          (counselor['name'] ?? 'C')[0].toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        counselor['name'] ?? 'Konselor',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (scheduledAt != null)
                        Text(
                          _formatDate(scheduledAt),
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                          ),
                        ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Menunggu',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.orange,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: Colors.grey.shade200),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextButton.icon(
                    onPressed: () => _showRescheduleModal(booking),
                    icon: const Icon(Icons.schedule, size: 18),
                    label: const Text("Reschedule"),
                    style: TextButton.styleFrom(
                      foregroundColor: primaryColor,
                      minimumSize: const Size(0, 48),
                    ),
                  ),
                ),
                Container(width: 1, height: 30, color: Colors.grey.shade200),
                Expanded(
                  child: TextButton.icon(
                    onPressed: () => _cancelBooking(booking['id']),
                    icon: const Icon(Icons.close, size: 18),
                    label: const Text("Batalkan"),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.red,
                      minimumSize: const Size(0, 48),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showRescheduleModal(Map<String, dynamic> booking) {
    DateTime selectedDate = DateTime.now().add(const Duration(days: 1));
    String? selectedTime;
    final timeSlots = ['09:00', '10:00', '11:00', '14:00', '15:00', '16:00'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Pilih Jadwal Baru",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime.now().add(const Duration(days: 1)),
                    lastDate: DateTime.now().add(const Duration(days: 60)),
                  );
                  if (picked != null) {
                    setModalState(() => selectedDate = picked);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const Icon(Icons.calendar_today, size: 20),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text("Pilih Waktu",
                  style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: timeSlots.map((time) {
                  final isSelected = selectedTime == time;
                  return GestureDetector(
                    onTap: () => setModalState(() => selectedTime = time),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xff6b38f0)
                            : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(8),
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
                }).toList(),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: selectedTime == null
                      ? null
                      : () async {
                          Navigator.pop(context);
                          await _rescheduleBooking(
                            booking['id'],
                            selectedDate,
                            selectedTime!,
                          );
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff6b38f0),
                    disabledBackgroundColor: Colors.grey.shade300,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Ubah Jadwal",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _rescheduleBooking(
      String bookingId, DateTime date, String time) async {
    final timeParts = time.split(':');
    final hour = int.parse(timeParts[0]);
    final minute = int.parse(timeParts[1]);

    final newScheduledAt = DateTime(date.year, date.month, date.day, hour, minute);

    final result =
        await BookingApiService.rescheduleBooking(bookingId, newScheduledAt);

    if (!mounted) return;

    if (result != null && result['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Jadwal berhasil diubah"),
          backgroundColor: Colors.green,
        ),
      );
      _loadPendingBookings();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result?['message'] ?? 'Gagal mengubah jadwal'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  String _formatDate(DateTime date) {
    final local = date.toLocal();
    final days = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
    final dayName = days[local.weekday - 1];
    final monthName = months[local.month - 1];
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return '$dayName, ${local.day} $monthName ${local.year} • $hour:$minute';
  }
}
