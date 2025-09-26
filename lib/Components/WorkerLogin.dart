import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:project/WorkerScreen/WorkerIndex.dart';

class WorkerLogin extends StatefulWidget {
  const WorkerLogin({Key? key}) : super(key: key);

  @override
  _WorkerLoginState createState() => _WorkerLoginState();
}

class _WorkerLoginState extends State<WorkerLogin> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isLoading = false;
  bool _obscurePassword = true;

  Future<void> loginWorker() async {
  if (!_formKey.currentState!.validate()) return;

  setState(() => _isLoading = true);

  try {
    final querySnapshot = await _firestore
        .collection('workers')
        .where('email', isEqualTo: _emailController.text.trim())
        .where('password', isEqualTo: _passwordController.text.trim())
          .where('status', isEqualTo:"active")

        .get();

    if (querySnapshot.docs.isNotEmpty) {
      final workerDoc = querySnapshot.docs.first;
      final workerData = workerDoc.data();

      // ✅ Save all worker data in SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('workerId', workerDoc.id); // document ID
      await prefs.setString('WorkerName', workerData['WorkerName'] ?? "");
      await prefs.setString('address', workerData['address'] ?? "");
      await prefs.setString('availability', workerData['availability'] ?? "");
      await prefs.setString('created_at', workerData['created_at']?.toString() ?? "");
      await prefs.setString('email', workerData['email'] ?? "");
      await prefs.setString('end_time', workerData['end_time'] ?? "");
      await prefs.setString('image_url', workerData['image_url'] ?? "");
      await prefs.setString('password', workerData['password'] ?? "");
      await prefs.setString('phone', workerData['phone'] ?? "");
      await prefs.setString('start_time', workerData['start_time'] ?? "");
      await prefs.setString('status', workerData['status'] ?? "");
      await prefs.setString('working_hours', workerData['working_hours'] ?? "");

      Flushbar(
        message: "Welcome ${workerData['WorkerName']}!",
        duration: const Duration(seconds: 3),
        backgroundColor: Colors.green,
        flushbarPosition: FlushbarPosition.TOP,
      ).show(context);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => WorkerIndex()),
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
          child: Column(
            children: [
              Container(
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
                        "assets/images/Eco.png",
                        height: 40,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        "Worker Login",
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
                          prefixIcon: Icon(Icons.email, color: Colors.green),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) =>
                            value == null || value.isEmpty ? 'Enter your email' : null,
                      ),
                      const SizedBox(height: 16),

                      // Password
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          labelStyle: GoogleFonts.inter(),
                          prefixIcon: Icon(Icons.lock, color: Colors.green),
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
                            value!.length < 6 ? 'Password too short' : null,
                      ),
                      const SizedBox(height: 20),

                      // Login Button
                      _isLoading
                          ? const CircularProgressIndicator()
                          : ElevatedButton(
                              onPressed: loginWorker,
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
            ],
          ),
        ),
      ),
    );
  }
}
