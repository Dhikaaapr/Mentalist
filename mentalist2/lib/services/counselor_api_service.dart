import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/logger.dart';

class CounselorApiService {
  // static const String baseUrl = 'http://10.0.2.2:8000/api';

  // physical device
  // static const String baseUrl = 'http://10.92.142.43:8000/api';
  static const String baseUrl = 'http://192.168.100.11:8000/api';
  static const Duration timeoutDuration = Duration(seconds: 30);

  /// -------------------------------
  /// LOGIN MANUAL KONSELOR
  /// -------------------------------
  static Future<Map<String, dynamic>?> login(
    String email,
    String password,
  ) async {
    try {
      AppLogger.info('📡 [COUNSELOR] Request → $baseUrl/auth/login');

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

      AppLogger.info('📡 [COUNSELOR] Status: ${response.statusCode}');
      AppLogger.debug('📬 [COUNSELOR] Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data is! Map<String, dynamic>) {
          AppLogger.error('[COUNSELOR] Response bukan Map');
          return null;
        }

        // Simpan token
        if (data['token'] != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('accessToken', data['token']);

          String userRole = 'konselor';
          if (data['user'] != null && data['user']['role'] != null) {
            userRole = data['user']['role']['name'] ?? 'konselor';
          }
          await prefs.setString('role', userRole);

          AppLogger.info('[COUNSELOR] Token disimpan dengan role: $userRole');
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
          'message': 'Akun konselor tidak aktif',
          'error': 'forbidden',
        };
      }

      return {
        'success': false,
        'message': 'Terjadi kesalahan pada server',
        'error': 'server_error',
      };
    } on TimeoutException catch (e) {
      AppLogger.error('[COUNSELOR] Timeout: $e');
      return {
        'success': false,
        'message': 'Koneksi timeout',
        'error': 'timeout',
      };
    } on SocketException catch (e) {
      AppLogger.error('[COUNSELOR] Network error: $e');
      return {
        'success': false,
        'message': 'Tidak dapat terhubung ke server',
        'error': 'network_error',
      };
    } catch (e) {
      AppLogger.error('[COUNSELOR] Error: $e');
      return {
        'success': false,
        'message': 'Terjadi kesalahan',
        'error': 'unknown_error',
      };
    }
  }

  /// -------------------------------
  /// LOGIN KONSELOR WITH GOOGLE
  /// -------------------------------
  static Future<Map<String, dynamic>?> loginWithGoogle(String idToken) async {
    try {
      AppLogger.info(
        '📡 [COUNSELOR] Google login → $baseUrl/auth/google/login',
      );

      final response = await http
          .post(
            Uri.parse('$baseUrl/auth/google/login'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: json.encode({'id_token': idToken}),
          )
          .timeout(timeoutDuration);

      AppLogger.info('📡 [COUNSELOR] Status: ${response.statusCode}');
      AppLogger.debug('📬 [COUNSELOR] Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('accessToken', data['token']);

        // Simpan role dari backend (biasanya 'konselor')
        String userRole = 'konselor';
        if (data['user'] != null && data['user']['role'] != null) {
          userRole = data['user']['role']['name'] ?? 'konselor';
        }
        await prefs.setString('role', userRole);

        data['success'] = true;
        return data;
      }

      if (response.statusCode == 401) {
        return {
          'success': false,
          'message': 'Akun Google tidak terdaftar sebagai konselor',
          'error': 'unauthorized',
        };
      }

      return {
        'success': false,
        'message': 'Login Google gagal',
        'error': 'server_error',
      };
    } catch (e) {
      AppLogger.error('[COUNSELOR] Google login error: $e');
      return {
        'success': false,
        'message': 'Terjadi kesalahan saat login Google',
        'error': 'unknown_error',
      };
    }
  }

  /// -------------------------------
  /// GET TODAY BOOKINGS
  /// -------------------------------
  static Future<Map<String, dynamic>> getTodayBookings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken') ?? '';

      if (token.isEmpty) {
        return {'success': false, 'message': 'Token tidak ditemukan'};
      }

      AppLogger.info(
        '📡 [COUNSELOR] Get today bookings → $baseUrl/bookings/today',
      );

      final response = await http
          .get(
            Uri.parse('$baseUrl/bookings/today'),
            headers: {
              'Authorization': 'Bearer $token',
              'Accept': 'application/json',
            },
          )
          .timeout(timeoutDuration);

      if (response.statusCode == 200) {
        return {'success': true, ...json.decode(response.body)};
      }
      return {'success': false, 'message': 'Gagal mengambil data'};
    } catch (e) {
      AppLogger.error('[COUNSELOR] Error today bookings: $e');
      return {'success': false, 'message': 'Kesalahan jaringan'};
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
        return {'success': false, 'message': 'Token tidak ditemukan'};
      }

      final response = await http
          .get(
            Uri.parse('$baseUrl/counselor/notifications'),
            headers: {
              'Authorization': 'Bearer $token',
              'Accept': 'application/json',
            },
          )
          .timeout(timeoutDuration);

      if (response.statusCode == 200) {
        return {'success': true, ...json.decode(response.body)};
      }
      return {'success': false, 'message': 'Gagal mengambil notifikasi'};
    } catch (e) {
      return {'success': false, 'message': 'Kesalahan jaringan'};
    }
  }

  /// -------------------------------
  /// MARK NOTIFICATION AS READ
  /// -------------------------------
  static Future<Map<String, dynamic>> markNotificationAsRead(String id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken') ?? '';

      if (token.isEmpty) {
        return {'success': false, 'message': 'Token tidak ditemukan'};
      }

      final response = await http
          .post(
            Uri.parse('$baseUrl/counselor/notifications/$id/read'),
            headers: {
              'Authorization': 'Bearer $token',
              'Accept': 'application/json',
            },
          )
          .timeout(timeoutDuration);

      if (response.statusCode == 200) {
        return {'success': true, ...json.decode(response.body)};
      }
      return {'success': false, 'message': 'Gagal memproses'};
    } catch (e) {
      return {'success': false, 'message': 'Kesalahan jaringan'};
    }
  }

  /// -------------------------------
  /// CHECK IF WEEKLY SETUP DONE
  /// -------------------------------
  static Future<Map<String, dynamic>> hasWeeklySetup() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken') ?? '';

      if (token.isEmpty) {
        return {'success': false, 'has_setup': false};
      }

      AppLogger.info(
        '📡 [COUNSELOR] Check weekly setup → $baseUrl/counselor/weekly-availability/check',
      );

      final response = await http
          .get(
            Uri.parse('$baseUrl/counselor/weekly-availability/check'),
            headers: {
              'Authorization': 'Bearer $token',
              'Accept': 'application/json',
            },
          )
          .timeout(timeoutDuration);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {'success': true, 'has_setup': data['has_setup'] ?? false};
      }
      return {'success': false, 'has_setup': false};
    } catch (e) {
      AppLogger.error('[COUNSELOR] Error checking weekly setup: $e');
      return {'success': false, 'has_setup': false};
    }
  }

  /// -------------------------------
  /// SAVE WEEKLY AVAILABILITY
  /// -------------------------------
  static Future<Map<String, dynamic>> saveWeeklyAvailability(
    List<Map<String, dynamic>> schedules,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken') ?? '';

      if (token.isEmpty) {
        return {'success': false, 'message': 'Token tidak ditemukan'};
      }

      AppLogger.info(
        '📡 [COUNSELOR] Save weekly availability → $baseUrl/counselor/weekly-availability',
      );

      final response = await http
          .post(
            Uri.parse('$baseUrl/counselor/weekly-availability'),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: json.encode({'schedules': schedules}),
          )
          .timeout(timeoutDuration);

      AppLogger.info('📡 [COUNSELOR] Status: ${response.statusCode}');
      AppLogger.debug('📬 [COUNSELOR] Body: ${response.body}');

      final data = json.decode(response.body);

      if (response.statusCode == 201) {
        return {
          'success': true,
          'message': data['message'],
          'data': data['data'],
        };
      }

      return {
        'success': false,
        'message': data['message'] ?? 'Gagal menyimpan jadwal',
      };
    } catch (e) {
      AppLogger.error('[COUNSELOR] Error saving weekly availability: $e');
      return {'success': false, 'message': 'Kesalahan jaringan'};
    }
  }

  /// -------------------------------
  /// GET WEEKLY AVAILABILITY
  /// -------------------------------
  static Future<Map<String, dynamic>> getWeeklyAvailability() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken') ?? '';

      if (token.isEmpty) {
        return {'success': false, 'message': 'Token tidak ditemukan'};
      }

      final response = await http
          .get(
            Uri.parse('$baseUrl/counselor/weekly-availability'),
            headers: {
              'Authorization': 'Bearer $token',
              'Accept': 'application/json',
            },
          )
          .timeout(timeoutDuration);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {'success': true, 'data': data['data']};
      }
      return {'success': false, 'message': 'Gagal memuat jadwal'};
    } catch (e) {
      return {'success': false, 'message': 'Kesalahan jaringan'};
    }
  }

  /// -------------------------------
  /// GET DASHBOARD STATS
  /// -------------------------------
  static Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken') ?? '';

      if (token.isEmpty) {
        return {'success': false, 'message': 'Token tidak ditemukan'};
      }

      AppLogger.info(
        '📡 [COUNSELOR] Get dashboard stats → $baseUrl/counselor/dashboard-stats',
      );

      final response = await http
          .get(
            Uri.parse('$baseUrl/counselor/dashboard-stats'),
            headers: {
              'Authorization': 'Bearer $token',
              'Accept': 'application/json',
            },
          )
          .timeout(timeoutDuration);

      AppLogger.info('📡 [COUNSELOR] Stats Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {'success': true, 'data': data['data']};
      }
      return {'success': false, 'message': 'Gagal mengambil statistik'};
    } catch (e) {
      AppLogger.error('[COUNSELOR] Error dashboard stats: $e');
      return {'success': false, 'message': 'Kesalahan jaringan'};
    }
  }
}
