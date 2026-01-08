import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/logger.dart';

class BookingApiService {
  static const String baseUrl = 'http://10.0.2.2:8000/api';

  // physical device
  // static const String baseUrl = 'http://192.168.1.15:8000/api';

  static const Duration timeoutDuration = Duration(seconds: 30);

  /// -------------------------------
  /// CREATE BOOKING
  /// -------------------------------
  static Future<Map<String, dynamic>?> createBooking({
    required String counselorId,
    required DateTime scheduledAt,
    String? notes,
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

      AppLogger.info('📡 [BOOKING] Create → $baseUrl/bookings');

      final body = {
        'counselor_id': counselorId,
        'scheduled_at': scheduledAt.toUtc().toIso8601String(),
        if (notes != null && notes.isNotEmpty) 'notes': notes,
      };

      AppLogger.debug('📤 [BOOKING] Body: $body');

      final response = await http
          .post(
            Uri.parse('$baseUrl/bookings'),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: json.encode(body),
          )
          .timeout(timeoutDuration);

      AppLogger.info('📡 [BOOKING] Status: ${response.statusCode}');
      AppLogger.debug('📬 [BOOKING] Body: ${response.body}');

      final data = json.decode(response.body);

      if (response.statusCode == 201) {
        return {'success': true, 'message': 'Booking berhasil', 'data': data};
      }

      if (response.statusCode == 422) {
        String errorMsg = 'Validasi gagal';
        if (data['errors'] != null) {
          final errors = data['errors'] as Map;
          if (errors.isNotEmpty) {
            final firstError = errors.values.first;
            if (firstError is List && firstError.isNotEmpty) {
              errorMsg = firstError.first.toString();
            }
          }
        } else if (data['message'] != null) {
          errorMsg = data['message'];
        }
        return {'success': false, 'message': errorMsg};
      }

      return {
        'success': false,
        'message': data['message'] ?? 'Gagal membuat booking',
      };
    } on TimeoutException catch (e) {
      AppLogger.error('[BOOKING] Timeout: $e');
      return {'success': false, 'message': 'Koneksi timeout'};
    } on SocketException catch (e) {
      AppLogger.error('[BOOKING] Network error: $e');
      return {'success': false, 'message': 'Tidak dapat terhubung ke server'};
    } catch (e) {
      AppLogger.error('[BOOKING] Error: $e');
      return {'success': false, 'message': 'Terjadi kesalahan'};
    }
  }

  /// -------------------------------
  /// GET BOOKINGS LIST
  /// -------------------------------
  static Future<Map<String, dynamic>?> getBookings({String? status}) async {
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

      String url = '$baseUrl/bookings';
      if (status != null && status.isNotEmpty) {
        url += '?status=$status';
      }

      AppLogger.info('📡 [BOOKING] Get list → $url');

      final response = await http
          .get(
            Uri.parse(url),
            headers: {
              'Authorization': 'Bearer $token',
              'Accept': 'application/json',
            },
          )
          .timeout(timeoutDuration);

      AppLogger.info('📡 [BOOKING] Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {'success': true, 'data': data['data'] ?? []};
      }

      return {'success': false, 'message': 'Gagal mengambil daftar booking'};
    } on TimeoutException catch (e) {
      AppLogger.error('[BOOKING] Timeout: $e');
      return {'success': false, 'message': 'Koneksi timeout'};
    } on SocketException catch (e) {
      AppLogger.error('[BOOKING] Network error: $e');
      return {'success': false, 'message': 'Tidak dapat terhubung ke server'};
    } catch (e) {
      AppLogger.error('[BOOKING] Error: $e');
      return {'success': false, 'message': 'Terjadi kesalahan'};
    }
  }

  /// -------------------------------
  /// GET BOOKING DETAIL
  /// -------------------------------
  static Future<Map<String, dynamic>?> getBookingDetail(String id) async {
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

      AppLogger.info('📡 [BOOKING] Get detail → $baseUrl/bookings/$id');

      final response = await http
          .get(
            Uri.parse('$baseUrl/bookings/$id'),
            headers: {
              'Authorization': 'Bearer $token',
              'Accept': 'application/json',
            },
          )
          .timeout(timeoutDuration);

      AppLogger.info('📡 [BOOKING] Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {'success': true, 'data': data['data']};
      }

      return {'success': false, 'message': 'Booking tidak ditemukan'};
    } on TimeoutException catch (e) {
      AppLogger.error('[BOOKING] Timeout: $e');
      return {'success': false, 'message': 'Koneksi timeout'};
    } on SocketException catch (e) {
      AppLogger.error('[BOOKING] Network error: $e');
      return {'success': false, 'message': 'Tidak dapat terhubung ke server'};
    } catch (e) {
      AppLogger.error('[BOOKING] Error: $e');
      return {'success': false, 'message': 'Terjadi kesalahan'};
    }
  }

  /// -------------------------------
  /// CANCEL BOOKING
  /// -------------------------------
  static Future<Map<String, dynamic>?> cancelBooking(String id) async {
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

      AppLogger.info('📡 [BOOKING] Cancel → $baseUrl/bookings/$id/cancel');

      final response = await http
          .post(
            Uri.parse('$baseUrl/bookings/$id/cancel'),
            headers: {
              'Authorization': 'Bearer $token',
              'Accept': 'application/json',
            },
          )
          .timeout(timeoutDuration);

      AppLogger.info('📡 [BOOKING] Status: ${response.statusCode}');

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        return {'success': true, 'message': 'Booking dibatalkan'};
      }

      return {
        'success': false,
        'message': data['message'] ?? 'Gagal membatalkan booking',
      };
    } on TimeoutException catch (e) {
      AppLogger.error('[BOOKING] Timeout: $e');
      return {'success': false, 'message': 'Koneksi timeout'};
    } on SocketException catch (e) {
      AppLogger.error('[BOOKING] Network error: $e');
      return {'success': false, 'message': 'Tidak dapat terhubung ke server'};
    } catch (e) {
      AppLogger.error('[BOOKING] Error: $e');
      return {'success': false, 'message': 'Terjadi kesalahan'};
    }
  }

  /// -------------------------------
  /// RESCHEDULE BOOKING
  /// -------------------------------
  static Future<Map<String, dynamic>?> rescheduleBooking(
    String id,
    DateTime newScheduledAt,
  ) async {
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

      AppLogger.info('📡 [BOOKING] Reschedule → $baseUrl/bookings/$id/reschedule');

      final body = {
        'scheduled_at': newScheduledAt.toUtc().toIso8601String(),
      };

      final response = await http
          .post(
            Uri.parse('$baseUrl/bookings/$id/reschedule'),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: json.encode(body),
          )
          .timeout(timeoutDuration);

      AppLogger.info('📡 [BOOKING] Status: ${response.statusCode}');

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        return {'success': true, 'message': 'Jadwal berhasil diubah'};
      }

      return {
        'success': false,
        'message': data['message'] ?? 'Gagal mengubah jadwal',
      };
    } on TimeoutException catch (e) {
      AppLogger.error('[BOOKING] Timeout: $e');
      return {'success': false, 'message': 'Koneksi timeout'};
    } on SocketException catch (e) {
      AppLogger.error('[BOOKING] Network error: $e');
      return {'success': false, 'message': 'Tidak dapat terhubung ke server'};
    } catch (e) {
      AppLogger.error('[BOOKING] Error: $e');
      return {'success': false, 'message': 'Terjadi kesalahan'};
    }
  }
}
