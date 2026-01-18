import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/logger.dart';

class ApiService {
  // emulator
  // static const String baseUrl = 'http://10.0.2.2:8000/api';

  // physical device
  static const String baseUrl = 'http://10.92.142.43:8000/api';

  static const Duration timeoutDuration = Duration(seconds: 30);

  /// -------------------------------
  /// LOGIN MANUAL USER
  /// -------------------------------
  static Future<Map<String, dynamic>?> login(
    String email,
    String password,
  ) async {
    try {
      AppLogger.info('📡 [USER] Request → $baseUrl/auth/login');

      final response = await http
          .post(
            Uri.parse('$baseUrl/auth/login'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: json.encode({'email': email, 'password': password}),
          )
          .timeout(
            timeoutDuration,
            onTimeout: () {
              throw TimeoutException('Request timeout');
            },
          );

      AppLogger.info('📡 [USER] Status: ${response.statusCode}');
      AppLogger.debug('📬 [USER] Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data is! Map<String, dynamic>) {
          AppLogger.error('[USER] Response bukan Map');
          return null;
        }

        // Simpan token
        if (data['token'] != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('accessToken', data['token']);

          // Determine role from response
          String userRole = 'user'; // default role
          if (data['user'] != null && data['user']['role'] != null) {
            userRole = data['user']['role']['name'] ?? 'user';
          }
          await prefs.setString('role', userRole);

          AppLogger.info('[USER] Token disimpan');
        }

        data['success'] = true;
        return data;
      }

      if (response.statusCode == 401) {
        return {
          'success': false,
          'message': 'Email atau password salah',
          'error': 'unauthorized',
        };
      }

      if (response.statusCode == 403) {
        return {
          'success': false,
          'message': 'Akun tidak aktif',
          'error': 'forbidden',
        };
      }

      return {
        'success': false,
        'message': 'Terjadi kesalahan pada server',
        'error': 'server_error',
      };
    } on TimeoutException catch (e) {
      AppLogger.error('[USER] Timeout: $e');
      return {
        'success': false,
        'message': 'Koneksi timeout',
        'error': 'timeout',
      };
    } on SocketException catch (e) {
      AppLogger.error('[USER] Network error: $e');
      return {
        'success': false,
        'message': 'Tidak dapat terhubung ke server',
        'error': 'network_error',
      };
    } catch (e) {
      AppLogger.error('[USER] Error: $e');
      return {
        'success': false,
        'message': 'Terjadi kesalahan',
        'error': 'unknown_error',
      };
    }
  }

  /// -------------------------------
  /// REGISTER USER
  /// -------------------------------
  static Future<Map<String, dynamic>?> register(
    String name,
    String email,
    String password,
    String passwordConfirmation,
  ) async {
    try {
      AppLogger.info('📡 [USER] Request → $baseUrl/auth/register');

      final response = await http
          .post(
            Uri.parse('$baseUrl/auth/register'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: json.encode({
              'name': name,
              'email': email,
              'password': password,
              'password_confirmation': passwordConfirmation,
            }),
          )
          .timeout(
            timeoutDuration,
            onTimeout: () {
              throw TimeoutException('Request timeout');
            },
          );

      AppLogger.info('📡 [USER] Status: ${response.statusCode}');
      AppLogger.debug('📬 [USER] Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data is! Map<String, dynamic>) {
          AppLogger.error('[USER] Response bukan Map');
          return null;
        }

        // Simpan token
        if (data['token'] != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('accessToken', data['token']);

          // Determine role from response
          String userRole = 'user';
          if (data['user'] != null && data['user']['role'] != null) {
            userRole = data['user']['role']['name'] ?? 'user';
          }
          await prefs.setString('role', userRole);

          AppLogger.info('[USER] Token disimpan');
        }

        data['success'] = true;
        return data;
      }

      if (response.statusCode == 422) {
        final data = json.decode(response.body);
        String errorMessage = 'Validasi gagal';
        if (data['errors'] != null) {
          // Get the first error message from the validation errors
          final errors = data['errors'];
          if (errors is Map) {
            final firstErrorKey = errors.keys.first;
            final firstErrorValue = errors[firstErrorKey];

            if (firstErrorValue is List && firstErrorValue.isNotEmpty) {
              errorMessage = firstErrorValue.first ?? 'Validasi gagal';
            } else if (firstErrorValue is String) {
              errorMessage = firstErrorValue;
            } else {
              errorMessage = 'Validasi gagal';
            }
          }
        }
        return {
          'success': false,
          'message': errorMessage,
          'error': 'validation_error',
        };
      }

      return {
        'success': false,
        'message': 'Registrasi gagal',
        'error': 'server_error',
      };
    } on TimeoutException catch (e) {
      AppLogger.error('[USER] Timeout: $e');
      return {
        'success': false,
        'message': 'Koneksi timeout',
        'error': 'timeout',
      };
    } on SocketException catch (e) {
      AppLogger.error('[USER] Network error: $e');
      return {
        'success': false,
        'message': 'Tidak dapat terhubung ke server',
        'error': 'network_error',
      };
    } catch (e) {
      AppLogger.error('[USER] Error: $e');
      return {
        'success': false,
        'message': 'Terjadi kesalahan',
        'error': 'unknown_error',
      };
    }
  }

