import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';

class AccountAdminLogin extends StatefulWidget {
  const AccountAdminLogin({Key? key}) : super(key: key);

  @override
  _AccountAdminLoginState createState() => _AccountAdminLoginState();
}

class _AccountAdminLoginState extends State<AccountAdminLogin> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  Future<void> loginNgo() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final query = await FirebaseFirestore.instance
          .collection('SocialAccount')
          .where('email', isEqualTo: _emailController.text.trim())
          .where('loginId', isEqualTo: _passwordController.text.trim())
          .get();

      if (query.docs.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid email or login ID')),
        );
      } else {
        final userData = query.docs.first.data();

        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('accountName', userData['accountName'] ?? '');
        await prefs.setString('bio', userData['bio'] ?? '');
        await prefs.setString('email', userData['email'] ?? '');
        await prefs.setInt('followers', userData['followers'] ?? 0);
        await prefs.setInt('following', userData['following'] ?? 0);
        await prefs.setString('loginId', userData['loginId'] ?? '');
        await prefs.setString('profilePic', userData['profilePic'] ?? '');
        await prefs.setString('status', userData['status'] ?? '');
        await prefs.setString('username', userData['username'] ?? '');

        // Navigate to Home or Dashboard
        Navigator.pushReplacementNamed(context, '/AdminAcountIndex');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            width: 360,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 12,
                  spreadRadius: 2,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Image.asset(
                    "assets/images/Eco.png", // Your logo
                    height: 40,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "Account Admin Login",
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      color: Colors.green,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Email
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      labelStyle: GoogleFonts.inter(),
                      prefixIcon: const Icon(Icons.email, color: Colors.green),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Enter your email' : null,
                  ),
                  const SizedBox(height: 16),

                  // Login ID (used as password)
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: 'Login ID',
                      labelStyle: GoogleFonts.inter(),
                      prefixIcon: const Icon(Icons.lock, color: Colors.green),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility_off : Icons.visibility,
                          color: Colors.green,
                        ),
                        onPressed: () =>
                            setState(() => _obscurePassword = !_obscurePassword),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Enter Login ID' : null,
                  ),
                  const SizedBox(height: 20),

                  // Login Button
                  _isLoading
                      ? const CircularProgressIndicator()
                      : ElevatedButton(
                          onPressed: loginNgo,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 40, vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            "Login",
                            style: GoogleFonts.inter(
                                fontWeight: FontWeight.w600, fontSize: 16),
                          ),
                        ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
