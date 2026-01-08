import 'package:flutter/material.dart';
import '../services/booking_api_service.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  bool isLoading = true;
  String? errorMessage;
  List<Map<String, dynamic>> completedBookings = [];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    final result = await BookingApiService.getBookings();

    if (result != null && result['success'] == true) {
      final data = result['data'] as List;
      setState(() {
        // Only show completed, cancelled, rejected
        completedBookings = data
            .map((e) => Map<String, dynamic>.from(e))
            .where((b) =>
                b['status'] == 'completed' ||
                b['status'] == 'cancelled' ||
                b['status'] == 'rejected')
            .toList();
      });
    } else {
      setState(() {
        errorMessage = result?['message'] ?? 'Gagal memuat riwayat';
      });
    }

    setState(() => isLoading = false);
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
          icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "History",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.black),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black87),
            onPressed: _loadHistory,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
              ? _buildErrorState()
              : completedBookings.isEmpty
                  ? _buildEmptyState()
                  : _buildHistoryList(),
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
            onPressed: _loadHistory,
            icon: const Icon(Icons.refresh),
            label: const Text("Coba Lagi"),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF5A2FC8),
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
          Icon(Icons.history, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            "Belum ada riwayat sesi",
            style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryList() {
    return RefreshIndicator(
      onRefresh: _loadHistory,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: completedBookings.length,
        itemBuilder: (context, index) {
          return _buildHistoryCard(completedBookings[index]);
        },
      ),
    );
  }

  Widget _buildHistoryCard(Map<String, dynamic> booking) {
    final user = booking['user'] ?? {};
    final status = booking['status'] ?? '';
    final scheduledAt = DateTime.tryParse(booking['scheduled_at'] ?? '');

    Color statusColor;
    String statusText;
    IconData statusIcon;

    switch (status) {
      case 'completed':
        statusColor = Colors.green;
        statusText = 'Selesai';
        statusIcon = Icons.check_circle;
        break;
      case 'cancelled':
        statusColor = Colors.grey;
        statusText = 'Dibatalkan';
        statusIcon = Icons.cancel;
        break;
      case 'rejected':
        statusColor = Colors.red;
        statusText = 'Ditolak';
        statusIcon = Icons.block;
        break;
      default:
        statusColor = Colors.grey;
        statusText = status;
        statusIcon = Icons.info;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: const Color(0xFF5A2FC8),
            backgroundImage:
                user['picture'] != null ? NetworkImage(user['picture']) : null,
            child: user['picture'] == null
                ? Text(
                    (user['name'] ?? 'U')[0].toUpperCase(),
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18),
                  )
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user['name'] ?? 'User',
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 15),
                ),
                const SizedBox(height: 4),
                if (scheduledAt != null)
                  Text(
                    _formatDate(scheduledAt),
                    style:
                        TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Icon(statusIcon, size: 20, color: statusColor),
              const SizedBox(height: 4),
              Text(
                statusText,
                style: TextStyle(
                  color: statusColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
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
