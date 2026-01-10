import 'package:flutter/material.dart';
import '../services/admin_api_services.dart';
import '../utils/logger.dart';

class AdminUserManagementPage extends StatefulWidget {
  const AdminUserManagementPage({super.key});

  @override
  State<AdminUserManagementPage> createState() => _AdminUserManagementPageState();
}

class _AdminUserManagementPageState extends State<AdminUserManagementPage> {
  List<dynamic> users = [];
  bool isLoading = true;
  String? errorMessage;
  Map<String, bool> toggleLoadingStates = {};

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final result = await AdminApiService.getAllUsers();

      if (!mounted) return;

      if (result['success'] == true) {
        setState(() {
          users = result['users'] ?? [];
          isLoading = false;
        });
        AppLogger.info('[ADMIN_USER_MGMT] Loaded ${users.length} users');
      } else {
        setState(() {
          errorMessage = result['message'] ?? 'Gagal memuat data user';
          isLoading = false;
        });
      }
    } catch (e) {
      AppLogger.error('[ADMIN_USER_MGMT] Error loading users: $e');
      if (mounted) {
        setState(() {
          errorMessage = 'Terjadi kesalahan tidak terduga';
          isLoading = false;
        });
      }
    }
  }

  Future<void> _toggleUserStatus(String userId, String userName, bool currentStatus) async {
    final action = currentStatus ? 'menonaktifkan' : 'mengaktifkan';
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi'),
        content: Text('Apakah Anda yakin ingin $action akun user "$userName"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: currentStatus ? Colors.red : Colors.green,
            ),
            child: Text(currentStatus ? 'Nonaktifkan' : 'Aktifkan'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      toggleLoadingStates[userId] = true;
    });

    try {
      final result = await AdminApiService.toggleUserStatus(userId);

      if (!mounted) return;

      setState(() {
        toggleLoadingStates[userId] = false;
      });

      if (result['success'] == true) {
        _showSnackBar(
          result['message'] ?? 'Status berhasil diubah',
          Colors.green,
        );
        _loadUsers();
      } else {
        _showSnackBar(
          result['message'] ?? 'Gagal mengubah status',
          Colors.red,
        );
      }
    } catch (e) {
      AppLogger.error('[ADMIN_USER_MGMT] Error toggling status: $e');
      if (mounted) {
        setState(() {
          toggleLoadingStates[userId] = false;
        });
        _showSnackBar('Terjadi kesalahan tidak terduga', Colors.red);
      }
    }
  }

  void _showSnackBar(String message, Color backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelola User'),
        backgroundColor: const Color(0xFF3F3D7D),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 64, color: Colors.grey.shade400),
                      const SizedBox(height: 16),
                      Text(errorMessage!, style: TextStyle(color: Colors.grey.shade600, fontSize: 16)),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: _loadUsers,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Coba Lagi'),
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF3F3D7D)),
                      ),
                    ],
                  ),
                )
              : users.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.people_outline, size: 64, color: Colors.grey.shade400),
                          const SizedBox(height: 16),
                          Text('Belum ada user terdaftar', style: TextStyle(color: Colors.grey.shade600, fontSize: 16)),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadUsers,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: users.length,
                        itemBuilder: (context, index) {
                          final user = users[index];
                          final userId = user['id'];
                          final name = user['name'] ?? 'No Name';
                          final email = user['email'] ?? 'No Email';
                          final picture = user['picture'];
                          final isActive = user['is_active'] ?? true;

                          final isToggling = toggleLoadingStates[userId] == true;

                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            elevation: 2,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 28,
                                    backgroundColor: const Color(0xFF3F3D7D),
                                    backgroundImage: picture != null && picture.isNotEmpty ? NetworkImage(picture) : null,
                                    child: picture == null || picture.isEmpty
                                        ? Text(name.isNotEmpty ? name[0].toUpperCase() : '?',
                                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20))
                                        : null,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                        const SizedBox(height: 4),
                                        Text(email, style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
                                        const SizedBox(height: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: isActive ? Colors.green.shade50 : Colors.red.shade50,
                                            borderRadius: BorderRadius.circular(12),
                                            border: Border.all(color: isActive ? Colors.green.shade300 : Colors.red.shade300),
                                          ),
                                          child: Text(
                                            isActive ? 'Aktif' : 'Nonaktif',
                                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: isActive ? Colors.green.shade700 : Colors.red.shade700),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  isToggling
                                      ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
                                      : Switch(
                                          value: isActive,
                                          onChanged: (value) => _toggleUserStatus(userId, name, isActive),
                                          activeTrackColor: Colors.green,
                                        ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
}
