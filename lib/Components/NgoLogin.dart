import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart'; // ✅ for local storage
import 'package:project/Components/NgoScreen/NgoIndex.dart';

class NgoLogin extends StatefulWidget {
  const NgoLogin({Key? key}) : super(key: key);

  @override
  _NgoLoginState createState() => _NgoLoginState();
}

class _NgoLoginState extends State<NgoLogin> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isLoading = false;
  bool _obscurePassword = true;

  Future<void> loginNgo() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final querySnapshot = await _firestore
          .collection('ngos') // ✅ NGO collection
          .where('email', isEqualTo: _emailController.text.trim())
          .where('password', isEqualTo: _passwordController.text.trim())
          .where('status', isEqualTo:"active")

          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final ngoDoc = querySnapshot.docs.first;
        final ngoData = ngoDoc.data();

        // ✅ Save NGO data in SharedPreferences
       SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('ngoId', ngoDoc.id); // Firestore document ID
      await prefs.setString('ngoname', ngoData['ngoname'] ?? "");
      await prefs.setString('email', ngoData['email'] ?? "");
      await prefs.setString('phone', ngoData['phone'] ?? "");
      await prefs.setString('address', ngoData['address'] ?? "");
      await prefs.setString('image_url', ngoData['image_url'] ?? "");
      await prefs.setString('status', ngoData['status'] ?? "");
      await prefs.setString('type', ngoData['type'] ?? "");
      await prefs.setString('created_at', ngoData['created_at']?.toString() ?? "");


        // ✅ Success message
        Flushbar(
          message: "Welcome ${ngoData['orgName'] ?? 'NGO'}!",
          duration: const Duration(seconds: 3),
          backgroundColor: Colors.green,
          flushbarPosition: FlushbarPosition.TOP,
        ).show(context);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const NgoIndex()),
        );
      } else {
        Flushbar(
                  message: "Login Failed",

          duration: const Duration(seconds: 3),
          backgroundColor: Colors.red,
          flushbarPosition: FlushbarPosition.TOP,
        ).show(context);
      }
    } catch (e) {
      Flushbar(
        message: "Something went wrong: $e",
        duration: const Duration(seconds: 3),
        backgroundColor: Colors.red,
        flushbarPosition: FlushbarPosition.TOP,
      ).show(context);
    } finally {
      setState(() => _isLoading = false);
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
                    "assets/images/Eco.png", // ✅ replace with your NGO logo
                    height: 40,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "Eco Organization Login",
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
                      prefixIcon:
                          const Icon(Icons.email, color: Colors.green),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) => value == null || value.isEmpty
                        ? 'Enter your email'
                        : null,
                  ),
                  const SizedBox(height: 16),

                  // Password
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      labelStyle: GoogleFonts.inter(),
                      prefixIcon:
                          const Icon(Icons.lock, color: Colors.green),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: Colors.green,
                        ),
                        onPressed: () => setState(
                            () => _obscurePassword = !_obscurePassword),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) =>
                        value!.length < 6 ? 'Password too short' : null,
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
