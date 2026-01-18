import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/logger.dart';

class ChatApiService {
  // Emulator
  // static const String baseUrl = 'http://10.0.2.2:8000/api';

  // Physical device - Update this to your backend IP
  static const String baseUrl = 'http://192.168.100.11:8000/api';
  // static const String baseUrl = 'http://10.92.142.43:8000/api';

  static const Duration timeoutDuration = Duration(seconds: 30);

  /// Get auth token from SharedPreferences
  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('accessToken');
  }

  /// -------------------------------
  /// GET CHAT LIST (CONVERSATIONS)
  /// Returns list of confirmed booking chats
  /// -------------------------------
  static Future<Map<String, dynamic>> getChatList() async {
    try {
      final token = await _getToken();

      if (token == null || token.isEmpty) {
        AppLogger.error('[CHAT] No token found');
        return {
          'success': false,
          'message': 'Belum login',
          'error': 'no_token',
        };
      }

      final url = '$baseUrl/chats';
      AppLogger.info('📡 [CHAT] GET $url');

      final response = await http
          .get(
            Uri.parse(url),
            headers: {
              'Authorization': 'Bearer $token',
              'Accept': 'application/json',
            },
          )
          .timeout(timeoutDuration);

      AppLogger.info('📡 [CHAT] Response: ${response.statusCode}');
      AppLogger.debug('📬 [CHAT] Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {'success': true, 'data': data['data'] ?? []};
      }

      if (response.statusCode == 401) {
        return {
          'success': false,
          'message': 'Sesi berakhir, silakan login ulang',
          'error': 'unauthorized',
        };
      }

      // Try to parse error message
      try {
        final errorData = json.decode(response.body);
        return {
          'success': false,
          'message': errorData['message'] ?? 'Gagal mengambil daftar chat',
          'error': 'server_error',
        };
      } catch (_) {
        return {
          'success': false,
          'message': 'Gagal mengambil daftar chat (${response.statusCode})',
          'error': 'server_error',
        };
      }
    } on TimeoutException {
      AppLogger.error('[CHAT] Request timeout');
      return {
        'success': false,
        'message': 'Koneksi timeout',
        'error': 'timeout',
      };
    } on SocketException catch (e) {
      AppLogger.error('[CHAT] Network error: $e');
      return {
        'success': false,
        'message': 'Tidak dapat terhubung ke server',
        'error': 'network_error',
      };
    } catch (e, stack) {
      AppLogger.error('[CHAT] Error: $e\n$stack');
      return {
        'success': false,
        'message': 'Terjadi kesalahan: $e',
        'error': 'unknown_error',
      };
    }
  }

  /// -------------------------------
  /// GET MESSAGES FOR A BOOKING
  /// -------------------------------
  static Future<Map<String, dynamic>> getMessages(String bookingId) async {
    try {
      final token = await _getToken();

      if (token == null || token.isEmpty) {
        AppLogger.error('[CHAT] No token found');
        return {
          'success': false,
          'message': 'Belum login',
          'error': 'no_token',
        };
      }

      final url = '$baseUrl/chats/$bookingId/messages';
      AppLogger.info('📡 [CHAT] GET $url');

      final response = await http
          .get(
            Uri.parse(url),
            headers: {
              'Authorization': 'Bearer $token',
              'Accept': 'application/json',
            },
          )
          .timeout(timeoutDuration);

      AppLogger.info('📡 [CHAT] Response: ${response.statusCode}');
      AppLogger.debug('📬 [CHAT] Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {'success': true, 'data': data['data'] ?? []};
      }

      if (response.statusCode == 404) {
        return {
          'success': false,
          'message': 'Chat tidak ditemukan atau booking belum dikonfirmasi',
          'error': 'not_found',
        };
      }

      if (response.statusCode == 401) {
        return {
          'success': false,
          'message': 'Sesi berakhir, silakan login ulang',
          'error': 'unauthorized',
        };
      }

      return {
        'success': false,
        'message': 'Gagal mengambil pesan (${response.statusCode})',
        'error': 'server_error',
      };
    } on TimeoutException {
      AppLogger.error('[CHAT] Request timeout');
      return {
        'success': false,
        'message': 'Koneksi timeout',
        'error': 'timeout',
      };
    } on SocketException catch (e) {
      AppLogger.error('[CHAT] Network error: $e');
      return {
        'success': false,
        'message': 'Tidak dapat terhubung ke server',
        'error': 'network_error',
      };
    } catch (e, stack) {
      AppLogger.error('[CHAT] Error: $e\n$stack');
      return {
        'success': false,
        'message': 'Terjadi kesalahan: $e',
        'error': 'unknown_error',
      };
    }
  }

  /// -------------------------------
  /// SEND MESSAGE
  /// -------------------------------
  static Future<Map<String, dynamic>> sendMessage({
    required String bookingId,
    required String content,
    String messageType = 'text',
  }) async {
    try {
      final token = await _getToken();

      if (token == null || token.isEmpty) {
        AppLogger.error('[CHAT] No token found');
        return {
          'success': false,
          'message': 'Belum login',
          'error': 'no_token',
        };
      }

      final url = '$baseUrl/chats/$bookingId/messages';
      AppLogger.info('📡 [CHAT] POST $url');
      AppLogger.debug('📤 [CHAT] Sending: content=$content, type=$messageType');

      final response = await http
          .post(
            Uri.parse(url),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: json.encode({
              'content': content,
              'message_type': messageType,
            }),
          )
          .timeout(timeoutDuration);

      AppLogger.info('📡 [CHAT] Response: ${response.statusCode}');
      AppLogger.debug('📬 [CHAT] Body: ${response.body}');

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'message': 'Pesan terkirim',
          'data': data['data'],
        };
      }

      if (response.statusCode == 404) {
        return {
          'success': false,
          'message': 'Booking tidak ditemukan atau belum dikonfirmasi',
          'error': 'not_found',
        };
      }

      if (response.statusCode == 401) {
        return {
          'success': false,
          'message': 'Sesi berakhir, silakan login ulang',
          'error': 'unauthorized',
        };
      }

      if (response.statusCode == 422) {
        try {
          final errorData = json.decode(response.body);
          return {
            'success': false,
            'message': errorData['message'] ?? 'Pesan tidak valid',
            'error': 'validation_error',
          };
        } catch (_) {
          return {
            'success': false,
            'message': 'Pesan tidak valid',
            'error': 'validation_error',
          };
        }
      }

      // Try to parse error response
      try {
        final errorData = json.decode(response.body);
        return {
          'success': false,
          'message': errorData['message'] ?? 'Gagal mengirim pesan',
          'error': 'server_error',
        };
      } catch (_) {
        return {
          'success': false,
          'message': 'Gagal mengirim pesan (${response.statusCode})',
          'error': 'server_error',
        };
      }
    } on TimeoutException {
      AppLogger.error('[CHAT] Request timeout');
      return {
        'success': false,
        'message': 'Koneksi timeout',
        'error': 'timeout',
      };
    } on SocketException catch (e) {
      AppLogger.error('[CHAT] Network error: $e');
      return {
        'success': false,
        'message': 'Tidak dapat terhubung ke server',
        'error': 'network_error',
      };
    } catch (e, stack) {
      AppLogger.error('[CHAT] Error: $e\n$stack');
      return {
        'success': false,
        'message': 'Terjadi kesalahan: $e',
        'error': 'unknown_error',
      };
    }
  }
}
