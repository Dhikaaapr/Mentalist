import 'package:flutter/material.dart';
import '../services/admin_api_services.dart';
import '../auth/admin_login_page.dart';

class AdminProfilePage extends StatefulWidget {
  const AdminProfilePage({super.key});

  @override
  State<AdminProfilePage> createState() => _AdminProfilePageState();
}

class _AdminProfilePageState extends State<AdminProfilePage> {
  bool _isEditing = false;
  bool _isLoading = true;
  bool _isSaving = false;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);

    final result = await AdminApiService.getProfile();

    if (result['success'] == true && result['user'] != null) {
      final user = result['user'];
      setState(() {
        _nameController.text = user['name'] ?? '';
        _emailController.text = user['email'] ?? '';
        _phoneController.text = user['phone'] ?? '';
        _dateController.text = user['created_at'] ?? '';
      });
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Gagal memuat profil'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }

    setState(() => _isLoading = false);
  }

  Future<void> _saveProfile() async {
    setState(() => _isSaving = true);

    final result = await AdminApiService.updateProfile(
      name: _nameController.text,
      phone: _phoneController.text,
    );

    setState(() => _isSaving = false);

    if (result['success'] == true) {
      setState(() => _isEditing = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profil berhasil diperbarui'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Gagal update profil'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  Future<void> _logout() async {
    await AdminApiService.logout();

    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const AdminLoginPage()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false, // No back button, part of bottom nav
        title: const Text(
          "Profile",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black),
            onPressed: _loadProfile,
          ),
        ],
      ),

      /// BODY
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 50,
                    backgroundColor: Color(0xFFD8CFF0),
                    child: Icon(Icons.person, size: 55, color: Color(0xFF6A1B9A)),
                  ),
                  const SizedBox(height: 15),

                  Text(
                    _nameController.text.isNotEmpty
                        ? _nameController.text
                        : 'Admin',
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
                  ),
                  const Text("Admin", style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 25),

                  /// PERSONAL INFO
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
                          editable: false, // Email tidak bisa diedit
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
                          editable: false, // Created at tidak bisa diedit
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  /// EDIT BUTTON
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isSaving
                          ? null
                          : () {
                              if (_isEditing) {
                                _saveProfile();
                              } else {
                                setState(() => _isEditing = true);
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade300,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: _isSaving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(
                              _isEditing ? "Save changes" : "Edit profile",
                              style: const TextStyle(fontSize: 15),
                            ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  /// SYSTEM SETTINGS
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "System settings",
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(height: 12),

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
                        _settingsItem(Icons.logout, "Logout", _logout, color: Colors.redAccent),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

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
              : Text(controller.text.isNotEmpty ? controller.text : '-', style: const TextStyle(fontSize: 15)),
        ),
      ],
    );
  }

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
