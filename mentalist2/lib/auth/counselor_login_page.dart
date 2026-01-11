// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../services/counselor_api_service.dart';
import '../screens/set_weekly_availability_page.dart';

import '../utils/logger.dart';

class CounselorLoginPage extends StatefulWidget {
  const CounselorLoginPage({super.key});

  @override
  State<CounselorLoginPage> createState() => _CounselorLoginPageState();
}

class _CounselorLoginPageState extends State<CounselorLoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isLoading = false;

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile', 'openid'],
    serverClientId:
        '253231344096-rfjhteso7p463jl44m6663qtp5bfpaf9.apps.googleusercontent.com',
  );

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  /// -------------------------------
  /// LOGIN MANUAL
  /// -------------------------------
  void _loginManual() async {
    AppLogger.info('[COUNSELOR] Manual login');

    if (emailController.text.trim().isEmpty ||
        passwordController.text.trim().isEmpty) {
      _showSnackBar("Email dan password wajib diisi", Colors.redAccent);
      return;
    }

    setState(() => isLoading = true);

    final response = await CounselorApiService.login(
      emailController.text.trim(),
      passwordController.text.trim(),
    );

    if (!mounted) return;
    setState(() => isLoading = false);

    _handleLoginResponse(response);
  }

  /// -------------------------------
  /// LOGIN GOOGLE
  /// -------------------------------
  Future<void> _loginWithGoogle() async {
    AppLogger.info('[COUNSELOR] Google login');
    setState(() => isLoading = true);

    try {
      await _googleSignIn.signOut();
      final account = await _googleSignIn.signIn();

      if (account == null) {
        setState(() => isLoading = false);
        return;
      }

      final auth = await account.authentication;
      final idToken = auth.idToken;

      if (idToken == null) {
        throw Exception('ID Token tidak tersedia');
      }

      final response = await CounselorApiService.loginWithGoogle(idToken);

      if (!mounted) return;
      setState(() => isLoading = false);

      _handleLoginResponse(response);
    } catch (e) {
      AppLogger.error('[COUNSELOR] Google login error: $e');
      setState(() => isLoading = false);
      _showSnackBar(
        'Login Google gagal. Pastikan akun Anda terdaftar sebagai konselor.',
        Colors.redAccent,
      );
    }
  }

  /// -------------------------------
  /// HANDLE RESPONSE
  /// -------------------------------
  void _handleLoginResponse(Map<String, dynamic>? response) {
    if (response != null && response['success'] == true) {
      final user = response['user'];
      final role = user['role']?['name'] ?? '';

      if (role != 'konselor') {
        AppLogger.error('[COUNSELOR] Akses ditolak: Role $role tidak diizinkan');
        _showSnackBar(
          'Akses ditolak. Akun ini tidak terdaftar sebagai konselor.',
          Colors.redAccent,
        );
        return;
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => SetWeeklyAvailabilityPage(
            counselorId: user['id'],
            counselorName: user['name'],
            counselorEmail: user['email'],
          ),
        ),
      );
    } else {
      _showSnackBar(response?['message'] ?? 'Login gagal', Colors.redAccent);
    }
  }

  /// -------------------------------
  /// SNACKBAR
  /// -------------------------------
  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// -------------------------------
  /// UI
  /// -------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                SvgPicture.asset("assets/logokonselor.svg", height: 200),

                const SizedBox(height: 30),

                const SizedBox(height: 30),

                TextField(
                  controller: emailController,
                  enabled: !isLoading,
                  decoration: _input("Email"),
                ),

                const SizedBox(height: 15),

                TextField(
                  controller: passwordController,
                  obscureText: true,
                  enabled: !isLoading,
                  decoration: _input("Password"),
                ),

                const SizedBox(height: 30),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _loginManual,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5A2FC8),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            "Login",
                            style: TextStyle(color: Colors.white),
                          ),
                  ),
                ),

                const SizedBox(height: 25),
                const Text(
                  "Atau masuk dengan",
                  style: TextStyle(fontSize: 13, color: Colors.black45),
                ),
                const SizedBox(height: 14),

                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: isLoading ? null : _loginWithGoogle,
                    icon: Image.asset("assets/Google.png", height: 22),
                    label: const Text("Login dengan Google"),
                  ),
                ),

                const SizedBox(height: 25),
                const Text(
                  "Gunakan akun yang diberikan admin.",
                  style: TextStyle(fontSize: 12, color: Colors.black45),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _input(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.grey.shade100,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
    );
  }
}
