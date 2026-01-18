import 'package:flutter/material.dart';
import 'counseling_notes_detail.dart';

import '../services/counselor_api_service.dart';

class CounselingNotesPage extends StatefulWidget {
  const CounselingNotesPage({super.key});

  @override
  State<CounselingNotesPage> createState() => _CounselingNotesPageState();
}

class _CounselingNotesPageState extends State<CounselingNotesPage> {
  // Brand Color (BIKIN SATU SUPAYA KONSISTEN)
  static const primaryColor = Color.fromARGB(255, 110, 16, 183);
  
  bool isLoading = true;
  List<dynamic> notes = [];

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    setState(() => isLoading = true);
    final data = await CounselorApiService.getCounselingNotesList();
    if (!mounted) return;
    setState(() {
      notes = data;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {


    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            /// --- Header ---
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
                    "Counseling Notes",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                ],
              ),
            ),

            /// --- Search Bar ---
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
                    Icon(Icons.search, size: 20, color: Colors.black54),
                    SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: "Search",
                          border: InputBorder.none,
                          hintStyle: TextStyle(color: Colors.black54),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 15),

            /// --- List of Notes ---
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : notes.isEmpty
                      ? const Center(child: Text("No completed sessions"))
                      : ListView.builder(
                          itemCount: notes.length,
                          itemBuilder: (context, index) {
                            final client = notes[index];

                  return Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xffe6e6e6),
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 25,
                          backgroundColor: primaryColor,
                          child: const Icon(Icons.person, color: Colors.white),
                        ),
                        const SizedBox(width: 14),

                        /// Name + Last note
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                client["name"] ?? 'Unknown',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                "Last Session: ${client["last_note_date"] ?? '-'}",
                                style: TextStyle(
                                  color: Colors.grey.shade700,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),

                        /// View button
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => CounselingNotesDetail(
                                  name: client["name"] ?? 'Unknown',
                                ),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                          ),
                          child: const Text(
                            "View Notes",
                            style: TextStyle(fontSize: 13, color: Colors.white),
                          ),
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
}
