import 'package:flutter/material.dart';

class CounselingSessionPage extends StatefulWidget {
  const CounselingSessionPage({super.key});

  @override
  State<CounselingSessionPage> createState() => _CounselingSessionPageState();
}

class _CounselingSessionPageState extends State<CounselingSessionPage> {
  int selectedTab = 0;

  // 🔧 ADDED — state khusus RESCHEDULE (TIDAK GANGGU CANCEL)
  DateTime _selectedDate = DateTime.now();
  String _selectedTime = "08 : 00   —   10 : 00";
  String _selectedReason = "Emergency";

  final List<String> _reasonOptions = [
    "Emergency",
    "Schedule Conflict",
    "Client Request",
    "Others",
  ];

  final List<String> _timeSlots = [
    "08 : 00   —   10 : 00",
    "11 : 00   —   13 : 00",
    "14 : 00   —   17 : 00",
  ];

  final List<Map<String, dynamic>> sessions = [
    {
      "name": "Dr. Emily Chen",
      "date": "Nov 22, 2025",
      "time": "2:00 PM",
      "online": true,
    },
    {
      "name": "Dr. Michael Roberts",
      "date": "Nov 25, 2025",
      "time": "12:00 PM",
      "online": true,
    },
    {
      "name": "Dr. Jana Rohima",
      "date": "Nov 27, 2025",
      "time": "10:00 PM",
      "online": false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        title: const Text("Counseling Session"),
      ),
      backgroundColor: const Color(0xfff5f7fb),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [_tabButton("Upcoming", 0), _tabButton("Completed", 1)],
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: sessions.length,
              itemBuilder: (_, i) => _sessionCard(sessions[i]),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff5565FF),
                minimumSize: const Size(double.infinity, 52),
              ),
              onPressed: () {},
              child: const Text("Book New Session"),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tabButton(String text, int index) {
    final active = selectedTab == index;
    return GestureDetector(
      onTap: () => setState(() => selectedTab = index),
      child: Container(
        padding: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: active ? const Color(0xff5565FF) : Colors.transparent,
              width: 3,
            ),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: active ? const Color(0xff5565FF) : Colors.grey,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  void _showRescheduleBottomDialog(String name) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                  child: Text(
                    "Reschedule Session",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xff5565FF),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                /// ================= DATE =================
                const Text(
                  "Date",
                  style: TextStyle(fontSize: 13, color: Colors.grey),
                ),
                const SizedBox(height: 6),

                // 🔧 CHANGED — sekarang bisa di-tap & pilih tanggal
                GestureDetector(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2030),
                    );
                    if (picked != null) {
                      setState(() => _selectedDate = picked);
                    }
                  },
                  child: _inputBox(
                    icon: Icons.calendar_today,
                    text:
                        "${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}",
                  ),
                ),

                const SizedBox(height: 12),

                /// ================= TIME =================
                const Text(
                  "Time",
                  style: TextStyle(fontSize: 13, color: Colors.grey),
                ),
                const SizedBox(height: 6),

                // 🔧 CHANGED — dropdown slot waktu
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedTime,
                      isExpanded: true,
                      items: _timeSlots
                          .map(
                            (e) => DropdownMenuItem(value: e, child: Text(e)),
                          )
                          .toList(),
                      onChanged: (val) {
                        setState(() => _selectedTime = val!);
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                /// REASON (TIDAK DIUBAH)
                const Text(
                  "Reasons",
                  style: TextStyle(fontSize: 13, color: Colors.grey),
                ),
                const SizedBox(height: 6),

                StatefulBuilder(
                  builder: (context, setLocalState) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedReason,
                          isExpanded: true,
                          items: _reasonOptions
                              .map(
                                (e) =>
                                    DropdownMenuItem(value: e, child: Text(e)),
                              )
                              .toList(),
                          onChanged: (val) {
                            setLocalState(() {
                              _selectedReason = val!;
                            });
                          },
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 20),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Cancel"),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xff5565FF),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                          _showConfirmReschedulePopup(name);
                        },
                        child: const Text("Reschedule"),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ================= SEMUA CODE DI BAWAH INI TIDAK DIUBAH =================
  // (confirm, cancel, success, dll tetap sama persis dengan punya kamu)

  void _showConfirmReschedulePopup(String name) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Confirm Rescheduling",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xff5565FF),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "You are about to reschedule this counseling session with $name.\n\nAre you sure you want to reschedule this session?",
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Back"),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff5565FF),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        _showSuccessDialog(context);
                      },
                      child: const Text("Yes, Reschedule Session"),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCancelSessionDialog(String name) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Text(
                  "Cancel Counseling Session",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xff5565FF),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              const Text(
                "Name",
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),
              const SizedBox(height: 6),
              _readonlyBox(name),

              const SizedBox(height: 12),

              const Text(
                "Date & Time",
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),
              const SizedBox(height: 6),
              _readonlyBox("Monday, Nov 17 (08:00 - 10:00)"),

              const SizedBox(height: 12),

              /// REASON (FIXED)
              const Text(
                "Reasons",
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),
              const SizedBox(height: 6),

              StatefulBuilder(
                builder: (context, setLocalState) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedReason,
                        isExpanded: true,
                        items: _reasonOptions
                            .map(
                              (e) => DropdownMenuItem(value: e, child: Text(e)),
                            )
                            .toList(),
                        onChanged: (val) {
                          setLocalState(() {
                            _selectedReason = val!;
                          });
                        },
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 12),

              const Text(
                "Notes to Client (optional)",
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),
              const SizedBox(height: 6),
              _textArea(),

              const SizedBox(height: 14),

              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 44,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xff5565FF)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          "Cancel",
                          style: TextStyle(
                            color: Color(0xff5565FF),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 44,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                          _showConfirmCancelPopup(name);
                        },
                        child: const Text(
                          "Confirm Cancellation",
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showConfirmCancelPopup(String name) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Confirm Cancellation",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xff5565FF),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "Are you sure you want to cancel session with $name?\n\nThe client will be notified immediately.",
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13, color: Colors.black87),
              ),
              const SizedBox(height: 24),

              // 🔴 Primary Button
              SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    _showCancelSuccessOptionDialog(name);
                  },
                  child: const Text(
                    "Yes, Cancel Session",
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // 🔵 Secondary Button
              SizedBox(
                width: double.infinity,
                height: 44,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xff5565FF)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    "Back",
                    style: TextStyle(
                      color: Color(0xff5565FF),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCancelSuccessOptionDialog(String name) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ✅ Success Icon
              Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 36),
              ),

              const SizedBox(height: 20),

              // ✅ Main Text
              Text(
                "The session with $name has been cancelled successfully.",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 8),

              // ✅ Subtitle
              const Text(
                "Would you like to reschedule this session?",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),

              const SizedBox(height: 24),

              // ✅ Primary Button (Top)
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff5565FF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    _showRescheduleBottomDialog(name);
                  },
                  child: const Text(
                    "Yes, Reschedule Session",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // ✅ Secondary Button (Bottom)
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    side: const BorderSide(color: Color(0xff5565FF)),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    "No, Keep it canceled",
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xff5565FF),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _readonlyBox(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(child: Text(text)),
          const Icon(Icons.lock, size: 16, color: Colors.grey),
        ],
      ),
    );
  }

  Widget _textArea() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const TextField(
        maxLines: 3,
        decoration: InputDecoration(
          hintText: "Write a message to client",
          border: InputBorder.none,
        ),
      ),
    );
  }

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: Colors.green,
                  child: Icon(Icons.check, color: Colors.white, size: 36),
                ),
                SizedBox(height: 20),
                Text(
                  "The session with Nathalia has been rescheduled successfully.",
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _inputBox({required IconData icon, required String text}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey),
          const SizedBox(width: 10),
          Expanded(child: Text(text)),
          const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
        ],
      ),
    );
  }

  Widget _sessionCard(Map data) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(radius: 24, backgroundColor: Colors.grey),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data["name"],
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.circle,
                          size: 10,
                          color: data["online"] ? Colors.green : Colors.grey,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          data["online"] ? "Online" : "Offline",
                          style: TextStyle(fontSize: 13, color: Colors.grey),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(Icons.more_horiz, color: Colors.grey.shade600),
            ],
          ),

          const SizedBox(height: 14),

          Row(
            children: [
              const Icon(Icons.calendar_month, size: 18, color: Colors.grey),
              const SizedBox(width: 8),
              Text(data["date"], style: const TextStyle(fontSize: 14)),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.access_time, size: 18, color: Colors.grey),
              const SizedBox(width: 8),
              Text(data["time"], style: const TextStyle(fontSize: 14)),
            ],
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff5565FF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: () => _showCancelSessionDialog(data["name"]),

                  child: const Text("Cancel Session"),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey.shade300,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: () => _showRescheduleBottomDialog(data["name"]),

                  child: const Text(
                    "Reschedule",
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
