// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../screens/counselor_dashboard.dart';

class CounselorLoginPage extends StatefulWidget {
  const CounselorLoginPage({super.key});

  @override
  State<CounselorLoginPage> createState() => _CounselorLoginPageState();
}

class _CounselorLoginPageState extends State<CounselorLoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isLoading = false;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  /// LOGIN MANUAL
  void _loginManual() async {
    setState(() => isLoading = true);
    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;

    if (emailController.text == "dhika" &&
        passwordController.text == "123456") {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => CounselorDashboardPage(
            counselorName: "Dr. Konselor",
            counselorEmail: emailController.text,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Email atau password salah!"),
          backgroundColor: Colors.redAccent,
        ),
      );
    }

    setState(() => isLoading = false);
  }

  /// LOGIN GOOGLE
  Future<void> _loginWithGoogle() async {
    try {
      setState(() => isLoading = true);
      final GoogleSignInAccount? account = await _googleSignIn.signIn();

      if (account != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => CounselorDashboardPage(
              counselorName: account.displayName ?? "Konselor",
              counselorEmail: account.email,
              counselorPhotoUrl: account.photoUrl,
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint("Login Google error: $e");
    } finally {
      setState(() => isLoading = false);
    }
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
              children: [
                SvgPicture.asset("assets/logokonselor.svg", height: 200),

                const SizedBox(height: 10),

                const SizedBox(height: 25),

                const Text(
                  "Login",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 30),

                // Email Input
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    hintText: "Email",
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: 15),

                // Password Input
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: "Password",
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                // LOGIN BUTTON
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _loginManual,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 90, 47, 200),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            "Login",
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                  ),
                ),

                const SizedBox(height: 20),

                const Text(
                  "Atau masuk dengan",
                  style: TextStyle(fontSize: 13, color: Colors.black45),
                ),

                const SizedBox(height: 14),

                // GOOGLE LOGIN
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: isLoading ? null : _loginWithGoogle,
                    icon: Image.asset("assets/Google.png", height: 22),
                    label: const Text("Login with Google"),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      side: const BorderSide(color: Colors.black26),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                const Text(
                  "Gunakan akun yang diberikan admin.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: Colors.black45),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