  /// -------------------------------
  /// LOGIN USER WITH GOOGLE
  /// -------------------------------
  static Future<Map<String, dynamic>?> loginWithGoogle(String idToken) async {
    try {
      AppLogger.info('📡 [USER] Google login → $baseUrl/auth/google/login');

      final response = await http
          .post(
            Uri.parse('$baseUrl/auth/google/login'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: json.encode({'id_token': idToken}),
          )
          .timeout(timeoutDuration);

      AppLogger.info('📡 [USER] Status: ${response.statusCode}');
      AppLogger.debug('📬 [USER] Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('accessToken', data['token']);

        // Determine role from response - Google login returns user object with role
        String userRole = 'user'; // default role
        if (data['user'] != null && data['user']['role'] != null) {
          userRole = data['user']['role']['name'] ?? 'user';
        }
        await prefs.setString('role', userRole);

        data['success'] = true;
        return data;
      }

      if (response.statusCode == 401) {
        return {
          'success': false,
          'message': 'Akun Google tidak terdaftar atau tidak valid',
          'error': 'unauthorized',
        };
      }

      return {
        'success': false,
        'message': 'Login Google gagal',
        'error': 'server_error',
      };
    } catch (e) {
      AppLogger.error('[USER] Google login error: $e');
      return {
        'success': false,
        'message': 'Terjadi kesalahan saat login Google',
        'error': 'unknown_error',
      };
    }
  }

  /// -------------------------------
  /// GET AUTHENTICATED USER PROFILE
  /// -------------------------------
  static Future<Map<String, dynamic>?> getProfile() async {
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

      // Using Laravel Sanctum's standard endpoint for getting authenticated user
      final response = await http.get(
        Uri.parse('$baseUrl/user'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return {'success': true, 'data': json.decode(response.body)};
      }

      return {'success': false, 'message': 'Gagal mengambil profil pengguna'};
    } catch (e) {
      AppLogger.error('[USER] Get profile error: $e');
      return {'success': false, 'message': 'Terjadi kesalahan'};
    }
  }

  /// -------------------------------
  /// FORGOT PASSWORD
  /// -------------------------------
  static Future<Map<String, dynamic>> forgotPassword(String email) async {
    try {
      AppLogger.info('📡 [USER] Forgot password → $baseUrl/forgot-password');

      final response = await http
          .post(
            Uri.parse('$baseUrl/forgot-password'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: json.encode({'email': email}),
          )
          .timeout(
            timeoutDuration,
            onTimeout: () {
              throw TimeoutException('Request timeout');
            },
          );

      AppLogger.info('📡 [USER] Status: ${response.statusCode}');
      AppLogger.debug('📬 [USER] Body: ${response.body}');

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': data['message'] ?? 'Link reset password dikirim',
        };
      }

      if (response.statusCode == 422) {
        return {
          'success': false,
          'message': data['message'] ?? 'Email tidak valid',
        };
      }

      return {
        'success': false,
        'message': data['message'] ?? 'Gagal mengirim reset password',
      };
    } on TimeoutException catch (e) {
      AppLogger.error('[USER] Forgot password timeout: $e');
      return {'success': false, 'message': 'Koneksi timeout'};
    } on SocketException catch (e) {
      AppLogger.error('[USER] Forgot password network error: $e');
      return {'success': false, 'message': 'Tidak dapat terhubung ke server'};
    } catch (e) {
      AppLogger.error('[USER] Forgot password error: $e');
      return {'success': false, 'message': 'Terjadi kesalahan'};
    }
  }

