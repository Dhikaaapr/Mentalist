import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../utils/logger.dart';

class AdminApiService {
  // emulator
  // static const String baseUrl = 'http://10.0.2.2:8000/api';

  // physical device
  static const String baseUrl = 'http://192.168.1.17:8000/api';

  static const Duration timeoutDuration = Duration(seconds: 30);

  /// -------------------------------
  /// LOGIN ADMIN
  /// -------------------------------
  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    try {
      AppLogger.info('📡 [ADMIN] Request → $baseUrl/auth/admin/login');

      final response = await http
          .post(
            Uri.parse('$baseUrl/auth/admin/login'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: json.encode({'email': email, 'password': password}),
          )
          .timeout(timeoutDuration);

      AppLogger.info('📡 [ADMIN] Status: ${response.statusCode}');
      AppLogger.debug('📬 [ADMIN] Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data is! Map<String, dynamic>) {
          return {'success': false, 'message': 'Format response tidak valid'};
        }

        data['success'] = true;
        return data;
      }

      if (response.statusCode == 401) {
        return {'success': false, 'message': 'Email atau password salah'};
      }

      if (response.statusCode == 403) {
        return {'success': false, 'message': 'Akun admin tidak aktif'};
      }

      return {'success': false, 'message': 'Terjadi kesalahan server'};
    } on TimeoutException {
      return {'success': false, 'message': 'Koneksi timeout'};
    } on SocketException {
      return {'success': false, 'message': 'Tidak dapat terhubung ke server'};
    } catch (e) {
      AppLogger.error(e);
      return {'success': false, 'message': 'Terjadi kesalahan'};
    }
  }
}
