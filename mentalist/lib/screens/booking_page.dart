import 'package:flutter/material.dart';

class BookingPage extends StatefulWidget {
  final String counselorName;

  const BookingPage({super.key, required this.counselorName});

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  void pickDate() async {
    DateTime? date = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
      initialDate: DateTime.now(),
    );

    if (date != null) {
      setState(() => selectedDate = date);
    }
  }

  void pickTime() async {
    TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (time != null) {
      setState(() => selectedTime = time);
    }
  }

  void submitBooking() {
    if (selectedDate == null || selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Pilih tanggal dan waktu sesi terlebih dahulu!"),
        ),
      );
      return;
    }

    Navigator.pop(context, {
      "counselor": widget.counselorName,
      "date":
          "${selectedDate!.year}-${selectedDate!.month}-${selectedDate!.day}",
      "time": selectedTime!.format(context),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Booking Sesi"),
        backgroundColor: Colors.pinkAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 10),
            Text(
              "Booking dengan ${widget.counselorName}",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 25),

            ListTile(
              leading: const Icon(Icons.calendar_month),
              title: const Text("Pilih Tanggal"),
              subtitle: Text(
                selectedDate == null
                    ? "Belum Dipilih"
                    : "${selectedDate!.day}-${selectedDate!.month}-${selectedDate!.year}",
              ),
              onTap: pickDate,
            ),

            ListTile(
              leading: const Icon(Icons.access_time),
              title: const Text("Pilih Waktu"),
              subtitle: Text(
                selectedTime == null
                    ? "Belum Dipilih"
                    : selectedTime!.format(context),
              ),
              onTap: pickTime,
            ),

            const Spacer(),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pinkAccent,
                minimumSize: const Size(double.infinity, 50),
              ),
              onPressed: submitBooking,
              child: const Text(
                "Konfirmasi Booking",
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
