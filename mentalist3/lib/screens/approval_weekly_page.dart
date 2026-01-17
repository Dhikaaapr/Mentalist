import 'package:flutter/material.dart';
import '../services/admin_api_services.dart';

class ApprovalWeeklyPage extends StatefulWidget {
  final dynamic counselorData;

  const ApprovalWeeklyPage({
    super.key,
    required this.counselorData,
  });

  @override
  State<ApprovalWeeklyPage> createState() => _ApprovalWeeklyPageState();
}

class _ApprovalWeeklyPageState extends State<ApprovalWeeklyPage> {
  bool showSuccess = false;
  bool isActionLoading = false;

  void _approve() async {
    setState(() => isActionLoading = true);

    final counselorId = widget.counselorData['counselor_id'];
    final result = await AdminApiService.approveWeeklySchedule(counselorId);

    if (!mounted) return;
    setState(() => isActionLoading = false);

    if (result['success'] == true) {
      setState(() => showSuccess = true);
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'] ?? 'Gagal menyetujui jadwal')),
      );
    }
  }

  void _decline() async {
    final TextEditingController reasonController = TextEditingController();
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          "Decline Request",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Are you sure you want to decline these schedules?"),
            const SizedBox(height: 12),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                hintText: "Reason (optional)",
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("No"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Yes", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      setState(() => isActionLoading = true);
      
      final counselorId = widget.counselorData['counselor_id'];
      final result = await AdminApiService.rejectWeeklySchedule(counselorId, reasonController.text);
      
      if (!mounted) return;
      setState(() => isActionLoading = false);

      if (result['success'] == true) {
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'] ?? 'Gagal menolak jadwal')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final name = widget.counselorData['counselor_name'] ?? 'Unknown';
    final schedules = widget.counselorData['schedules'] as List<dynamic>;

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
          "Weekly Approval",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
        ),
      ),

      body: Stack(
        children: [
          /// ================= MAIN CONTENT =================
          ListView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
            children: [
              const Text(
                "DETAILS",
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey),
              ),
              const SizedBox(height: 12),

              _sectionTitle("Counselor"),
              const SizedBox(height: 8),
              _card(
                Row(
                  children: [
                    const CircleAvatar(
                      radius: 28,
                      backgroundColor: Color(0xFFD1D1D1),
                      child: Icon(
                        Icons.person,
                        size: 32,
                        color: Color(0xFF3F3D7D),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              _sectionTitle("Proposed Weekly Schedule"),
              const SizedBox(height: 8),
              
              ...schedules.map((schedule) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _card(
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          schedule['day_name'] ?? '',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        Text(
                          "${schedule['start_time']} - ${schedule['end_time']}",
                          style: const TextStyle(color: Colors.black54),
                        ),
                      ],
                    ),
                  ),
                );
              }),

              const SizedBox(height: 28),

              if (!showSuccess) ...[
                if (isActionLoading)
                  const Center(child: CircularProgressIndicator())
                else ...[
                  _actionButton(
                    text: "Approve Schedule",
                    color: const Color(0xFF6A7CFF),
                    onTap: _approve,
                  ),
                  const SizedBox(height: 12),
                  _actionButton(
                    text: "Decline Schedule",
                    color: const Color(0xFF3F3D7D),
                    onTap: _decline,
                  ),
                ],
              ],
            ],
          ),

          /// ================= SUCCESS OVERLAY =================
          if (showSuccess)
            Container(
              color: Colors.black.withValues(alpha: 0.15),
              child: Center(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 36),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: const BoxDecoration(
                          color: Color(0xFFE5F5EC),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check,
                          size: 48,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "Weekly schedule for $name has been approved.",
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// ================= SMALL WIDGETS =================

  Widget _sectionTitle(String text) => Text(
    text,
    style: const TextStyle(
      fontSize: 12,
      color: Colors.black54,
      fontWeight: FontWeight.w600,
    ),
  );

  Widget _card(Widget child) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: const Color(0xFFE0E0E0),
      borderRadius: BorderRadius.circular(16),
    ),
    child: child,
  );

  Widget _actionButton({
    required String text,
    required Color color,
    required VoidCallback onTap,
  }) => SizedBox(
    width: double.infinity,
    height: 48,
    child: ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      onPressed: onTap,
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
  );
}
