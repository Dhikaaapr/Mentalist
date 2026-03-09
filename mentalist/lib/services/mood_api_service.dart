import 'dart:convert';

import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/logger.dart';

class MoodApiService {
  static const String baseUrl = 'http://192.168.23.205:8000/api';
  static const Duration timeoutDuration = Duration(seconds: 30);

  /// -------------------------------
  /// GET WEEKLY MOOD
  /// -------------------------------
  static Future<Map<String, dynamic>> getWeeklyMood() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken') ?? '';

      if (token.isEmpty) {
        return {'success': false, 'message': 'Belum login'};
      }

      AppLogger.info('📡 [MOOD] Fetching weekly mood...');

      final response = await http
          .get(
            Uri.parse('$baseUrl/moods'),
            headers: {
              'Authorization': 'Bearer $token',
              'Accept': 'application/json',
            },
          )
          .timeout(timeoutDuration);

      AppLogger.info('📡 [MOOD] Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {'success': true, 'data': data['data']};
      }

      return {'success': false, 'message': 'Gagal mengambil data mood'};
    } catch (e) {
      AppLogger.error('[MOOD] Error: $e');
      return {'success': false, 'message': 'Terjadi kesalahan'};
    }
  }

  /// -------------------------------
  /// SAVE MOOD
  /// -------------------------------
  static Future<Map<String, dynamic>> saveMood(
    String mood,
    DateTime date,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken') ?? '';

      if (token.isEmpty) {
        return {'success': false, 'message': 'Belum login'};
      }

      AppLogger.info('📡 [MOOD] Saving mood: $mood for $date');

      final response = await http
          .post(
            Uri.parse('$baseUrl/moods'),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: json.encode({'mood': mood, 'date': date.toIso8601String()}),
          )
          .timeout(timeoutDuration);

      AppLogger.info('📡 [MOOD] Save Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        return {'success': true, 'message': 'Mood disimpan'};
      }

      return {'success': false, 'message': 'Gagal menyimpan mood'};
    } catch (e) {
      AppLogger.error('[MOOD] Save Error: $e');
      return {'success': false, 'message': 'Terjadi kesalahan'};
    }
  }
}
