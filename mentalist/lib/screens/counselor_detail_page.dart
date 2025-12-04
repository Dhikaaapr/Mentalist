import 'package:flutter/material.dart';
import 'booking_page.dart';
import 'schedule_page.dart';

class CounselorDetailPage extends StatelessWidget {
  final Map data;

  const CounselorDetailPage({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
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
          data['name'],
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Section
            Row(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.grey.shade300,
                  child: Text(
                    data['name'][0],
                    style: const TextStyle(color: Colors.white, fontSize: 28),
                  ),
                ),
                const SizedBox(width: 18),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data['name'],
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          Icons.circle,
                          size: 12,
                          color: data['online'] ? Colors.green : Colors.grey,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          data['online'] ? "Online" : "Offline",
                          style: TextStyle(
                            fontSize: 14,
                            color: data['online'] ? Colors.green : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 25),

            // Specialist / Role
            const Text(
              "Specialization",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            Text(
              data['spec'] ?? "Unknown",
              style: const TextStyle(fontSize: 15),
            ),

            const SizedBox(height: 25),

            // About section
            const Text(
              "About Counselor",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              data['desc'] ?? "No description available.",
              style: const TextStyle(fontSize: 14),
            ),

            const Spacer(),

            // Button: Booking
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pinkAccent,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: () async {
                  final bookingResult = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BookingPage(counselorName: data['name']),
                    ),
                  );

                  if (!context.mounted) return;

                  if (bookingResult != null) {
                    SchedulePage.sessions.add(bookingResult);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Session successfully booked!"),
                      ),
                    );
                  }
                },
                child: const Text(
                  "Book Consultation",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
