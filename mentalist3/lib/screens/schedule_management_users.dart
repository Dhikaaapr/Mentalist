import 'package:flutter/material.dart';

class ScheduleManagementUsers extends StatefulWidget {
  const ScheduleManagementUsers({super.key});

  @override
  State<ScheduleManagementUsers> createState() =>
      _ScheduleManagementUsersState();
}

class _ScheduleManagementUsersState extends State<ScheduleManagementUsers> {
  List<String> names = ["Tami", "Angga", "Putri", "Dina", "Bella", "Zahra"];

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
          "Schedule management users",
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _statsRow(),

          const SizedBox(height: 20),
          const Text(
            "Schedule request",
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 15),

          Expanded(
            child: names.isEmpty
                ? const Center(child: Text("No pending schedule"))
                : ListView.builder(
                    itemCount: names.length,
                    itemBuilder: (_, i) => _card(names[i], i),
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
        _miniStat("15", "Total users"),
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
            backgroundColor: Color.fromARGB(255, 110, 16, 183),
            child: Icon(Icons.person, color: Colors.white),
          ),
          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                const Text("Nov 5,2025", style: TextStyle(fontSize: 12)),
                const Text("12.00 - 13.00", style: TextStyle(fontSize: 12)),
              ],
            ),
          ),

          _statusButton("Approve", Colors.green, () {
            _showPopup(name, index);
          }),
          const SizedBox(width: 5),
          _statusButton("Reject", Colors.red, () {
            setState(() => names.removeAt(index));
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

  // POPUP MODERN
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

              Text("$name request has been approved."),
              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  setState(() {
                    approvedToday++;
                    names.removeAt(index);
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
