import 'package:flutter/material.dart';
import '../services/admin_api_services.dart';

class TherapySessionPage extends StatefulWidget {
  const TherapySessionPage({super.key});

  @override
  State<TherapySessionPage> createState() => _TherapySessionPageState();
}

class _TherapySessionPageState extends State<TherapySessionPage> {
  bool _isLoading = true;
  List<dynamic> _sessions = [];
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadSessions();
  }

  Future<void> _loadSessions() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    final result = await AdminApiService.getTherapySessions();

    if (result['success'] == true) {
      if (mounted) {
        setState(() {
          _sessions = result['bookings'] ?? [];
          _isLoading = false;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          _errorMessage = result['message'] ?? 'Gagal memuat data';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // ================= APP BAR =================
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color.fromARGB(197, 229, 225, 225),
        automaticallyImplyLeading: false, // Part of bottom nav
        title: const Text(
          "Therapy Session",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black),
            onPressed: _loadSessions,
          ),
        ],
      ),

      // ================= BODY =================
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_errorMessage),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: _loadSessions,
                        child: const Text('Coba Lagi'),
                      ),
                    ],
                  ),
                )
              : _sessions.isEmpty
                  ? const Center(child: Text("Belum ada sesi terapi"))
                  : Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "All Sessions",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.black54,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Expanded(
                            child: ListView.builder(
                              itemCount: _sessions.length,
                              itemBuilder: (context, index) {
                                final session = _sessions[index];
                                return TherapySessionItem(session: session);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
    );
  }
}

// ================= ITEM CARD =================

class TherapySessionItem extends StatelessWidget {
  final Map<String, dynamic> session;

  const TherapySessionItem({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    final user = session['user'] ?? {};
    final counselor = session['counselor'] ?? {};
    final status = session['status'] ?? 'pending';
    final time = "${session['booking_time'] ?? '-'}";
    final date = "${session['booking_date'] ?? '-'}";

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color.fromARGB(223, 220, 214, 214),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.13),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Avatar User
              CircleAvatar(
                radius: 21,
                backgroundColor: const Color.fromARGB(172, 109, 0, 235),
                backgroundImage: user['picture'] != null
                    ? NetworkImage(user['picture'])
                    : null,
                child: user['picture'] == null
                    ? const Icon(Icons.person, color: Colors.white)
                    : null,
              ),

              const SizedBox(width: 12),

              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${user['name'] ?? 'User'} ➡ ${counselor['name'] ?? 'Counselor'}",
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "$date • $time",
                      style: const TextStyle(fontSize: 12, color: Colors.black54),
                    ),
                  ],
                ),
              ),

              _statusChip(status),
            ],
          ),
          
          if (session['meeting_link'] != null) ...[
             const SizedBox(height: 8),
             Align(
               alignment: Alignment.centerLeft,
               child: Text('Link: ${session['meeting_link']}', style: TextStyle(fontSize: 10, color: Colors.blue)),
             ) 
          ]
        ],
      ),
    );
  }

  Widget _statusChip(String status) {
    Color color;
    String text;

    switch (status) {
      case 'confirmed':
        color = const Color.fromARGB(255, 81, 0, 161);
        text = "Upcoming";
        break;
      case 'ongoing':
        color = const Color.fromARGB(255, 12, 3, 195);
        text = "Ongoing";
        break;
      case 'completed':
        color = const Color.fromARGB(255, 0, 137, 5);
        text = "Completed";
        break;
      case 'cancelled':
        color = Colors.red;
        text = "Cancelled";
        break;
      default:
        color = Colors.grey;
        text = status.toUpperCase();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
