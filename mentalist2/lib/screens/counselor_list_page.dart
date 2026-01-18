import 'package:flutter/material.dart';
import 'chat_list_page.dart';
import 'schedule_page.dart';
import 'counseling_notes_page.dart';
import '../services/counselor_api_service.dart';

class CounselorListPage extends StatefulWidget {
  const CounselorListPage({super.key});

  @override
  State<CounselorListPage> createState() => _CounselorListPageState();
}

class _CounselorListPageState extends State<CounselorListPage> {
  bool isLoading = true;
  List<dynamic> clients = [];

  @override
  void initState() {
    super.initState();
    _loadClients();
  }

  Future<void> _loadClients() async {
    setState(() => isLoading = true);
    final data = await CounselorApiService.getActiveClients();
    if (!mounted) return;
    setState(() {
      clients = data;
      isLoading = false;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            /// ---- Header ----
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, size: 26),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Spacer(),
                  const Text(
                    "Active Clients",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                ],
              ),
            ),

            /// ---- Search ----
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.search, size: 20),
                    SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: "Search",
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            /// ---- Client List ----
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : clients.isEmpty
                      ? const Center(child: Text("No active clients"))
                      : ListView.builder(
                          itemCount: clients.length,
                          itemBuilder: (context, index) {
                            final client = clients[index];

                  final int progress = client["progress"] ?? 0;
                  final int total = client["target_sessions"] ?? 12;
                  final double percent = (progress / total).clamp(0.0, 1.0);

                  return Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xffe6e6e6),
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// Name + Status Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const CircleAvatar(
                                  backgroundColor: Color.fromARGB(
                                    255,
                                    110,
                                    16,
                                    183,
                                  ),
                                  child: Icon(
                                    Icons.person,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  client["name"],
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade400,
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: Text(
                                client["status"] ?? 'Active',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 5),

                        Text(
                          "Last Booking: ${client["last_booking_date"] ?? '-'}",
                          style: TextStyle(color: Colors.grey.shade700),
                        ),

                        const SizedBox(height: 10),

                        /// Progress bar
                        Stack(
                          children: [
                            Container(
                              height: 6,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade500,
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            FractionallySizedBox(
                              widthFactor: percent,
                              child: Container(
                                height: 6,
                                decoration: BoxDecoration(
                                  color: Colors.amber,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 5),
                        Text(
                          "${client['total_sessions']} Sessions Completed",
                          style: const TextStyle(fontSize: 12),
                        ),

                        const SizedBox(height: 12),

                        /// Action Buttons Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _actionButton(
                              label: "View Notes",
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const CounselingNotesPage(),
                                  ),
                                );
                              },
                            ),
                            _actionButton(
                              label: "Schedule",
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const SchedulePage(),
                                  ),
                                );
                              },
                            ),
                            _actionButton(
                              label: "Chat",
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const ChatListPage(),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionButton({required String label, required VoidCallback onTap}) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color.fromARGB(255, 110, 16, 183),
        foregroundColor: Colors.white, // 🟣 Tekst dan icon auto putih
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
      ),
    );
  }
}
