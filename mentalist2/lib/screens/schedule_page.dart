import 'package:flutter/material.dart';
import '../services/booking_api_service.dart';

class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key});

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool isLoading = true;
  String? errorMessage;
  List<Map<String, dynamic>> allBookings = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadBookings();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadBookings() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    final result = await BookingApiService.getBookings();

    if (result != null && result['success'] == true) {
      final data = result['data'] as List;
      setState(() {
        allBookings = data.map((e) => Map<String, dynamic>.from(e)).toList();
      });
    } else {
      setState(() {
        errorMessage = result?['message'] ?? 'Gagal memuat booking';
      });
    }

    setState(() => isLoading = false);
  }

  List<Map<String, dynamic>> _filterByStatus(List<String> statuses) {
    return allBookings.where((b) => statuses.contains(b['status'])).toList();
  }

  int _countByStatus(List<String> statuses) {
    return allBookings.where((b) => statuses.contains(b['status'])).length;
  }

  Future<void> _confirmBooking(String id) async {
    final result = await BookingApiService.confirmBooking(id);
    if (!mounted) return;

    if (result != null && result['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Booking dikonfirmasi"), backgroundColor: Colors.green),
      );
      _loadBookings();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result?['message'] ?? 'Gagal'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _rejectBooking(String id) async {
    final reason = await _showRejectDialog();
    if (reason == null) return;

    final result = await BookingApiService.rejectBooking(id, reason: reason);
    if (!mounted) return;

    if (result != null && result['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Booking ditolak"), backgroundColor: Colors.orange),
      );
      _loadBookings();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result?['message'] ?? 'Gagal'), backgroundColor: Colors.red),
      );
    }
  }

  Future<String?> _showRejectDialog() async {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Tolak Booking?"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: "Alasan (opsional)",
            border: OutlineInputBorder(),
          ),
          maxLines: 2,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Tolak", style: TextStyle(color: Colors.white)),
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
            left: 20, right: 20, top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Pilih Jadwal Baru",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              InkWell(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime.now().add(const Duration(days: 1)),
                    lastDate: DateTime.now().add(const Duration(days: 60)),
                  );
                  if (picked != null) setModalState(() => selectedDate = picked);
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
                      Text('${selectedDate.day}/${selectedDate.month}/${selectedDate.year}'),
                      const Icon(Icons.calendar_today, size: 20),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text("Pilih Waktu", style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: timeSlots.map((time) {
                  final isSelected = selectedTime == time;
                  return GestureDetector(
                    onTap: () => setModalState(() => selectedTime = time),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF5A2FC8) : Colors.grey.shade200,
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
                          await _rescheduleBooking(booking['id'], selectedDate, selectedTime!);
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5A2FC8),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text("Ubah Jadwal", style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _rescheduleBooking(String id, DateTime date, String time) async {
    final timeParts = time.split(':');
    final newScheduledAt = DateTime(date.year, date.month, date.day,
        int.parse(timeParts[0]), int.parse(timeParts[1]));

    final result = await BookingApiService.rescheduleBooking(id, newScheduledAt);
    if (!mounted) return;

    if (result != null && result['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Jadwal diubah"), backgroundColor: Colors.green),
      );
      _loadBookings();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result?['message'] ?? 'Gagal'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _completeBooking(String id) async {
    final result = await BookingApiService.completeBooking(id);
    if (!mounted) return;

    if (result != null && result['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Sesi selesai"), backgroundColor: Colors.green),
      );
      _loadBookings();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result?['message'] ?? 'Gagal'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = const Color(0xFF5A2FC8);
    final pendingCount = _countByStatus(['pending']);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Schedule", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.black)),
        actions: [
          IconButton(icon: const Icon(Icons.refresh, color: Colors.black87), onPressed: _loadBookings),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: primaryColor,
          unselectedLabelColor: Colors.grey,
          indicatorColor: primaryColor,
          tabs: [
            Tab(child: Row(mainAxisSize: MainAxisSize.min, children: [
              const Text("Requests"),
              if (pendingCount > 0) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(10)),
                  child: Text('$pendingCount', style: const TextStyle(color: Colors.white, fontSize: 12)),
                ),
              ],
            ])),
            const Tab(text: "Upcoming"),
            const Tab(text: "Completed"),
          ],
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
              ? _buildErrorState()
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildRequestList(_filterByStatus(['pending'])),
                    _buildUpcomingList(_filterByStatus(['confirmed'])),
                    _buildCompletedList(_filterByStatus(['completed', 'cancelled', 'rejected'])),
                  ],
                ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(errorMessage!, style: TextStyle(color: Colors.grey.shade600)),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _loadBookings,
            icon: const Icon(Icons.refresh),
            label: const Text("Coba Lagi"),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestList(List<Map<String, dynamic>> bookings) {
    if (bookings.isEmpty) {
      return _buildEmptyState("Tidak ada request baru", Icons.inbox);
    }
    return RefreshIndicator(
      onRefresh: _loadBookings,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: bookings.length,
        itemBuilder: (_, i) => _buildRequestCard(bookings[i]),
      ),
    );
  }

  Widget _buildUpcomingList(List<Map<String, dynamic>> bookings) {
    if (bookings.isEmpty) {
      return _buildEmptyState("Tidak ada sesi mendatang", Icons.event);
    }
    return RefreshIndicator(
      onRefresh: _loadBookings,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: bookings.length,
        itemBuilder: (_, i) => _buildUpcomingCard(bookings[i]),
      ),
    );
  }

  Widget _buildCompletedList(List<Map<String, dynamic>> bookings) {
    if (bookings.isEmpty) {
      return _buildEmptyState("Belum ada riwayat", Icons.history);
    }
    return RefreshIndicator(
      onRefresh: _loadBookings,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: bookings.length,
        itemBuilder: (_, i) => _buildHistoryCard(bookings[i]),
      ),
    );
  }

  Widget _buildEmptyState(String message, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(message, style: TextStyle(color: Colors.grey.shade600)),
        ],
      ),
    );
  }

  Widget _buildRequestCard(Map<String, dynamic> booking) {
    final user = booking['user'] ?? {};
    final scheduledAt = DateTime.tryParse(booking['scheduled_at'] ?? '');

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF5A2FC8),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: Colors.white,
                backgroundImage: user['picture'] != null ? NetworkImage(user['picture']) : null,
                child: user['picture'] == null
                    ? Text((user['name'] ?? 'U')[0], style: const TextStyle(color: Color(0xFF5A2FC8), fontWeight: FontWeight.bold))
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(user['name'] ?? 'User', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16)),
                    const SizedBox(height: 4),
                    if (scheduledAt != null)
                      Text(_formatDate(scheduledAt), style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 13)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _confirmBooking(booking['id']),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text("Accept", style: TextStyle(color: Color(0xFF5A2FC8))),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _rejectBooking(booking['id']),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.white),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text("Decline", style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingCard(Map<String, dynamic> booking) {
    final user = booking['user'] ?? {};
    final scheduledAt = DateTime.tryParse(booking['scheduled_at'] ?? '');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green.shade200),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)],
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: const Color(0xFF5A2FC8),
                backgroundImage: user['picture'] != null ? NetworkImage(user['picture']) : null,
                child: user['picture'] == null
                    ? Text((user['name'] ?? 'U')[0], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(user['name'] ?? 'User', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                    if (scheduledAt != null)
                      Text(_formatDate(scheduledAt), style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: Colors.green.shade100, borderRadius: BorderRadius.circular(8)),
                child: const Text("Confirmed", style: TextStyle(color: Colors.green, fontSize: 11, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _showRescheduleModal(booking),
                  icon: const Icon(Icons.schedule, size: 16),
                  label: const Text("Reschedule"),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF5A2FC8),
                    side: const BorderSide(color: Color(0xFF5A2FC8)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _completeBooking(booking['id']),
                  icon: const Icon(Icons.check, size: 16),
                  label: const Text("Complete"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(Map<String, dynamic> booking) {
    final user = booking['user'] ?? {};
    final status = booking['status'] ?? '';
    final scheduledAt = DateTime.tryParse(booking['scheduled_at'] ?? '');

    Color statusColor;
    String statusText;
    switch (status) {
      case 'completed': statusColor = Colors.blue; statusText = 'Selesai'; break;
      case 'cancelled': statusColor = Colors.grey; statusText = 'Dibatalkan'; break;
      case 'rejected': statusColor = Colors.red; statusText = 'Ditolak'; break;
      default: statusColor = Colors.grey; statusText = status;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: const Color(0xFF5A2FC8),
            child: Text((user['name'] ?? 'U')[0], style: const TextStyle(color: Colors.white)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user['name'] ?? 'User', style: const TextStyle(fontWeight: FontWeight.w600)),
                if (scheduledAt != null)
                  Text(_formatDate(scheduledAt), style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
            child: Text(statusText, style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final local = date.toLocal();
    final days = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
    return '${days[local.weekday - 1]}, ${local.day} ${months[local.month - 1]} ${local.year} • ${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
  }
}
