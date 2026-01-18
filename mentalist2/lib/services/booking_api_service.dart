import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class BookingApiService {
  // static const String baseUrl = 'http://10.0.2.2:8000/api';
  static const String baseUrl = 'http://192.168.100.11:8000/api';
  //  static const String baseUrl = 'http://10.92.142.43:8000/api';
  static const Duration timeoutDuration = Duration(seconds: 30);

  /// GET BOOKINGS (for counselor - shows bookings assigned to them)
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

      final response = await http
          .get(
            Uri.parse(url),
            headers: {
              'Authorization': 'Bearer $token',
              'Accept': 'application/json',
            },
          )
          .timeout(timeoutDuration);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {'success': true, 'data': data['data'] ?? []};
      }

      return {'success': false, 'message': 'Gagal mengambil daftar booking'};
    } on TimeoutException {
      return {'success': false, 'message': 'Koneksi timeout'};
    } on SocketException {
      return {'success': false, 'message': 'Tidak dapat terhubung ke server'};
    } catch (e) {
      return {'success': false, 'message': 'Terjadi kesalahan'};
    }
  }

  /// CONFIRM BOOKING (counselor accepts)
  static Future<Map<String, dynamic>?> confirmBooking(String id) async {
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

      final response = await http
          .post(
            Uri.parse('$baseUrl/bookings/$id/confirm'),
            headers: {
              'Authorization': 'Bearer $token',
              'Accept': 'application/json',
            },
          )
          .timeout(timeoutDuration);

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        return {'success': true, 'message': 'Booking berhasil dikonfirmasi'};
      }

      return {
        'success': false,
        'message': data['message'] ?? 'Gagal konfirmasi',
      };
    } on TimeoutException {
      return {'success': false, 'message': 'Koneksi timeout'};
    } on SocketException {
      return {'success': false, 'message': 'Tidak dapat terhubung ke server'};
    } catch (e) {
      return {'success': false, 'message': 'Terjadi kesalahan'};
    }
  }

  /// REJECT BOOKING (counselor declines)
  static Future<Map<String, dynamic>?> rejectBooking(
    String id, {
    String? reason,
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

      final body = <String, dynamic>{};
      if (reason != null && reason.isNotEmpty) {
        body['reason'] = reason;
      }

      final response = await http
          .post(
            Uri.parse('$baseUrl/bookings/$id/reject'),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: json.encode(body),
          )
          .timeout(timeoutDuration);

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        return {'success': true, 'message': 'Booking berhasil ditolak'};
      }

      return {'success': false, 'message': data['message'] ?? 'Gagal menolak'};
    } on TimeoutException {
      return {'success': false, 'message': 'Koneksi timeout'};
    } on SocketException {
      return {'success': false, 'message': 'Tidak dapat terhubung ke server'};
    } catch (e) {
      return {'success': false, 'message': 'Terjadi kesalahan'};
    }
  }

  /// RESCHEDULE BOOKING
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

      final body = {'scheduled_at': newScheduledAt.toUtc().toIso8601String()};

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

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        return {'success': true, 'message': 'Jadwal berhasil diubah'};
      }

      return {
        'success': false,
        'message': data['message'] ?? 'Gagal reschedule',
      };
    } on TimeoutException {
      return {'success': false, 'message': 'Koneksi timeout'};
    } on SocketException {
      return {'success': false, 'message': 'Tidak dapat terhubung ke server'};
    } catch (e) {
      return {'success': false, 'message': 'Terjadi kesalahan'};
    }
  }

  /// COMPLETE BOOKING
  static Future<Map<String, dynamic>?> completeBooking(String id) async {
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

      final response = await http
          .post(
            Uri.parse('$baseUrl/bookings/$id/complete'),
            headers: {
              'Authorization': 'Bearer $token',
              'Accept': 'application/json',
            },
          )
          .timeout(timeoutDuration);

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        return {'success': true, 'message': 'Booking selesai'};
      }

      return {
        'success': false,
        'message': data['message'] ?? 'Gagal menyelesaikan',
      };
    } on TimeoutException {
      return {'success': false, 'message': 'Koneksi timeout'};
    } on SocketException {
      return {'success': false, 'message': 'Tidak dapat terhubung ke server'};
    } catch (e) {
      return {'success': false, 'message': 'Terjadi kesalahan'};
    }
  }
}
