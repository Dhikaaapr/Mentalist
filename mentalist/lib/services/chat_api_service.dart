import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/logger.dart';

class ChatApiService {
  // static const String baseUrl = 'http://10.0.2.2:8000/api';

  // physical device
  static const String baseUrl = 'http://10.0.60.110:8000/api';

  static const Duration timeoutDuration = Duration(seconds: 30);

  /// -------------------------------
  /// GET CHAT LIST (CONVERSATIONS)
  /// Returns list of confirmed booking chats
  /// -------------------------------
  static Future<Map<String, dynamic>> getChatList() async {
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

      AppLogger.info('📡 [CHAT] Get list → $baseUrl/chats');

      final response = await http
          .get(
            Uri.parse('$baseUrl/chats'),
            headers: {
              'Authorization': 'Bearer $token',
              'Accept': 'application/json',
            },
          )
          .timeout(timeoutDuration);

      AppLogger.info('📡 [CHAT] Status: ${response.statusCode}');
      AppLogger.debug('📬 [CHAT] Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'data': data['data'] ?? [],
        };
      }

      return {
        'success': false,
        'message': 'Gagal mengambil daftar chat',
      };
    } on TimeoutException catch (e) {
      AppLogger.error('[CHAT] Timeout: $e');
      return {'success': false, 'message': 'Koneksi timeout'};
    } on SocketException catch (e) {
      AppLogger.error('[CHAT] Network error: $e');
      return {'success': false, 'message': 'Tidak dapat terhubung ke server'};
    } catch (e) {
      AppLogger.error('[CHAT] Error: $e');
      return {'success': false, 'message': 'Terjadi kesalahan'};
    }
  }

  /// -------------------------------
  /// GET MESSAGES FOR A BOOKING
  /// -------------------------------
  static Future<Map<String, dynamic>> getMessages(String bookingId) async {
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

      AppLogger.info('📡 [CHAT] Get messages → $baseUrl/chats/$bookingId/messages');

      final response = await http
          .get(
            Uri.parse('$baseUrl/chats/$bookingId/messages'),
            headers: {
              'Authorization': 'Bearer $token',
              'Accept': 'application/json',
            },
          )
          .timeout(timeoutDuration);

      AppLogger.info('📡 [CHAT] Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'data': data['data'] ?? [],
        };
      }

      if (response.statusCode == 404) {
        return {
          'success': false,
          'message': 'Chat tidak ditemukan',
        };
      }

      return {
        'success': false,
        'message': 'Gagal mengambil pesan',
      };
    } on TimeoutException catch (e) {
      AppLogger.error('[CHAT] Timeout: $e');
      return {'success': false, 'message': 'Koneksi timeout'};
    } on SocketException catch (e) {
      AppLogger.error('[CHAT] Network error: $e');
      return {'success': false, 'message': 'Tidak dapat terhubung ke server'};
    } catch (e) {
      AppLogger.error('[CHAT] Error: $e');
      return {'success': false, 'message': 'Terjadi kesalahan'};
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
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken') ?? '';

      if (token.isEmpty) {
        return {
          'success': false,
          'message': 'Belum login',
          'error': 'no_token',
        };
      }

      AppLogger.info('📡 [CHAT] Send message → $baseUrl/chats/$bookingId/messages');

      final response = await http
          .post(
            Uri.parse('$baseUrl/chats/$bookingId/messages'),
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

      AppLogger.info('📡 [CHAT] Status: ${response.statusCode}');

      final data = json.decode(response.body);

      if (response.statusCode == 201) {
        return {
          'success': true,
          'message': 'Pesan terkirim',
          'data': data['data'],
        };
      }

      return {
        'success': false,
        'message': data['message'] ?? 'Gagal mengirim pesan',
      };
    } on TimeoutException catch (e) {
      AppLogger.error('[CHAT] Timeout: $e');
      return {'success': false, 'message': 'Koneksi timeout'};
    } on SocketException catch (e) {
      AppLogger.error('[CHAT] Network error: $e');
      return {'success': false, 'message': 'Tidak dapat terhubung ke server'};
    } catch (e) {
      AppLogger.error('[CHAT] Error: $e');
      return {'success': false, 'message': 'Terjadi kesalahan'};
    }
  }
}