  /// -------------------------------
  /// LOGOUT USER
  /// -------------------------------
  static Future<Map<String, dynamic>?> logout() async {
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

      final response = await http.post(
        Uri.parse('$baseUrl/logout'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        // Clear stored tokens
        await prefs.remove('accessToken');
        await prefs.remove('role');

        return {'success': true, 'message': 'Logout berhasil'};
      }

      // Even if logout API fails, clear local storage
      await prefs.remove('accessToken');
      await prefs.remove('role');

      return {'success': true, 'message': 'Logout berhasil'};
    } catch (e) {
      AppLogger.error('[USER] Logout error: $e');

      // Clear local storage anyway
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('accessToken');
      await prefs.remove('role');

      return {'success': true, 'message': 'Logout berhasil'};
    }
  }

  /// -------------------------------
  /// FETCH NOTIFICATIONS
  /// -------------------------------
  static Future<Map<String, dynamic>> fetchNotifications() async {
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

      AppLogger.info('📡 [USER] Request → $baseUrl/notifications');

      final response = await http
          .get(
            Uri.parse('$baseUrl/notifications'),
            headers: {
              'Authorization': 'Bearer $token',
              'Accept': 'application/json',
            },
          )
          .timeout(
            timeoutDuration,
            onTimeout: () {
              throw TimeoutException('Request timeout');
            },
          );

      AppLogger.info('📡 [USER] Status: ${response.statusCode}');
      AppLogger.debug('📬 [USER] Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {'success': true, 'data': data['data'] ?? data};
      }

      return {
        'success': false,
        'message': 'Gagal mengambil notifikasi',
        'error': 'server_error',
      };
    } on TimeoutException catch (e) {
      AppLogger.error('[USER] Fetch notifications timeout: $e');
      return {
        'success': false,
        'message': 'Koneksi timeout',
        'error': 'timeout',
      };
    } on SocketException catch (e) {
      AppLogger.error('[USER] Fetch notifications network error: $e');
      return {
        'success': false,
        'message': 'Tidak dapat terhubung ke server',
        'error': 'network_error',
      };
    } catch (e) {
      AppLogger.error('[USER] Fetch notifications error: $e');
      return {
        'success': false,
        'message': 'Terjadi kesalahan',
        'error': 'unknown_error',
      };
    }
  }

  /// -------------------------------
  /// UPDATE PROFILE
  /// -------------------------------
  static Future<Map<String, dynamic>> updateProfile({
    String? name,
    String? phone,
    String? birthDate,
    String? address,
    String? photo,
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

      AppLogger.info('📡 [USER] Request → $baseUrl/user/profile');

      final body = <String, dynamic>{};
      if (name != null && name.isNotEmpty) body['name'] = name;
      if (phone != null && phone.isNotEmpty) body['phone'] = phone;
      if (birthDate != null && birthDate.isNotEmpty)
        body['birth_date'] = birthDate;
      if (address != null && address.isNotEmpty) body['address'] = address;
      if (photo != null && photo.isNotEmpty) body['photo'] = photo;

      final response = await http
          .put(
            Uri.parse('$baseUrl/user/profile'),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: json.encode(body),
          )
          .timeout(
            timeoutDuration,
            onTimeout: () {
              throw TimeoutException('Request timeout');
            },
          );

      AppLogger.info('📡 [USER] Status: ${response.statusCode}');
      AppLogger.debug('📬 [USER] Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'message': data['message'] ?? 'Profil berhasil diperbarui',
          'data': data['data'] ?? data,
        };
      }

      if (response.statusCode == 422) {
        final data = json.decode(response.body);
        String errorMessage = 'Validasi gagal';
        if (data['errors'] != null) {
          final errors = data['errors'];
          if (errors is Map && errors.keys.isNotEmpty) {
            final firstErrorKey = errors.keys.first;
            final firstErrorValue = errors[firstErrorKey];
            if (firstErrorValue is List && firstErrorValue.isNotEmpty) {
              errorMessage = firstErrorValue.first ?? 'Validasi gagal';
            } else if (firstErrorValue is String) {
              errorMessage = firstErrorValue;
            }
          }
        }
        return {
          'success': false,
          'message': errorMessage,
          'error': 'validation_error',
        };
      }

      return {
        'success': false,
        'message': 'Gagal memperbarui profil',
        'error': 'server_error',
      };
    } on TimeoutException catch (e) {
      AppLogger.error('[USER] Update profile timeout: $e');
      return {
        'success': false,
        'message': 'Koneksi timeout',
        'error': 'timeout',
      };
    } on SocketException catch (e) {
      AppLogger.error('[USER] Update profile network error: $e');
      return {
        'success': false,
        'message': 'Tidak dapat terhubung ke server',
        'error': 'network_error',
      };
    } catch (e) {
      AppLogger.error('[USER] Update profile error: $e');
      return {
        'success': false,
        'message': 'Terjadi kesalahan',
        'error': 'unknown_error',
      };
    }
  }
}
