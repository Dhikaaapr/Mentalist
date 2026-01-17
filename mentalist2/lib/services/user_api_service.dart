import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/logger.dart';

class UserApiService {
  // static const String baseUrl = 'http://10.0.2.2:8000/api';

  // physical device
  static const String baseUrl = 'http://192.168.100.11:8000/api';

  static const Duration timeoutDuration = Duration(seconds: 30);

  /// -------------------------------
  /// GET USER PROFILE
  /// Includes counselor_profile if user is a konselor
  /// -------------------------------
  static Future<Map<String, dynamic>?> getProfile() async {
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

      AppLogger.info('📡 [USER] Get profile → $baseUrl/user');

      final response = await http
          .get(
            Uri.parse('$baseUrl/user'),
            headers: {
              'Authorization': 'Bearer $token',
              'Accept': 'application/json',
            },
          )
          .timeout(timeoutDuration);

      AppLogger.info('📡 [USER] Status: ${response.statusCode}');
      AppLogger.debug('📬 [USER] Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {'success': true, ...data};
      }

      if (response.statusCode == 401) {
        return {
          'success': false,
          'message': 'Sesi habis, silakan login kembali',
          'error': 'unauthorized',
        };
      }

      return {'success': false, 'message': 'Gagal mengambil profil'};
    } on TimeoutException catch (e) {
      AppLogger.error('[USER] Timeout: $e');
      return {
        'success': false,
        'message': 'Koneksi timeout',
        'error': 'timeout',
      };
    } on SocketException catch (e) {
      AppLogger.error('[USER] Network error: $e');
      return {
        'success': false,
        'message': 'Tidak dapat terhubung ke server',
        'error': 'network_error',
      };
    } catch (e) {
      AppLogger.error('[USER] Get profile error: $e');
      return {'success': false, 'message': 'Terjadi kesalahan'};
    }
  }

  /// -------------------------------
  /// UPDATE USER PROFILE
  /// For konselor, also updates counselor_profile fields
  /// -------------------------------
  static Future<Map<String, dynamic>?> updateProfile({
    String? name,
    String? picture,
    String? bio,
    String? specialization,
    bool? isAcceptingPatients,
  }) async {
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

      AppLogger.info('📡 [USER] Update profile → $baseUrl/user');

      final body = <String, dynamic>{};
      if (name != null) body['name'] = name;
      if (picture != null) body['picture'] = picture;
      if (bio != null) body['bio'] = bio;
      if (specialization != null) body['specialization'] = specialization;
      if (isAcceptingPatients != null) {
        body['is_accepting_patients'] = isAcceptingPatients.toString();
      }

      AppLogger.debug('📤 [USER] Body: $body');

      final response = await http
          .post(
            Uri.parse('$baseUrl/user'),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: json.encode(body),
          )
          .timeout(timeoutDuration);

      AppLogger.info('📡 [USER] Status: ${response.statusCode}');
      AppLogger.debug('📬 [USER] Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {'success': true, ...data};
      }

      if (response.statusCode == 401) {
        return {
          'success': false,
          'message': 'Sesi habis, silakan login kembali',
          'error': 'unauthorized',
        };
      }

      return {'success': false, 'message': 'Gagal mengupdate profil'};
    } on TimeoutException catch (e) {
      AppLogger.error('[USER] Timeout: $e');
      return {
        'success': false,
        'message': 'Koneksi timeout',
        'error': 'timeout',
      };
    } on SocketException catch (e) {
      AppLogger.error('[USER] Network error: $e');
      return {
        'success': false,
        'message': 'Tidak dapat terhubung ke server',
        'error': 'network_error',
      };
    } catch (e) {
      AppLogger.error('[USER] Update profile error: $e');
      return {'success': false, 'message': 'Terjadi kesalahan'};
    }
  }

  /// -------------------------------
  /// LOGOUT
  /// -------------------------------
  static Future<Map<String, dynamic>?> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken') ?? '';

      if (token.isEmpty) {
        // Just clear local storage
        await prefs.remove('accessToken');
        await prefs.remove('role');
        return {'success': true, 'message': 'Logout berhasil'};
      }

      AppLogger.info('📡 [USER] Logout → $baseUrl/logout');

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

      AppLogger.info('📡 [USER] Logout status: ${response.statusCode}');

      return {'success': true, 'message': 'Logout berhasil'};
    } catch (e) {
      // Still clear local storage on error
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('accessToken');
      await prefs.remove('role');

      AppLogger.error('[USER] Logout error: $e');
      return {'success': true, 'message': 'Logout berhasil'};
    }
  }
}
