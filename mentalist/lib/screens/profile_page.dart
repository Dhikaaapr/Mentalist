import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../auth/login_page.dart';

class ProfilePage extends StatefulWidget {
  final String? userName;
  final String? userEmail;
  final String? userPhoto;

  const ProfilePage({super.key, this.userName, this.userEmail, this.userPhoto});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isEditing = false;

  late final TextEditingController _nameController;
  late final TextEditingController _emailController;

  final TextEditingController _phoneController = TextEditingController(
    text: "+62 812 3456 7890",
  );
  final TextEditingController _birthController = TextEditingController(
    text: "11 November 2002",
  );
  final TextEditingController _addressController = TextEditingController(
    text: "Jakarta Selatan",
  );

  final GoogleSignIn _googleSignIn = GoogleSignIn();

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(text: widget.userName ?? "User");
    _emailController = TextEditingController(
      text: widget.userEmail ?? "email@example.com",
    );
  }

  /// 🔥 Logout Function
  Future<void> _logout() async {
    try {
      await _googleSignIn.signOut();

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    } catch (e) {
      debugPrint("Logout error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff6f7fb),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        child: Column(
          children: [
            /// Profile Photo
            Center(
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.blue.shade100,
                    backgroundImage: widget.userPhoto != null
                        ? NetworkImage(widget.userPhoto!)
                        : null,
                    child: widget.userPhoto == null
                        ? const Icon(
                            Icons.person,
                            size: 60,
                            color: Colors.white,
                          )
                        : null,
                  ),
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: Colors.blueAccent,
                    child: const Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 15),

            Text(
              _nameController.text,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 5),
            Text(
              _emailController.text,
              style: const TextStyle(color: Colors.grey, fontSize: 14),
            ),

            const SizedBox(height: 25),

            /// Card Section
            _buildInfoCard(),

            const SizedBox(height: 30),

            /// Edit Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    if (_isEditing) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            "Perubahan profil berhasil disimpan 🎉",
                          ),
                        ),
                      );
                    }
                    _isEditing = !_isEditing;
                  });
                },
                icon: Icon(_isEditing ? Icons.save : Icons.edit),
                label: Text(_isEditing ? "Simpan Perubahan" : "Edit Profil"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 15),

            /// Logout Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _logout,
                icon: const Icon(Icons.logout, color: Colors.redAccent),
                label: const Text(
                  "Logout",
                  style: TextStyle(color: Colors.redAccent, fontSize: 16),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.redAccent, width: 1.5),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 💡 Card Widget
  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07), // << FIXED WARNING
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildField(
            icon: Icons.person,
            label: "Nama",
            controller: _nameController,
          ),
          const Divider(),
          _buildField(
            icon: Icons.email,
            label: "Email",
            controller: _emailController,
          ),
          const Divider(),
          _buildField(
            icon: Icons.phone,
            label: "Nomor Telepon",
            controller: _phoneController,
          ),
          const Divider(),
          _buildField(
            icon: Icons.cake,
            label: "Tanggal Lahir",
            controller: _birthController,
          ),
          const Divider(),
          _buildField(
            icon: Icons.home,
            label: "Alamat / Kota",
            controller: _addressController,
          ),
        ],
      ),
    );
  }

  /// 🔧 ListTile Custom Widget
  Widget _buildField({
    required IconData icon,
    required String label,
    required TextEditingController controller,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.blueAccent),
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: _isEditing
          ? TextField(
              controller: controller,
              decoration: const InputDecoration(
                isDense: true,
                border: UnderlineInputBorder(),
              ),
            )
          : Text(
              controller.text,
              style: const TextStyle(color: Colors.black87),
            ),
    );
  }
}
