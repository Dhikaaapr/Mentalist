import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/logger.dart';

class AdminApiService {
  // emulator
  // static const String baseUrl = 'http://10.0.2.2:8000/api';

  // physical device
  static const String baseUrl = 'http://192.168.100.11:8000/api';

  static const Duration timeoutDuration = Duration(seconds: 30);

  /// -------------------------------
  /// LOGIN ADMIN
  /// Uses same endpoint as user/konselor, backend will validate role
  /// -------------------------------
  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    try {
      AppLogger.info('📡 [ADMIN] Request → $baseUrl/auth/login');

      final response = await http
          .post(
            Uri.parse('$baseUrl/auth/login'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: json.encode({'email': email, 'password': password}),
          )
          .timeout(
            timeoutDuration,
            onTimeout: () {
              throw TimeoutException('Request timeout');
            },
          );

      AppLogger.info('📡 [ADMIN] Status: ${response.statusCode}');
      AppLogger.debug('📬 [ADMIN] Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data is! Map<String, dynamic>) {
          AppLogger.error('[ADMIN] Response bukan Map');
          return {'success': false, 'message': 'Format response tidak valid'};
        }

        // Validate that user is admin
        if (data['user'] != null && data['user']['role'] != null) {
          final roleName = data['user']['role']['name'];
          if (roleName != 'admin') {
            return {
              'success': false,
              'message': 'Akun ini bukan akun admin',
              'error': 'not_admin',
            };
          }
        }

        // Save token and role
        if (data['token'] != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('accessToken', data['token']);
          await prefs.setString('role', 'admin');
          AppLogger.info('[ADMIN] Token dan role disimpan');
        }

        data['success'] = true;
        return data;
      }

      if (response.statusCode == 401) {
        return {
          'success': false,
          'message': 'Email atau password salah',
          'error': 'unauthorized',
        };
      }

      if (response.statusCode == 403) {
        return {
          'success': false,
          'message': 'Akun tidak aktif',
          'error': 'forbidden',
        };
      }

      return {
        'success': false,
        'message': 'Terjadi kesalahan pada server',
        'error': 'server_error',
      };
    } on TimeoutException catch (e) {
      AppLogger.error('[ADMIN] Timeout: $e');
      return {
        'success': false,
        'message': 'Koneksi timeout',
        'error': 'timeout',
      };
    } on SocketException catch (e) {
      AppLogger.error('[ADMIN] Network error: $e');
      return {
        'success': false,
        'message': 'Tidak dapat terhubung ke server',
        'error': 'network_error',
      };
    } catch (e) {
      AppLogger.error('[ADMIN] Error: $e');
      return {
        'success': false,
        'message': 'Terjadi kesalahan',
        'error': 'unknown_error',
      };
    }
  }

  /// -------------------------------
  /// LOGOUT ADMIN
  /// -------------------------------
  static Future<Map<String, dynamic>> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken') ?? '';

      if (token.isEmpty) {
        // Just clear local storage
        await prefs.remove('accessToken');
        await prefs.remove('role');
        return {'success': true, 'message': 'Logout berhasil'};
      }

      AppLogger.info('📡 [ADMIN] Logout → $baseUrl/logout');

      final response = await http
          .post(
            Uri.parse('$baseUrl/logout'),
            headers: {
              'Authorization': 'Bearer $token',
              'Accept': 'application/json',
            },
          )
          .timeout(timeoutDuration);

      // Clear local storage regardless of response
      await prefs.remove('accessToken');
      await prefs.remove('role');

      AppLogger.info('📡 [ADMIN] Logout status: ${response.statusCode}');

      return {'success': true, 'message': 'Logout berhasil'};
    } catch (e) {
      // Still clear local storage on error
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('accessToken');
      await prefs.remove('role');

      AppLogger.error('[ADMIN] Logout error: $e');
      return {'success': true, 'message': 'Logout berhasil'};
    }
  }

  /// -------------------------------
  /// GET ALL COUNSELORS
  /// -------------------------------
  static Future<Map<String, dynamic>> getAllCounselors() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken') ?? '';

      if (token.isEmpty) {
        return {
          'success': false,
          'message': 'Belum login',
          'error': 'no_token',
        };
      }

      AppLogger.info('📡 [ADMIN] Get all counselors → $baseUrl/admin/counselors');

      final response = await http
          .get(
            Uri.parse('$baseUrl/admin/counselors'),
            headers: {
              'Authorization': 'Bearer $token',
              'Accept': 'application/json',
            },
          )
          .timeout(
            timeoutDuration,
            onTimeout: () {
              throw TimeoutException('Request timeout');
            },
          );

      AppLogger.info('📡 [ADMIN] Status: ${response.statusCode}');
      AppLogger.debug('📬 [ADMIN] Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data is! Map<String, dynamic>) {
          AppLogger.error('[ADMIN] Response bukan Map');
          return {'success': false, 'message': 'Format response tidak valid'};
        }

        return {'success': true, ...data};
      }

      if (response.statusCode == 401) {
        return {
          'success': false,
          'message': 'Sesi habis, silakan login kembali',
          'error': 'unauthorized',
        };
      }

      if (response.statusCode == 403) {
        return {
          'success': false,
          'message': 'Akses ditolak. Hanya admin yang dapat mengakses.',
          'error': 'forbidden',
        };
      }

      return {
        'success': false,
        'message': 'Terjadi kesalahan pada server',
        'error': 'server_error',
      };
    } on TimeoutException catch (e) {
      AppLogger.error('[ADMIN] Timeout: $e');
      return {
        'success': false,
        'message': 'Koneksi timeout',
        'error': 'timeout',
      };
    } on SocketException catch (e) {
      AppLogger.error('[ADMIN] Network error: $e');
      return {
        'success': false,
        'message': 'Tidak dapat terhubung ke server',
        'error': 'network_error',
      };
    } catch (e) {
      AppLogger.error('[ADMIN] Error: $e');
      return {
        'success': false,
        'message': 'Terjadi kesalahan',
        'error': 'unknown_error',
      };
    }
  }

  /// -------------------------------
  /// TOGGLE COUNSELOR STATUS
  /// -------------------------------
  static Future<Map<String, dynamic>> toggleCounselorStatus(String counselorId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken') ?? '';

      if (token.isEmpty) {
        return {
          'success': false,
          'message': 'Belum login',
          'error': 'no_token',
        };
      }

      AppLogger.info('📡 [ADMIN] Toggle counselor status → $baseUrl/admin/counselors/$counselorId/toggle-status');

      final response = await http
          .post(
            Uri.parse('$baseUrl/admin/counselors/$counselorId/toggle-status'),
            headers: {
              'Authorization': 'Bearer $token',
              'Accept': 'application/json',
              'Content-Type': 'application/json',
            },
          )
          .timeout(
            timeoutDuration,
            onTimeout: () {
              throw TimeoutException('Request timeout');
            },
          );

      AppLogger.info('📡 [ADMIN] Status: ${response.statusCode}');
      AppLogger.debug('📬 [ADMIN] Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data is! Map<String, dynamic>) {
          AppLogger.error('[ADMIN] Response bukan Map');
          return {'success': false, 'message': 'Format response tidak valid'};
        }

        return {'success': true, ...data};
      }

      if (response.statusCode == 401) {
        return {
          'success': false,
          'message': 'Sesi habis, silakan login kembali',
          'error': 'unauthorized',
        };
      }

      if (response.statusCode == 403) {
        return {
          'success': false,
          'message': 'Akses ditolak',
          'error': 'forbidden',
        };
      }

      return {
        'success': false,
        'message': 'Terjadi kesalahan pada server',
        'error': 'server_error',
      };
    } on TimeoutException catch (e) {
      AppLogger.error('[ADMIN] Timeout: $e');
      return {
        'success': false,
        'message': 'Koneksi timeout',
        'error': 'timeout',
      };
    } on SocketException catch (e) {
      AppLogger.error('[ADMIN] Network error: $e');
      return {
        'success': false,
        'message': 'Tidak dapat terhubung ke server',
        'error': 'network_error',
      };
    } catch (e) {
      AppLogger.error('[ADMIN] Error: $e');
      return {
        'success': false,
        'message': 'Terjadi kesalahan',
        'error': 'unknown_error',
      };
    }
  }

  /// -------------------------------
  /// GET ALL USERS (Regular Users)
  /// -------------------------------
  static Future<Map<String, dynamic>> getAllUsers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken') ?? '';

      if (token.isEmpty) {
        return {
          'success': false,
          'message': 'Belum login',
          'error': 'no_token',
        };
      }

      AppLogger.info('📡 [ADMIN] Get all users → $baseUrl/admin/users');

      final response = await http
          .get(
            Uri.parse('$baseUrl/admin/users'),
            headers: {
              'Authorization': 'Bearer $token',
              'Accept': 'application/json',
            },
          )
          .timeout(
            timeoutDuration,
            onTimeout: () {
              throw TimeoutException('Request timeout');
            },
          );

      AppLogger.info('📡 [ADMIN] Status: ${response.statusCode}');
      AppLogger.debug('📬 [ADMIN] Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data is! Map<String, dynamic>) {
          AppLogger.error('[ADMIN] Response bukan Map');
          return {'success': false, 'message': 'Format response tidak valid'};
        }

        return {'success': true, ...data};
      }

      if (response.statusCode == 401) {
        return {
          'success': false,
          'message': 'Sesi habis, silakan login kembali',
          'error': 'unauthorized',
        };
      }

      if (response.statusCode == 403) {
        return {
          'success': false,
          'message': 'Akses ditolak. Hanya admin yang dapat mengakses.',
          'error': 'forbidden',
        };
      }

      return {
        'success': false,
        'message': 'Terjadi kesalahan pada server',
        'error': 'server_error',
      };
    } on TimeoutException catch (e) {
      AppLogger.error('[ADMIN] Timeout: $e');
      return {
        'success': false,
        'message': 'Koneksi timeout',
        'error': 'timeout',
      };
    } on SocketException catch (e) {
      AppLogger.error('[ADMIN] Network error: $e');
      return {
        'success': false,
        'message': 'Tidak dapat terhubung ke server',
        'error': 'network_error',
      };
    } catch (e) {
      AppLogger.error('[ADMIN] Error: $e');
      return {
        'success': false,
        'message': 'Terjadi kesalahan',
        'error': 'unknown_error',
      };
    }
  }

  /// -------------------------------
  /// TOGGLE USER STATUS
  /// -------------------------------
  static Future<Map<String, dynamic>> toggleUserStatus(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken') ?? '';

      if (token.isEmpty) {
        return {
          'success': false,
          'message': 'Belum login',
          'error': 'no_token',
        };
      }

      AppLogger.info('📡 [ADMIN] Toggle user status → $baseUrl/admin/users/$userId/toggle-status');

      final response = await http
          .post(
            Uri.parse('$baseUrl/admin/users/$userId/toggle-status'),
            headers: {
              'Authorization': 'Bearer $token',
              'Accept': 'application/json',
              'Content-Type': 'application/json',
            },
          )
          .timeout(
            timeoutDuration,
            onTimeout: () {
              throw TimeoutException('Request timeout');
            },
          );

      AppLogger.info('📡 [ADMIN] Status: ${response.statusCode}');
      AppLogger.debug('📬 [ADMIN] Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data is! Map<String, dynamic>) {
          AppLogger.error('[ADMIN] Response bukan Map');
          return {'success': false, 'message': 'Format response tidak valid'};
        }

        return {'success': true, ...data};
      }

      if (response.statusCode == 401) {
        return {
          'success': false,
          'message': 'Sesi habis, silakan login kembali',
          'error': 'unauthorized',
        };
      }

      if (response.statusCode == 403) {
        return {
          'success': false,
          'message': 'Akses ditolak',
          'error': 'forbidden',
        };
      }

      return {
        'success': false,
        'message': 'Terjadi kesalahan pada server',
        'error': 'server_error',
      };
    } on TimeoutException catch (e) {
      AppLogger.error('[ADMIN] Timeout: $e');
      return {
        'success': false,
        'message': 'Koneksi timeout',
        'error': 'timeout',
      };
    } on SocketException catch (e) {
      AppLogger.error('[ADMIN] Network error: $e');
      return {
        'success': false,
        'message': 'Tidak dapat terhubung ke server',
        'error': 'network_error',
      };
    } catch (e) {
      AppLogger.error('[ADMIN] Error: $e');  
      return {
        'success': false,
        'message': 'Terjadi kesalahan',
        'error': 'unknown_error',
      };
    }
  }

  /// -------------------------------
  /// GET REPORT STATS
  /// -------------------------------
  static Future<Map<String, dynamic>> getReportStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken') ?? '';

      if (token.isEmpty) {
        return {
          'success': false,
          'message': 'Belum login',
          'error': 'no_token',
        };
      }

      AppLogger.info('📡 [ADMIN] Get report stats → $baseUrl/admin/reports/stats');

      final response = await http
          .get(
            Uri.parse('$baseUrl/admin/reports/stats'),
            headers: {
              'Authorization': 'Bearer $token',
              'Accept': 'application/json',
            },
          )
          .timeout(
            timeoutDuration,
            onTimeout: () {
              throw TimeoutException('Request timeout');
            },
          );

      AppLogger.info('📡 [ADMIN] Status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        return {'success': true, ...json.decode(response.body)};
      }

      return {
        'success': false,
        'message': 'Gagal mengambil data laporan',
        'error': 'server_error',
      };
    } catch (e) {
      AppLogger.error('[ADMIN] Error report stats: $e');
      return {
        'success': false,
        'message': 'Terjadi kesalahan jaringan',
        'error': 'unknown_error',
      };
    }
  }

  /// -------------------------------
  /// GET NOTIFICATIONS
  /// -------------------------------
  static Future<Map<String, dynamic>> getNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken') ?? '';

      if (token.isEmpty) {
        return {
          'success': false,
          'message': 'Belum login',
          'error': 'no_token',
        };
      }

      AppLogger.info('📡 [ADMIN] Get notifications → $baseUrl/admin/notifications');

      final response = await http.get(
        Uri.parse('$baseUrl/admin/notifications'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      ).timeout(timeoutDuration);

      AppLogger.info('📡 [ADMIN] Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        return {'success': true, ...json.decode(response.body)};
      }

      return {
        'success': false,
        'message': 'Gagal mengambil notifikasi',
      };
    } catch (e) {
      AppLogger.error('[ADMIN] Error notifications: $e');
      return {
        'success': false,
        'message': 'Terjadi kesalahan jaringan',
      };
    }
  }

  /// -------------------------------
  /// MARK NOTIFICATION AS READ
  /// -------------------------------
  static Future<Map<String, dynamic>> markNotificationAsRead(String notificationId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken') ?? '';

      AppLogger.info('📡 [ADMIN] Mark read → $baseUrl/admin/notifications/$notificationId/read');

      final response = await http.post(
        Uri.parse('$baseUrl/admin/notifications/$notificationId/read'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      ).timeout(timeoutDuration);

      if (response.statusCode == 200) {
        return {'success': true, ...json.decode(response.body)};
      }

      return {'success': false, 'message': 'Gagal update status'};
    } catch (e) {
      return {'success': false, 'message': 'Kesalahan jaringan'};
    }
  }

  /// -------------------------------
  /// GET PENDING SCHEDULES
  /// -------------------------------
  static Future<Map<String, dynamic>> getPendingSchedules() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken') ?? '';

      final response = await http.get(
        Uri.parse('$baseUrl/admin/schedules/pending'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      ).timeout(timeoutDuration);

      if (response.statusCode == 200) {
        return {'success': true, ...json.decode(response.body)};
      }
      return {'success': false, 'message': 'Gagal mengambil data'};
    } catch (e) {
      return {'success': false, 'message': 'Kesalahan jaringan'};
    }
  }

  /// -------------------------------
  /// APPROVE SCHEDULE
  /// -------------------------------
  static Future<Map<String, dynamic>> approveSchedule(String id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken') ?? '';

      final response = await http.post(
        Uri.parse('$baseUrl/admin/schedules/$id/approve'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      ).timeout(timeoutDuration);

      if (response.statusCode == 200) {
        return {'success': true, ...json.decode(response.body)};
      }
      return {'success': false, 'message': 'Gagal approve'};
    } catch (e) {
      return {'success': false, 'message': 'Kesalahan jaringan'};
    }
  }

  /// -------------------------------
  /// REJECT SCHEDULE
  /// -------------------------------
  static Future<Map<String, dynamic>> rejectSchedule(String id, String reason) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken') ?? '';

      final response = await http.post(
        Uri.parse('$baseUrl/admin/schedules/$id/reject'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: json.encode({'admin_notes': reason}),
      ).timeout(timeoutDuration);

      if (response.statusCode == 200) {
        return {'success': true, ...json.decode(response.body)};
      }
      return {'success': false, 'message': 'Gagal reject'};
    } catch (e) {
      return {'success': false, 'message': 'Kesalahan jaringan'};
    }
  }
}
