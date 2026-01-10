import 'package:flutter/material.dart';
import '../services/admin_api_services.dart';
import '../utils/logger.dart';

class AdminManagementPage extends StatefulWidget {
  const AdminManagementPage({super.key});

  @override
  State<AdminManagementPage> createState() => _AdminManagementPageState();
}

class _AdminManagementPageState extends State<AdminManagementPage> {
  List<dynamic> counselors = [];
  bool isLoading = true;
  String? errorMessage;
  Map<String, bool> toggleLoadingStates = {};

  @override
  void initState() {
    super.initState();
    _loadCounselors();
  }

  Future<void> _loadCounselors() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final result = await AdminApiService.getAllCounselors();

      if (!mounted) return;

      if (result['success'] == true) {
        setState(() {
          counselors = result['counselors'] ?? [];
          isLoading = false;
        });
        AppLogger.info('[ADMIN_MGMT] Loaded ${counselors.length} counselors');
      } else {
        setState(() {
          errorMessage = result['message'] ?? 'Gagal memuat data konselor';
          isLoading = false;
        });
      }
    } catch (e) {
      AppLogger.error('[ADMIN_MGMT] Error loading counselors: $e');
      if (mounted) {
        setState(() {
          errorMessage = 'Terjadi kesalahan tidak terduga';
          isLoading = false;
        });
      }
    }
  }

  Future<void> _toggleCounselorStatus(String userId, String counselorName, bool currentStatus) async {
    final action = currentStatus ? 'menonaktifkan' : 'mengaktifkan';
    
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi'),
        content: Text('Apakah Anda yakin ingin $action akun konselor "$counselorName"?'),
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

    // Set loading state for this counselor
    setState(() {
      toggleLoadingStates[userId] = true;
    });

    try {
      final result = await AdminApiService.toggleCounselorStatus(userId);

      if (!mounted) return;

      setState(() {
        toggleLoadingStates[userId] = false;
      });

      if (result['success'] == true) {
        _showSnackBar(
          result['message'] ?? 'Status berhasil diubah',
          Colors.green,
        );
        // Reload counselors to get updated data
        await _loadCounselors();
      } else {
        _showSnackBar(
          result['message'] ?? 'Gagal mengubah status',
          Colors.red,
        );
      }
    } catch (e) {
      AppLogger.error('[ADMIN_MGMT] Error toggling status: $e');
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
        title: const Text('Kelola Konselor'),
        backgroundColor: const Color(0xFF6A1B9A),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        errorMessage!,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: _loadCounselors,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Coba Lagi'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6A1B9A),
                        ),
                      ),
                    ],
                  ),
                )
              : counselors.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.people_outline,
                            size: 64,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Belum ada konselor terdaftar',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadCounselors,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: counselors.length,
                        itemBuilder: (context, index) {
                          final counselor = counselors[index];
                          final userId = counselor['id'];
                          final name = counselor['name'] ?? 'No Name';
                          final email = counselor['email'] ?? 'No Email';
                          final picture = counselor['picture'];
                          
                          final counselorProfile = counselor['counselor_profile'];
                          final isActive = counselorProfile?['is_active'] ?? true;
                          final bio = counselorProfile?['bio'];
                          final specialization = counselorProfile?['specialization'];

                          final isToggling = toggleLoadingStates[userId] == true;

                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Header with avatar, name, and status toggle
                                  Row(
                                    children: [
                                      // Avatar
                                      CircleAvatar(
                                        radius: 28,
                                        backgroundColor: const Color(0xFF6A1B9A),
                                        backgroundImage: picture != null && picture.isNotEmpty
                                            ? NetworkImage(picture)
                                            : null,
                                        child: picture == null || picture.isEmpty
                                            ? Text(
                                                name.isNotEmpty ? name[0].toUpperCase() : '?',
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 20,
                                                ),
                                              )
                                            : null,
                                      ),
                                      const SizedBox(width: 12),
                                      // Name and email
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              name,
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              email,
                                              style: TextStyle(
                                                fontSize: 13,
                                                color: Colors.grey.shade600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      // Status toggle switch
                                      isToggling
                                          ? const SizedBox(
                                              width: 24,
                                              height: 24,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                              ),
                                            )
                                          : Switch(
                                              value: isActive,
                                              onChanged: (value) {
                                                _toggleCounselorStatus(userId, name, isActive);
                                              },
                                              activeTrackColor: Colors.green,
                                            ),
                                    ],
                                  ),
                                  
                                  const SizedBox(height: 12),
                                  
                                  // Status badge
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: isActive
                                              ? Colors.green.shade50
                                              : Colors.red.shade50,
                                          borderRadius: BorderRadius.circular(16),
                                          border: Border.all(
                                            color: isActive
                                                ? Colors.green.shade300
                                                : Colors.red.shade300,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              isActive ? Icons.check_circle : Icons.cancel,
                                              size: 16,
                                              color: isActive ? Colors.green : Colors.red,
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              isActive ? 'Aktif' : 'Tidak Aktif',
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                                color: isActive ? Colors.green.shade700 : Colors.red.shade700,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  
                                  // Specialization
                                  if (specialization != null && specialization.isNotEmpty) ...[
                                    const SizedBox(height: 12),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.school_outlined,
                                          size: 16,
                                          color: Colors.grey.shade600,
                                        ),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: Text(
                                            specialization,
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: Colors.grey.shade700,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                  
                                  // Bio
                                  if (bio != null && bio.isNotEmpty) ...[
                                    const SizedBox(height: 12),
                                    Text(
                                      bio.length > 100 ? '${bio.substring(0, 100)}...' : bio,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey.shade600,
                                        height: 1.4,
                                      ),
                                    ),
                                  ],
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
