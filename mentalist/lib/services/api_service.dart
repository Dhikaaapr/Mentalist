import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/logger.dart';

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:8000/api';
  // Untuk testing di physical device, ganti dengan IP komputer Anda:
  // static const String baseUrl = 'http://192.168.x.x:8000/api';

  static const Duration timeoutDuration = Duration(seconds: 30);

  /// -------------------------------
  /// LOGIN WITH GOOGLE
  /// -------------------------------
  static Future<Map<String, dynamic>?> loginWithGoogle(String idToken) async {
    try {
      AppLogger.info('📡 Mengirim request ke: $baseUrl/auth/google/login');
      AppLogger.debug('🔑 ID Token length: ${idToken.length}');
      AppLogger.debug(
        '🔑 ID Token (first 50 chars): ${idToken.substring(0, idToken.length > 50 ? 50 : idToken.length)}...',
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
          .timeout(
            timeoutDuration,
            onTimeout: () {
              throw TimeoutException(
                'Request timeout. Pastikan backend berjalan dan dapat diakses.',
              );
            },
          );

      AppLogger.info('📡 Response status: ${response.statusCode}');
      AppLogger.debug('📬 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Validasi response structure
        if (data is! Map<String, dynamic>) {
          AppLogger.error('❌ Response bukan Map<String, dynamic>');
          return null;
        }

        // Store token jika ada
        if (data['token'] != null && data['token'].toString().isNotEmpty) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('accessToken', data['token'].toString());
          AppLogger.info('✅ Access token disimpan');
        }

        // Tambahkan success flag jika belum ada
        if (!data.containsKey('success')) {
          data['success'] = true;
        }

        return data;
      } else if (response.statusCode == 401) {
        AppLogger.error('❌ Unauthorized - ID Token tidak valid atau expired');
        return {
          'success': false,
          'message': 'Token Google tidak valid. Silakan coba lagi.',
          'error': 'unauthorized',
        };
      } else if (response.statusCode == 400) {
        AppLogger.error('❌ Bad Request');
        try {
          final errorData = json.decode(response.body);
          return {
            'success': false,
            'message':
                errorData['message'] ??
                errorData['error'] ??
                'Request tidak valid',
            'error': 'bad_request',
          };
        } catch (e) {
          return {
            'success': false,
            'message': 'Request tidak valid',
            'error': 'bad_request',
          };
        }
      } else {
        AppLogger.error('❌ API Error: ${response.statusCode}');
        try {
          final errorData = json.decode(response.body);
          return {
            'success': false,
            'message':
                errorData['message'] ??
                errorData['error'] ??
                'Terjadi kesalahan pada server',
            'error': 'server_error',
          };
        } catch (e) {
          return {
            'success': false,
            'message': 'Terjadi kesalahan pada server (${response.statusCode})',
            'error': 'server_error',
          };
        }
      }
    } on TimeoutException catch (e) {
      AppLogger.error('❌ Timeout: $e');
      return {
        'success': false,
        'message': 'Koneksi timeout. Server tidak merespons.',
        'error': 'timeout',
      };
    } on SocketException catch (e) {
      AppLogger.error('❌ Network Error: $e');
      AppLogger.info('💡 Troubleshooting:');
      AppLogger.info('   1. Pastikan backend Laravel berjalan (php artisan serve)');
      AppLogger.info('   2. Untuk emulator, gunakan http://10.0.2.2:8000');
      AppLogger.info(
        '   3. Untuk physical device, gunakan IP komputer (misal: http://192.168.1.100:8000)',
      );
      AppLogger.info('   4. Pastikan firewall tidak memblokir koneksi');

      return {
        'success': false,
        'message':
            'Tidak dapat terhubung ke server.\n'
            'Pastikan backend berjalan dan dapat diakses.',
        'error': 'network_error',
      };
    } on FormatException catch (e) {
      AppLogger.error('❌ Format Error: $e');
      return {
        'success': false,
        'message': 'Format response tidak valid dari server',
        'error': 'format_error',
      };
    } on http.ClientException catch (e) {
      AppLogger.error('❌ HTTP Client Error: $e');
      return {
        'success': false,
        'message': 'Gagal menghubungi server. Periksa koneksi internet Anda.',
        'error': 'client_error',
      };
    } catch (e) {
      AppLogger.error('❌ Unexpected Error: $e');
      return {
        'success': false,
        'message': 'Terjadi kesalahan: ${e.toString()}',
        'error': 'unknown_error',
      };
    }
  }

  /// -------------------------------
  /// GET USER PROFILE
  /// -------------------------------
  static Future<Map<String, dynamic>?> getProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('accessToken') ?? '';

      if (accessToken.isEmpty) {
        AppLogger.error('❌ No access token available');
        return {
          'success': false,
          'message': 'Anda belum login',
          'error': 'no_token',
        };
      }

      AppLogger.info('📡 Fetching user profile...');

      final response = await http
          .get(
            Uri.parse('$baseUrl/user'),
            headers: {
              'Authorization': 'Bearer $accessToken',
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          )
          .timeout(
            timeoutDuration,
            onTimeout: () {
              throw TimeoutException('Request timeout');
            },
          );

      AppLogger.info('📬 Profile response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        AppLogger.info('✅ Profile fetched successfully');
        return {'success': true, 'user': data};
      } else if (response.statusCode == 401) {
        AppLogger.error('❌ Token expired or invalid');
        // Clear token
        await prefs.remove('accessToken');
        return {
          'success': false,
          'message': 'Sesi Anda telah berakhir. Silakan login kembali.',
          'error': 'token_expired',
        };
      } else {
        AppLogger.error('❌ Error: ${response.statusCode} - ${response.body}');
        return {
          'success': false,
          'message': 'Gagal mengambil data profil',
          'error': 'fetch_error',
        };
      }
    } on TimeoutException catch (e) {
      AppLogger.error('❌ Timeout: $e');
      return {
        'success': false,
        'message': 'Koneksi timeout',
        'error': 'timeout',
      };
    } on SocketException catch (e) {
      AppLogger.error('❌ Network Error: $e');
      return {
        'success': false,
        'message': 'Tidak dapat terhubung ke server',
        'error': 'network_error',
      };
    } catch (e) {
      AppLogger.error('❌ Exception in getProfile: $e');
      return {
        'success': false,
        'message': 'Terjadi kesalahan: ${e.toString()}',
        'error': 'exception',
      };
    }
  }

  /// -------------------------------
  /// LOGOUT
  /// -------------------------------
  static Future<bool> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('accessToken') ?? '';

      // Jika ada token, coba logout dari backend
      if (accessToken.isNotEmpty) {
        try {
          await http
              .post(
                Uri.parse('$baseUrl/logout'),
                headers: {
                  'Authorization': 'Bearer $accessToken',
                  'Content-Type': 'application/json',
                  'Accept': 'application/json',
                },
              )
              .timeout(const Duration(seconds: 10));

          AppLogger.info('✅ Logged out from backend');
        } catch (e) {
          AppLogger.warning('⚠️ Backend logout failed, but clearing local token: $e');
        }
      }

      // Hapus token lokal
      await prefs.remove('accessToken');
      AppLogger.info('✅ Local token cleared');

      return true;
    } catch (e) {
      AppLogger.error('❌ Exception in logout: $e');
      // Tetap return true karena kita ingin clear local token
      return true;
    }
  }

  /// -------------------------------
  /// CHECK IF USER IS LOGGED IN
  /// -------------------------------
  static Future<bool> isLoggedIn() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('accessToken') ?? '';
      return accessToken.isNotEmpty;
    } catch (e) {
      AppLogger.error('❌ Error checking login status: $e');
      return false;
    }
  }

  /// -------------------------------
  /// GET STORED TOKEN
  /// -------------------------------
  static Future<String?> getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('accessToken');
    } catch (e) {
      AppLogger.error('❌ Error getting token: $e');
      return null;
    }
  }
}
