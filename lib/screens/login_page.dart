import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'admin_dashboard.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _loading = false;
  bool _obscurePassword = true;

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      final response = await http
          .post(
            Uri.parse(
              "http://voting-alb-1933918113.eu-north-1.elb.amazonaws.com/auth/login",
            ),
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({
              "identifier": _emailController.text.trim(),
              "password": _passwordController.text.trim(),
              "app": "MASTER_ADMIN",
            }),
          )
          .timeout(const Duration(seconds: 15));

      Map<String, dynamic> data = {};
      try {
        data = jsonDecode(response.body);
      } catch (_) {
        data = {};
      }

      if (response.statusCode != 200) {
        String message = data["message"] ?? "Login failed";

        if (message.toLowerCase().contains("invalid")) {
          message = "Invalid email or password";
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.red.shade700,
          ),
        );

        setState(() => _loading = false);
        return;
      }

      final prefs = await SharedPreferences.getInstance();

      // ✅ MUST match dashboard
      await prefs.setString("token", data["token"]);

      // ✅ ADD LOGIN TIME (24h session)
      await prefs.setInt("login_time", DateTime.now().millisecondsSinceEpoch);

      // ✅ REQUIRED for drawer
      final user = data["user"];

      await prefs.setString("admin_name", user?["name"]?.toString() ?? "Admin");

      await prefs.setString("admin_email", user?["email"]?.toString() ?? "");

      await prefs.setString(
        "admin_photo",
        user?["profile_photo"]?.toString() ?? "",
      );

      // optional
      await prefs.setString("user_role", user?["role"]?.toString() ?? "");

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Welcome Master Admin!"),
          backgroundColor: Colors.green,
        ),
      );

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AdminDashboard()),
      );
    } catch (e) {
      String message = "Something went wrong";

      if (e.toString().contains("SocketException")) {
        message = "No Internet Connection";
      } else if (e.toString().contains("TimeoutException")) {
        message = "Server timeout. Try again.";
      } else {
        message = "Server not reachable";
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red.shade700),
      );
      ;
    }
    setState(() => _loading = false);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Container(
            width: double.infinity,
            height: constraints.maxHeight,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [Colors.white, Colors.blue],
                stops: [0.4, 1.0],
              ),
            ),
            child: SafeArea(
              child: SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: sw * 0.08),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(height: sh * 0.05),

                            // LOGO
                            Image.asset(
                              'assets/logo_circle.png',
                              width: 110,
                              height: 110,
                            ),

                            const SizedBox(height: 20),

                            Text(
                              "Admin Login",
                              style: TextStyle(
                                fontSize: sw * 0.075,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue.shade700,
                              ),
                            ),

                            const SizedBox(height: 6),

                            Text(
                              "Manage elections, users & reports",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: sw * 0.04,
                                color: Colors.grey.shade600,
                              ),
                            ),

                            const SizedBox(height: 40),

                            // EMAIL
                            TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              decoration: InputDecoration(
                                labelText: "Email/VOTER ID/PHONE",
                                prefixIcon: const Icon(Icons.email_outlined),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              validator: (v) => (v == null || v.isEmpty)
                                  ? "Enter email/voter id/phone"
                                  : null,
                            ),
                            const SizedBox(height: 20),

                            // PASSWORD
                            TextFormField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              decoration: InputDecoration(
                                labelText: "Password",
                                prefixIcon: const Icon(Icons.lock_outline),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              validator: (v) => (v == null || v.isEmpty)
                                  ? "Enter password"
                                  : null,
                            ),

                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        "Password recovery coming soon",
                                      ),
                                      backgroundColor: Colors.blueGrey,
                                    ),
                                  );
                                },
                                child: const Text("Forgot Password?"),
                              ),
                            ),

                            const SizedBox(height: 10),

                            // LOGIN BUTTON
                            SizedBox(
                              width: double.infinity,
                              height: 55,
                              child: ElevatedButton(
                                onPressed: _loading ? null : _login,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: _loading
                                    ? const CircularProgressIndicator(
                                        color: Colors.white,
                                      )
                                    : const Text(
                                        "Login",
                                        style: TextStyle(
                                          fontSize: 18,
                                          color: Colors.white,
                                        ),
                                      ),
                              ),
                            ),

                            const SizedBox(height: 30),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
