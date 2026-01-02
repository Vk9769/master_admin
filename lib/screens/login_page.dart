import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'admin_dashboard.dart';

/// DEMO ADMIN CREDENTIALS (Replace with API later)
const String demoEmail = "admin@gmail.com";
const String demoPassword = "123456";

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

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    setState(() => _loading = true);

    await Future.delayed(const Duration(milliseconds: 700));

    if (email != demoEmail || password != demoPassword) {
      setState(() => _loading = false);
      Fluttertoast.showToast(
        msg: "Invalid admin credentials",
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      return;
    }

    // ✅ SAVE ADMIN SESSION
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("auth_token", "admin_demo_token");
    await prefs.setString("user_role", "admin");

    Fluttertoast.showToast(
      msg: "Welcome Admin!",
      backgroundColor: Colors.green,
      textColor: Colors.white,
    );

    if (!mounted) return;

    setState(() => _loading = false);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const AdminDashboard()),
    );
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
                colors: [
                  Colors.white,
                  Colors.blue,
                ],
                stops: [
                  0.4,
                  1.0,
                ],
              ),
            ),
            child: SafeArea(
              child: SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                  ),
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
                                labelText: "Email Address",
                                prefixIcon:
                                const Icon(Icons.email_outlined),
                                border: OutlineInputBorder(
                                  borderRadius:
                                  BorderRadius.circular(12),
                                ),
                              ),
                              validator: (v) {
                                if (v == null || v.isEmpty) {
                                  return "Enter email";
                                }
                                if (!v.contains('@')) {
                                  return "Enter valid email";
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 20),

                            // PASSWORD
                            TextFormField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              decoration: InputDecoration(
                                labelText: "Password",
                                prefixIcon:
                                const Icon(Icons.lock_outline),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscurePassword =
                                      !_obscurePassword;
                                    });
                                  },
                                ),
                                border: OutlineInputBorder(
                                  borderRadius:
                                  BorderRadius.circular(12),
                                ),
                              ),
                              validator: (v) =>
                              (v == null || v.isEmpty)
                                  ? "Enter password"
                                  : null,
                            ),

                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () {
                                  Fluttertoast.showToast(
                                    msg:
                                    "Password recovery coming soon",
                                    backgroundColor:
                                    Colors.blueGrey,
                                  );
                                },
                                child:
                                const Text("Forgot Password?"),
                              ),
                            ),

                            const SizedBox(height: 10),

                            // LOGIN BUTTON
                            SizedBox(
                              width: double.infinity,
                              height: 55,
                              child: ElevatedButton(
                                onPressed:
                                _loading ? null : _login,
                                style:
                                ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  shape:
                                  RoundedRectangleBorder(
                                    borderRadius:
                                    BorderRadius.circular(
                                        12),
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
