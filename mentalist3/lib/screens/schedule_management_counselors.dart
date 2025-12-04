import 'package:flutter/material.dart';

class ScheduleManagementCounselors extends StatefulWidget {
  const ScheduleManagementCounselors({super.key});

  @override
  State<ScheduleManagementCounselors> createState() =>
      _ScheduleManagementCounselorsState();
}

class _ScheduleManagementCounselorsState
    extends State<ScheduleManagementCounselors> {
  List<String> counselors = [
    "Dr. Adi",
    "Dr. Rudi",
    "Dr. Budi",
    "Dr. Gina",
    "Dr. Intan",
    "Dr. Mia",
  ];

  int approvedToday = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back, color: Colors.black),
        ),
        title: const Text(
          "Schedule management counselors",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: _content(),
    );
  }

  Widget _content() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _statsRow(),
          const SizedBox(height: 20),

          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Schedule request",
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 15),

          Expanded(
            child: counselors.isEmpty
                ? const Center(child: Text("No pending schedule"))
                : ListView.builder(
                    itemCount: counselors.length,
                    itemBuilder: (_, i) => _card(counselors[i], i),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _statsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _miniStat("$approvedToday", "Approved today"),
        _miniStat("6", "Total counselors"),
      ],
    );
  }

  Widget _miniStat(String number, String label) {
    return Container(
      width: 130,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFD9D9D9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            number,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 5),
          Text(label, textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _card(String name, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFD9D9D9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: Colors.deepPurple,
            child: Icon(Icons.person, color: Colors.white),
          ),
          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name, // <-- nama ditampilkan
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),

                const Text("Nov 5, 2025", style: TextStyle(fontSize: 12)),
                const Text("12.00 - 13.00", style: TextStyle(fontSize: 12)),
              ],
            ),
          ),

          _statusButton("Approve", Colors.green, () {
            _showPopup(name, index);
          }),
          const SizedBox(width: 5),
          _statusButton("Reject", Colors.red, () {
            setState(() => counselors.removeAt(index));
          }),
        ],
      ),
    );
  }

  Widget _statusButton(String text, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          text,
          style: const TextStyle(color: Colors.white, fontSize: 11),
        ),
      ),
    );
  }

  void _showPopup(String name, int index) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(25),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  size: 45,
                  color: Colors.green,
                ),
              ),

              const SizedBox(height: 15),

              const Text(
                "Approved!",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 10),

              Text("$name's schedule has been approved."),
              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  setState(() {
                    approvedToday++;
                    counselors.removeAt(index);
                  });
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                child: const Text("OK", style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
