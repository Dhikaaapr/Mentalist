// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../screens/user_dashboard.dart';
import '../auth/register_page.dart';
import '../auth/forgoutpass.dart';
import '../services/api_service.dart';
import '../utils/logger.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isLoading = false;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ["email", "profile", "openid"],
    serverClientId:
        "253231344096-rfjhteso7p463jl44m6663qtp5bfpaf9.apps.googleusercontent.com",
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
    // Validasi input
    if (emailController.text.trim().isEmpty ||
        passwordController.text.trim().isEmpty) {
      _showSnackBar("Harap isi email dan password!", Colors.redAccent);
      return;
    }

    setState(() => isLoading = true);

    try {
      // TODO: Ganti dengan API call sebenarnya
      await Future.delayed(const Duration(seconds: 1));

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => UserDashboardPage(
            userName: emailController.text.split('@')[0],
            userEmail: emailController.text,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      _showSnackBar("Login gagal: ${e.toString()}", Colors.redAccent);
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  /// -------------------------------
  /// LOGIN WITH GOOGLE
  /// -------------------------------
  Future<void> _loginWithGoogle() async {
    setState(() => isLoading = true);

    try {
      // Sign out terlebih dahulu untuk memastikan user bisa pilih akun
      await _googleSignIn.signOut();

      // Sign in dengan Google
      final GoogleSignInAccount? account = await _googleSignIn.signIn();

      debugPrint("GoogleSignIn: $account");

      if (account == null) {
        // User membatalkan login
        if (!mounted) return;
        _showSnackBar("Login dibatalkan", Colors.orangeAccent);
        return;
      }

      AppLogger.info("✅ Google account signed in: ${account.email}");

      // Dapatkan authentication tokens
      final GoogleSignInAuthentication googleAuth =
          await account.authentication;

      // Cek ID Token
      final String? idToken = googleAuth.idToken;

      debugPrint("idToken: $idToken");

      if (idToken == null || idToken.isEmpty) {
        throw Exception(
          "ID Token tidak tersedia. Pastikan:\n"
          "1. SHA-1 fingerprint sudah terdaftar di Google Cloud Console\n"
          "2. OAuth 2.0 Client ID sudah dikonfigurasi dengan benar\n"
          "3. google-services.json (Android) atau GoogleService-Info.plist (iOS) sudah ditambahkan",
        );
      }

      AppLogger.info("✅ ID Token diperoleh (${idToken.length} karakter)");

      // Kirim ke backend
      AppLogger.info("🔄 Mengirim ID Token ke backend...");
      final response = await ApiService.loginWithGoogle(idToken);

      if (!mounted) return;

      if (response != null && response['success'] == true) {
        AppLogger.info("✅ Login berhasil!");

        // Navigasi ke dashboard
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => UserDashboardPage(
              userName:
                  response['user']?['name'] ?? account.displayName ?? "User",
              userEmail: response['user']?['email'] ?? account.email,
              userPhotoUrl: response['user']?['picture'] ?? account.photoUrl,
            ),
          ),
        );
      } else {
        // Login gagal
        final errorMessage =
            response?['message'] ??
            response?['error'] ??
            "Login gagal. Silakan coba lagi.";

        AppLogger.error("❌ Login gagal: $errorMessage");
        _showSnackBar(errorMessage, Colors.redAccent);
      }
    } on Exception catch (e) {
      AppLogger.error('❌ Exception: $e');
      if (!mounted) return;
      _showSnackBar(
        e.toString().replaceAll('Exception: ', ''),
        Colors.redAccent,
      );
    } catch (e) {
      AppLogger.error('❌ Error: $e');
      if (!mounted) return;

      String errorMessage = "Terjadi kesalahan saat login Google";

      // Deteksi error spesifik
      if (e.toString().contains("sign_in_failed") ||
          e.toString().contains("ApiException")) {
        errorMessage =
            "Login Google gagal.\n\n"
            "Troubleshooting:\n"
            "1. Pastikan SHA-1 fingerprint sudah terdaftar di Google Cloud Console\n"
            "2. Periksa konfigurasi OAuth 2.0 Client ID\n"
            "3. Pastikan google-services.json sudah ditambahkan";
      } else if (e.toString().contains("network") ||
          e.toString().contains("SocketException")) {
        errorMessage =
            "Tidak dapat terhubung ke server. Periksa koneksi internet Anda.";
      }

      _showSnackBar(errorMessage, Colors.redAccent);
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  /// -------------------------------
  /// HELPER: SHOW SNACKBAR
  /// -------------------------------
  void _showSnackBar(String message, Color backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset("assets/logo.png", height: 120),
                const SizedBox(height: 20),

                const Text(
                  "Masuk ke Mentalist",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 35),

                // Email Field
                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  enabled: !isLoading,
                  decoration: InputDecoration(
                    labelText: "Email",
                    prefixIcon: const Icon(Icons.email_outlined),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Password Field
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  enabled: !isLoading,
                  decoration: InputDecoration(
                    labelText: "Password",
                    prefixIcon: const Icon(Icons.lock_outline),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: isLoading
                        ? null
                        : () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const ForgotPassPage(),
                              ),
                            );
                          },
                    child: const Text(
                      "Forgot password?",
                      style: TextStyle(fontSize: 13, color: Colors.blueAccent),
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                // Login Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _loginManual,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      disabledBackgroundColor: Colors.grey.shade300,
                    ),
                    child: isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            "Masuk",
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                  ),
                ),

                const SizedBox(height: 25),
                const Row(
                  children: [
                    Expanded(child: Divider()),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        "Atau",
                        style: TextStyle(color: Colors.black54),
                      ),
                    ),
                    Expanded(child: Divider()),
                  ],
                ),
                const SizedBox(height: 25),

                // Google Login Button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: isLoading ? null : _loginWithGoogle,
                    icon: Image.asset("assets/Google.png", height: 24),
                    label: const Text(
                      "Masuk dengan Google",
                      style: TextStyle(fontSize: 16, color: Colors.black87),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      side: const BorderSide(color: Colors.black26),
                      disabledForegroundColor: Colors.grey,
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // Register Link
                GestureDetector(
                  onTap: isLoading
                      ? null
                      : () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const RegisterPage(),
                            ),
                          );
                        },
                  child: Text(
                    "Belum punya akun? Daftar",
                    style: TextStyle(
                      color: isLoading ? Colors.grey : Colors.blueAccent,
                      fontSize: 15,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
