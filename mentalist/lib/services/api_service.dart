import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:8000/api'; // Using 10.0.2.2 for Android emulator to reach localhost

  static Future<Map<String, dynamic>?> loginWithGoogle(String idToken) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/google/login'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'id_token': idToken,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data;
      } else {
        print('Error: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('Exception in loginWithGoogle: $e');
      return null;
    }
  }
}