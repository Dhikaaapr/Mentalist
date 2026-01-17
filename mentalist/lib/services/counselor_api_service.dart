import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CounselorApiService {
  static const String baseUrl = 'http://10.0.60.110:8000/api';

  /// =========================
  /// GET LIST COUNSELORS
  /// =========================
  static Future<List<dynamic>> getCounselors() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');

    if (token == null) {
      throw Exception('Token tidak ditemukan, user belum login');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/counselors/approved'),
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      final body = json.decode(response.body);
      return body['data'] ?? [];
    } else {
      throw Exception('Gagal mengambil data konselor');
    }
  }

  /// =========================
  /// GET AVAILABILITY COUNSELOR
  /// =========================
  static Future<List<dynamic>> getAvailability(
    String counselorId,
    String date,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');

    final response = await http.get(
      Uri.parse('$baseUrl/counselors/$counselorId/slots?date=$date'),
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      final body = json.decode(response.body);
      // Returns list of {id, time}
      return body['data'] ?? [];
    } else {
      throw Exception('Gagal mengambil jadwal');
    }
  }
}
