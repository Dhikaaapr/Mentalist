import 'package:flutter/material.dart';

class CounselingNotesDetail extends StatelessWidget {
  final String name;

  const CounselingNotesDetail({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, size: 26),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 10),
                  const CircleAvatar(
                    radius: 22,
                    backgroundColor: Colors.purple,
                    child: Icon(Icons.person, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// Note Cards
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    noteSection(
                      title: "Session Summary:",
                      content:
                          "The user talked about feeling low and easily irritated over the past few days. We discussed recent triggers and how these moods affect daily activities.",
                    ),
                    noteSection(
                      title: "User Concerns:",
                      content:
                          "Low mood, frequent bad days, trouble focusing, and feeling emotionally drained",
                    ),
                    noteSection(
                      title: "Strategies Suggested:",
                      content:
                          "Practice short breathing exercises, take brief breaks during stressful moments, write a simple mood journal at night, and reach out to supportive friends or family when needed.",
                    ),
                    noteSection(
                      title: "Action Plan / Next Steps:",
                      content:
                          "User will try to track mood once a day and apply breathing techniques during moments of stress. We will review progress in the next session.",
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Reusable note container UI
  Widget noteSection({required String title, required String content}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xffe6e6e6),
        borderRadius: BorderRadius.circular(18),
      ),
      child: RichText(
        text: TextSpan(
          text: "$title\n",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: Colors.black,
          ),
          children: [
            TextSpan(
              text: content,
              style: const TextStyle(
                fontWeight: FontWeight.normal,
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
