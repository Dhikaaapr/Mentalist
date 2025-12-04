import 'package:flutter/material.dart';
import '../auth/counselor_login_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool isEditing = false;

  final TextEditingController bioController = TextEditingController(
    text:
        "Dr. Julliete Aurora is passionate about helping clients navigate life challenges, build coping skills, and improve emotional well-being. She creates a safe and supportive space for open conversations.",
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      /// ===================== APP BAR =====================
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Counselor Profile",
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            /// ================= Profile Image =================
            CircleAvatar(
              radius: 55,
              backgroundColor: const Color(0xff6b38f0),
              child: const Icon(Icons.person, color: Colors.white, size: 60),
            ),

            const SizedBox(height: 16),

            /// ================= Name & Role =================
            const Text(
              "Dr. dhika",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),

            const Text(
              "Title / Role: Licensed Clinical Psychologist",
              style: TextStyle(fontSize: 13, color: Colors.black87),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 4),

            const Text(
              "Experience: 8 years in counseling adolescents and adults",
              style: TextStyle(color: Colors.black54, fontSize: 12),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 25),

            /// ================= Specialization Box =================
            _infoBox(
              title: "Specialization:",
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Stress & Anxiety Management"),
                  Text("Depression & Mood Disorders"),
                  Text("Emotional Regulation & Coping Skills"),
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// ================= Short Bio Box =================
            _infoBox(
              title: "Short Bio:",
              trailing: GestureDetector(
                onTap: () => setState(() => isEditing = !isEditing),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 6,
                    horizontal: 16,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xff6b38f0),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    isEditing ? "Save" : "Edit",
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                  ),
                ),
              ),
              child: isEditing
                  ? TextField(
                      controller: bioController,
                      maxLines: 5,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    )
                  : Text(
                      bioController.text,
                      style: const TextStyle(height: 1.4),
                    ),
            ),

            const SizedBox(height: 20),

            /// ================= Additional Info =================
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  "Languages Spoken:",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text("English, Indonesian"),
              ],
            ),

            const SizedBox(height: 10),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  "Availability:",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text("Mon–Fri, 10:00–17:00"),
              ],
            ),

            const SizedBox(height: 40),

            /// ================= LOGOUT BUTTON =================
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.logout, color: Colors.redAccent),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const CounselorLoginPage(),
                    ),
                  );
                },
                label: const Text(
                  "Logout",
                  style: TextStyle(
                    color: Colors.redAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: const BorderSide(color: Colors.redAccent),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  /// ===================== COMPONENT BOX TEMPLATE =====================

  Widget _infoBox({
    required String title,
    required Widget child,
    Widget? trailing,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xfff0f0f0),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: trailing == null
                ? MainAxisAlignment.start
                : MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (trailing != null) trailing,
            ],
          ),

          const SizedBox(height: 10),

          child,
        ],
      ),
    );
  }
}
