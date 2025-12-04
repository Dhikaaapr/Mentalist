import 'package:flutter/material.dart';

class AdminProfilePage extends StatefulWidget {
  const AdminProfilePage({super.key});

  @override
  State<AdminProfilePage> createState() => _AdminProfilePageState();
}

class _AdminProfilePageState extends State<AdminProfilePage> {
  bool _isEditing = false;

  final TextEditingController _nameController = TextEditingController(
    text: "Sarah Lee",
  );
  final TextEditingController _emailController = TextEditingController(
    text: "sarahlee@gmail.com",
  );
  final TextEditingController _phoneController = TextEditingController(
    text: "089088844333",
  );
  final TextEditingController _dateController = TextEditingController(
    text: "15 November, 2023",
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back, color: Colors.black),
        ),
        title: const Text(
          "Settings",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        centerTitle: true,
      ),

      /// BODY
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
        child: Column(
          children: [
            /// --- PROFILE HEADER ---
            const CircleAvatar(
              radius: 50,
              backgroundColor: Color(0xFFD8CFF0),
              child: Icon(Icons.person, size: 55, color: Color(0xFF6A1B9A)),
            ),
            const SizedBox(height: 15),

            Text(
              _nameController.text,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
            ),
            const Text("Admin", style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 25),

            /// --- PERSONAL INFORMATION CARD ---
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Personal information",
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                  ),
                  const SizedBox(height: 15),

                  _infoItem(
                    Icons.person,
                    _nameController,
                    editable: _isEditing,
                  ),
                  const SizedBox(height: 12),
                  _infoItem(
                    Icons.email,
                    _emailController,
                    editable: _isEditing,
                  ),
                  const SizedBox(height: 12),
                  _infoItem(
                    Icons.phone,
                    _phoneController,
                    editable: _isEditing,
                  ),
                  const SizedBox(height: 12),
                  _infoItem(
                    Icons.access_time,
                    _dateController,
                    editable: _isEditing,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            /// --- EDIT BUTTON ---
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    if (_isEditing) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Profile updated successfully"),
                        ),
                      );
                    }
                    _isEditing = !_isEditing;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey.shade300,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: Text(
                  _isEditing ? "Save changes" : "Edit profile",
                  style: const TextStyle(fontSize: 15),
                ),
              ),
            ),

            const SizedBox(height: 25),

            /// --- SYSTEM SETTINGS TITLE ---
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "System settings",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 12),

            /// --- SETTINGS MENU CARD ---
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                children: [
                  _settingsItem(
                    Icons.group,
                    "Manage users & counselors accounts",
                    () {},
                  ),
                  _divider(),
                  _settingsItem(Icons.info_outline, "About application", () {}),
                  _divider(),
                  _settingsItem(Icons.logout, "Logout", () {
                    Navigator.pop(context);
                  }, color: Colors.redAccent),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// --- PROFILE VALUE ITEM ---
  Widget _infoItem(
    IconData icon,
    TextEditingController controller, {
    bool editable = false,
  }) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF6A1B9A)),
        const SizedBox(width: 12),
        Expanded(
          child: editable
              ? TextField(
                  controller: controller,
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    isDense: true,
                  ),
                )
              : Text(controller.text, style: const TextStyle(fontSize: 15)),
        ),
      ],
    );
  }

  /// --- SETTINGS TILE ---
  Widget _settingsItem(
    IconData icon,
    String text,
    VoidCallback onTap, {
    Color color = Colors.black,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: const Color(0xFF6A1B9A)),
      title: Text(text, style: TextStyle(color: color, fontSize: 15)),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: Colors.grey,
      ),
      onTap: onTap,
    );
  }

  Widget _divider() => const Padding(
    padding: EdgeInsets.symmetric(vertical: 4),
    child: Divider(height: 1),
  );
}
