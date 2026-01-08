import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/logger.dart';

class CounselorApiService {
  static const String baseUrl = 'http://10.0.2.2:8000/api';

  // physical device
  // static const String baseUrl = 'http://192.168.1.15:8000/api';

  static const Duration timeoutDuration = Duration(seconds: 30);

  /// -------------------------------
  /// GET AVAILABLE COUNSELORS
  /// Returns list of counselors who are accepting patients
  /// -------------------------------
  static Future<Map<String, dynamic>?> getAvailableCounselors() async {
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

      AppLogger.info('📡 [COUNSELOR] Get available → $baseUrl/counselors/available');

      final response = await http
          .get(
            Uri.parse('$baseUrl/counselors/available'),
            headers: {
              'Authorization': 'Bearer $token',
              'Accept': 'application/json',
            },
          )
          .timeout(timeoutDuration);

      AppLogger.info('📡 [COUNSELOR] Status: ${response.statusCode}');
      AppLogger.debug('📬 [COUNSELOR] Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {'success': true, 'data': data['data'] ?? []};
      }

      if (response.statusCode == 401) {
        return {
          'success': false,
          'message': 'Sesi habis, silakan login kembali',
          'error': 'unauthorized',
        };
      }

      return {'success': false, 'message': 'Gagal mengambil daftar konselor'};
    } on TimeoutException catch (e) {
      AppLogger.error('[COUNSELOR] Timeout: $e');
      return {'success': false, 'message': 'Koneksi timeout'};
    } on SocketException catch (e) {
      AppLogger.error('[COUNSELOR] Network error: $e');
      return {'success': false, 'message': 'Tidak dapat terhubung ke server'};
    } catch (e) {
      AppLogger.error('[COUNSELOR] Error: $e');
      return {'success': false, 'message': 'Terjadi kesalahan'};
    }
  }

  /// -------------------------------
  /// GET COUNSELOR DETAIL
  /// -------------------------------
  static Future<Map<String, dynamic>?> getCounselorDetail(String id) async {
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

      AppLogger.info('📡 [COUNSELOR] Get detail → $baseUrl/counselors/$id');

      final response = await http
          .get(
            Uri.parse('$baseUrl/counselors/$id'),
            headers: {
              'Authorization': 'Bearer $token',
              'Accept': 'application/json',
            },
          )
          .timeout(timeoutDuration);

      AppLogger.info('📡 [COUNSELOR] Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {'success': true, 'data': data['data']};
      }

      return {'success': false, 'message': 'Konselor tidak ditemukan'};
    } on TimeoutException catch (e) {
      AppLogger.error('[COUNSELOR] Timeout: $e');
      return {'success': false, 'message': 'Koneksi timeout'};
    } on SocketException catch (e) {
      AppLogger.error('[COUNSELOR] Network error: $e');
      return {'success': false, 'message': 'Tidak dapat terhubung ke server'};
    } catch (e) {
      AppLogger.error('[COUNSELOR] Error: $e');
      return {'success': false, 'message': 'Terjadi kesalahan'};
    }
  }
}
