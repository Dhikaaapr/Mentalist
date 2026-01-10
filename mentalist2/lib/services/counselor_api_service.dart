import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/logger.dart';

class CounselorApiService {
  // static const String baseUrl = 'http://10.0.2.2:8000/api';

  // physical device
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
          await prefs.setString('role', 'counselor');
          AppLogger.info('[COUNSELOR] Token disimpan');
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
        await prefs.setString('role', 'counselor');

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
}
