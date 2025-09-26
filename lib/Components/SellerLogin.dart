import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart'; // ✅ for local storage
import 'package:project/SellerScreen.dart/SellerIndex.dart';

class SellerLogin extends StatefulWidget {
  const SellerLogin({Key? key}) : super(key: key);

  @override
  _SellerLoginState createState() => _SellerLoginState();
}

class _SellerLoginState extends State<SellerLogin> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isLoading = false;
  bool _obscurePassword = true;

  Future<void> loginSeller() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final querySnapshot = await _firestore
          .collection('sellers')
          .where('email', isEqualTo: _emailController.text.trim())
          .where('password', isEqualTo: _passwordController.text.trim())
          .where('status', isEqualTo:"active")

          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final sellerDoc = querySnapshot.docs.first;
        final sellerData = sellerDoc.data();

        // ✅ Save all seller data including doc ID
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('sellerId', sellerDoc.id); // Firestore document ID
        await prefs.setString('saddress', sellerData['saddress'] ?? "");
        await prefs.setString('brandName', sellerData['brandName'] ?? "");
        await prefs.setStringList('categories',
            List<String>.from(sellerData['categories'] ?? []));
        await prefs.setString(
            'created_at', sellerData['created_at']?.toString() ?? "");
        await prefs.setString('email', sellerData['email'] ?? "");
        await prefs.setString('image_url', sellerData['image_url'] ?? "");
        await prefs.setString('lastName', sellerData['lastName'] ?? "");
        await prefs.setString('password', sellerData['password'] ?? "");
        await prefs.setString('phone', sellerData['phone'] ?? "");
        await prefs.setString('sellerName', sellerData['sellerName'] ?? "");
        await prefs.setString('status', sellerData['status'] ?? "");

        // ✅ Success message
        Flushbar(
          message: "Welcome ${sellerData['sellerName'] ?? 'Seller'}!",
          duration: const Duration(seconds: 3),
          backgroundColor: Colors.green,
          flushbarPosition: FlushbarPosition.TOP,
        ).show(context);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => SellerIndex()),
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
                    "assets/images/Eco.png", // logo
                    height: 40,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "Seller Login",
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

                  // Password
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      labelStyle: GoogleFonts.inter(),
                      prefixIcon: const Icon(Icons.lock, color: Colors.green),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
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
                          onPressed: loginSeller,
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
