import 'package:flutter/material.dart';
import '../auth/counselor_login_page.dart';
import '../services/user_api_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool isEditing = false;
  bool isLoading = true;
  bool isSaving = false;

  // Profile data
  String name = '';
  String email = '';
  String? picture;
  String bio = '';
  String specialization = '';
  bool isAcceptingPatients = false;

  final TextEditingController bioController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    bioController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    setState(() => isLoading = true);

    final result = await UserApiService.getProfile();

    if (result != null && result['success'] == true) {
      final user = result['user'];
      final counselorProfile = user['counselor_profile'];

      setState(() {
        name = user['name'] ?? '';
        email = user['email'] ?? '';
        picture = user['picture'];
        bio = counselorProfile?['bio'] ?? '';
        specialization = counselorProfile?['specialization'] ?? '';
        isAcceptingPatients = counselorProfile?['is_accepting_patients'] ?? false;
        bioController.text = bio;
      });
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result?['message'] ?? 'Gagal memuat profil'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }

    setState(() => isLoading = false);
  }

  Future<void> _toggleAcceptingPatients(bool value) async {
    setState(() => isAcceptingPatients = value);

    final result = await UserApiService.updateProfile(
      isAcceptingPatients: value,
    );

    if (result == null || result['success'] != true) {
      // Revert on failure
      setState(() => isAcceptingPatients = !value);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result?['message'] ?? 'Gagal mengubah status'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              value ? 'Siap menerima pasien' : 'Tidak menerima pasien',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  Future<void> _saveBio() async {
    setState(() => isSaving = true);

    final result = await UserApiService.updateProfile(
      bio: bioController.text,
    );

    setState(() => isSaving = false);

    if (result != null && result['success'] == true) {
      setState(() {
        bio = bioController.text;
        isEditing = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bio berhasil disimpan'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result?['message'] ?? 'Gagal menyimpan bio'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  Future<void> _logout() async {
    await UserApiService.logout();

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const CounselorLoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black87),
            onPressed: _loadProfile,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  /// ================= Profile Image =================
                  CircleAvatar(
                    radius: 55,
                    backgroundColor: const Color(0xff6b38f0),
                    backgroundImage:
                        picture != null ? NetworkImage(picture!) : null,
                    child: picture == null
                        ? const Icon(Icons.person, color: Colors.white, size: 60)
                        : null,
                  ),

                  const SizedBox(height: 16),

                  /// ================= Name & Email =================
                  Text(
                    name.isNotEmpty ? name : 'Konselor',
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),

                  Text(
                    email,
                    style:
                        const TextStyle(fontSize: 13, color: Colors.black54),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 25),

                  /// ================= Accepting Patients Toggle =================
                  _infoBox(
                    title: "Status Penerimaan Pasien:",
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          isAcceptingPatients
                              ? "Menerima Pasien Baru"
                              : "Tidak Menerima Pasien",
                          style: TextStyle(
                            color: isAcceptingPatients
                                ? Colors.green.shade700
                                : Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Switch(
                          value: isAcceptingPatients,
                          onChanged: _toggleAcceptingPatients,
                          activeThumbColor: const Color(0xff6b38f0),
                          activeTrackColor:
                              const Color(0xff6b38f0).withValues(alpha: 0.3),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// ================= Specialization Box =================
                  _infoBox(
                    title: "Specialization:",
                    child: Text(
                      specialization.isNotEmpty
                          ? specialization
                          : "Belum diatur",
                      style: TextStyle(
                        color: specialization.isNotEmpty
                            ? Colors.black87
                            : Colors.grey,
                        height: 1.4,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// ================= Short Bio Box =================
                  _infoBox(
                    title: "Short Bio:",
                    trailing: GestureDetector(
                      onTap: () {
                        if (isEditing) {
                          _saveBio();
                        } else {
                          setState(() => isEditing = true);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 6,
                          horizontal: 16,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xff6b38f0),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: isSaving
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                isEditing ? "Save" : "Edit",
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 13),
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
                              hintText: 'Tulis bio singkat...',
                            ),
                          )
                        : Text(
                            bio.isNotEmpty ? bio : "Belum ada bio",
                            style: TextStyle(
                              height: 1.4,
                              color: bio.isNotEmpty ? Colors.black87 : Colors.grey,
                            ),
                          ),
                  ),

                  const SizedBox(height: 40),

                  /// ================= LOGOUT BUTTON =================
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.logout, color: Colors.redAccent),
                      onPressed: _logout,
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
