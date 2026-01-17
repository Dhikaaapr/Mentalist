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
      Uri.parse('$baseUrl/counselors/available'),
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
  static Future<List<String>> getAvailability(
    String counselorId,
    String date,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');

    final response = await http.get(
      Uri.parse('$baseUrl/counselors/$counselorId/availability?date=$date'),
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      final body = json.decode(response.body);
      return List<String>.from(body['slots'] ?? []);
    } else {
      throw Exception('Gagal mengambil jadwal');
    }
  }
}
