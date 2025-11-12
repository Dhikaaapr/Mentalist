import 'package:flutter/material.dart';

class AdminProfilePage extends StatefulWidget {
  const AdminProfilePage({super.key});

  @override
  State<AdminProfilePage> createState() => _AdminProfilePageState();
}

class _AdminProfilePageState extends State<AdminProfilePage> {
  bool _isEditing = false;

  final TextEditingController _nameController = TextEditingController(
    text: "Andhika Presha Saputra",
  );
  final TextEditingController _emailController = TextEditingController(
    text: "admin@mentalist.com",
  );
  final TextEditingController _phoneController = TextEditingController(
    text: "+62 812 3456 7890",
  );
  final TextEditingController _roleController = TextEditingController(
    text: "Administrator Sistem",
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xfff4f6f9),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 16),
            CircleAvatar(
              radius: 55,
              backgroundColor: Colors.blueAccent.shade100,
              child: const Icon(
                Icons.admin_panel_settings,
                size: 60,
                color: Colors.blueAccent,
              ),
            ),
            const SizedBox(height: 16),

            // Nama Admin
            Text(
              _nameController.text,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            const Text("Administrator", style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 20),

            // Kartu Data Profil
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
                      icon: Icons.person,
                      label: "Nama Lengkap",
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
                      icon: Icons.work,
                      label: "Jabatan",
                      controller: _roleController,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Tombol Edit / Simpan Profil
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    if (_isEditing) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Profil admin berhasil disimpan ✅"),
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

            const SizedBox(height: 32),

            // =======================
            // Bagian Pengaturan Sistem
            // =======================
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Pengaturan Sistem",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black54,
                ),
              ),
            ),
            const SizedBox(height: 10),

            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
              child: Column(
                children: [
                  _buildSettingTile(
                    icon: Icons.color_lens,
                    title: "Ubah Tema",
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Fitur ubah tema belum tersedia."),
                        ),
                      );
                    },
                  ),
                  const Divider(),
                  _buildSettingTile(
                    icon: Icons.group,
                    title: "Kelola Akun User & Konselor",
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            "Menu manajemen akun sedang dikembangkan.",
                          ),
                        ),
                      );
                    },
                  ),
                  const Divider(),
                  _buildSettingTile(
                    icon: Icons.info_outline,
                    title: "Tentang Aplikasi",
                    onTap: () {
                      showAboutDialog(
                        context: context,
                        applicationName: "Mentalist Admin Panel",
                        applicationVersion: "1.0.0",
                        applicationIcon: const Icon(Icons.admin_panel_settings),
                        children: const [
                          Text(
                            "Aplikasi pengelolaan konseling dan akun pengguna.",
                          ),
                        ],
                      );
                    },
                  ),
                  const Divider(),
                  _buildSettingTile(
                    icon: Icons.logout,
                    title: "Logout",
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Berhasil logout ✅")),
                      );
                      Navigator.pop(context); // kembali ke login
                    },
                    color: Colors.redAccent,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget untuk field profil yang bisa diedit
  Widget _buildField({
    required IconData icon,
    required String label,
    required TextEditingController controller,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.blueAccent),
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

  // Widget untuk item pengaturan
  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color color = Colors.black87,
  }) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title, style: TextStyle(color: color)),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: Colors.grey,
      ),
      onTap: onTap,
    );
  }
}
