import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isEditing = false;

  final TextEditingController _nameController = TextEditingController(
    text: "Andhika Presha Saputra",
  );
  final TextEditingController _emailController = TextEditingController(
    text: "andhika@mentalist.com",
  );
  final TextEditingController _phoneController = TextEditingController(
    text: "+62 812 3456 7890",
  );
  final TextEditingController _specializationController = TextEditingController(
    text: "Konseling Remaja & Keluarga",
  );
  final TextEditingController _experienceController = TextEditingController(
    text: "5 Tahun Pengalaman Konseling",
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xfff3f2f8),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 8),
            CircleAvatar(
              radius: 55,
              backgroundColor: Colors.deepPurple.shade100,
              child: const Icon(
                Icons.person,
                size: 60,
                color: Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 16),

            Text(
              _nameController.text,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            const Text(
              "Konselor Psikologi",
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 20),

            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
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
                      icon: Icons.school,
                      label: "Spesialisasi",
                      controller: _specializationController,
                    ),
                    const Divider(),
                    _buildField(
                      icon: Icons.star,
                      label: "Pengalaman",
                      controller: _experienceController,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    if (_isEditing) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Perubahan profil berhasil disimpan ✅"),
                        ),
                      );
                    }
                    _isEditing = !_isEditing;
                  });
                },
                icon: Icon(_isEditing ? Icons.save : Icons.edit),
                label: Text(_isEditing ? "Simpan Perubahan" : "Edit Profil"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
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

  Widget _buildField({
    required IconData icon,
    required String label,
    required TextEditingController controller,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.deepPurple),
      title: Text(label),
      subtitle: _isEditing
          ? TextField(
              controller: controller,
              decoration: const InputDecoration(
                isDense: true,
                border: UnderlineInputBorder(),
              ),
            )
          : Text(controller.text),
    );
  }
}
