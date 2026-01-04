import 'package:flutter/material.dart';

class ApprovalDoctorPage extends StatefulWidget {
  final String name;
  final String date;
  final String time;

  const ApprovalDoctorPage({
    super.key,
    required this.name,
    required this.date,
    required this.time,
  });

  @override
  State<ApprovalDoctorPage> createState() => _ApprovalDoctorPageState();
}

class _ApprovalDoctorPageState extends State<ApprovalDoctorPage> {
  bool showSuccess = false;

  void _approve() async {
    setState(() => showSuccess = true);

    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    Navigator.pop(context, true); // ⬅️ kirim status approved
  }

  @override
  Widget build(BuildContext context) {
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
          "Approval",
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
                "TODAY",
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),

              _sectionTitle("Personal Information"),
              const SizedBox(height: 8),
              _card(
                Column(
                  children: [
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
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.name,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              "ID : 12345",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Divider(),
                    _infoRow("Full Name", "Adi Wijaya S.Psi"),
                    _infoRow("Date", "March 15, 1999"),
                    _infoRow("Email", "adiwijaya@gmail.com"),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              _sectionTitle("Spesialis Type"),
              const SizedBox(height: 8),
              _card(
                Row(
                  children: const [
                    Icon(Icons.add, color: Color(0xFF3F3D7D)),
                    SizedBox(width: 10),
                    Text("Counseling Psychology"),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              _sectionTitle("Date Schedule"),
              const SizedBox(height: 8),
              _card(
                Row(
                  children: [
                    const Icon(Icons.calendar_month, color: Color(0xFF3F3D7D)),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.date),
                        Text(
                          widget.time,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              if (!showSuccess) ...[
                _actionButton(
                  text: "Approve",
                  color: const Color(0xFF6A7CFF),
                  onTap: _approve,
                ),
                const SizedBox(height: 12),
                _actionButton(
                  text: "Decline",
                  color: const Color(0xFF3F3D7D),
                  onTap: _decline,
                ),
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
                        "The request with ${widget.name} has been Approval successfully.",
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

  void _decline() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          "Decline Request",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text("Are you sure you want to decline this schedule?"),
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
      Navigator.pop(context, false); // ⬅️ kirim status DECLINE
    }
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
      borderRadius: BorderRadius.circular(20),
    ),
    child: child,
  );

  Widget _infoRow(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 12, color: Colors.black54),
          ),
        ),
        Expanded(child: Text(value, style: const TextStyle(fontSize: 12))),
      ],
    ),
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
