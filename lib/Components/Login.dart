import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:project/Components/AppColors.dart'; // Custom colors

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _loadSavedEmail();
  }

  Future<void> _loadSavedEmail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedEmail = prefs.getString('userEmail');
    if (savedEmail != null) {
      _emailController.text = savedEmail;
    }
  }
Future<void> _login() async {
  if (!_formKey.currentState!.validate()) return;

  try {
    final email = _emailController.text.trim().toLowerCase();
    final password = _passwordController.text.trim();

    String role = "";
    Map<String, dynamic>? userData;

    // NGO check
    var ngoDoc = await FirebaseFirestore.instance
        .collection('ngos')
        .where('email', isEqualTo: email)
        .where('status', isEqualTo: "active")
        .limit(1)
        .get();

    if (ngoDoc.docs.isNotEmpty && ngoDoc.docs.first['password'] == password) {
      role = 'NGO';
      userData = ngoDoc.docs.first.data();
      userData['docId'] = ngoDoc.docs.first.id;

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('ngoId', ngoDoc.docs.first.id);
    }

    // Worker check
    if (role.isEmpty) {
      var workerDoc = await FirebaseFirestore.instance
          .collection('workers')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (workerDoc.docs.isNotEmpty &&
          workerDoc.docs.first['password'] == password) {
        role = workerDoc.docs.first['role'] ?? 'Worker';
        userData = workerDoc.docs.first.data();
        userData['docId'] = workerDoc.docs.first.id;

        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('workerId', workerDoc.docs.first.id);
      }
    }

    // Seller check
    if (role.isEmpty) {
      var sellerDoc = await FirebaseFirestore.instance
          .collection('sellers')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (sellerDoc.docs.isNotEmpty &&
          sellerDoc.docs.first['password'] == password) {
        role = sellerDoc.docs.first['role'] ?? 'Seller';
        userData = sellerDoc.docs.first.data();
        userData['docId'] = sellerDoc.docs.first.id;
      }
    }

    // User check
    if (role.isEmpty) {
      var userDoc = await FirebaseFirestore.instance
          .collection('users')
          .where('Email', isEqualTo: email)
          .limit(1)
          .get();

      if (userDoc.docs.isNotEmpty &&
          userDoc.docs.first['Password'] == password) {
        role = userDoc.docs.first['Role'] ?? 'User';
        userData = userDoc.docs.first.data();
        userData['docId'] = userDoc.docs.first.id;
      }
    }

    // Admin check (hardcoded)
    if (role.isEmpty && email == 'admin@gmail.com' && password == "admin123") {
      role = 'Admin';
      userData = {'email': email, 'name': 'Admin'};
    }

    if (role.isEmpty || userData == null) {
      throw Exception("Incorrect Email or Password");
    }

    // ✅ Save to SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedin', true);
    await prefs.setString('userEmail', email);
    await prefs.setString('role', role);
    await prefs.setString('userId', userData['docId']);

    for (var entry in userData.entries) {
      final key = entry.key;
      final value = entry.value;

      if (value != null) {
        if (key == 'categories' && value is List) {
          List<String> stringList = value.map((e) => e.toString()).toList();
          await prefs.setStringList('categories', stringList);
        } else if (value is String) {
          await prefs.setString(key, value);
        } else if (value is int) {
          await prefs.setInt(key, value);
        } else if (value is double) {
          await prefs.setDouble(key, value);
        } else if (value is bool) {
          await prefs.setBool(key, value);
        }
      }
    }

    _emailController.clear();
    _passwordController.clear();

    Flushbar(
      message: "Login successful as $role!",
      duration: const Duration(seconds: 3),
      backgroundColor: Colors.green,
      flushbarPosition: FlushbarPosition.TOP,
    ).show(context);

    Future.delayed(const Duration(seconds: 2), () {
      if (role == 'NGO') {
        Navigator.pushReplacementNamed(context, '/NgoIndex');
      } else if (role == 'Worker') {
        Navigator.pushReplacementNamed(context, '/WorkerIndex');
      } else if (role == 'Seller') {
        Navigator.pushReplacementNamed(context, '/SellerIndex');
      } else if (role == 'Admin') {
        Navigator.pushReplacementNamed(context, '/AdminIndex');
      } else {
        Navigator.pushReplacementNamed(context, '/mainhome');
      }
    });
  } catch (e) {
    Flushbar(
      message: "Incorrect Email or Password...",
      duration: const Duration(seconds: 3),
      backgroundColor: Colors.red,
      flushbarPosition: FlushbarPosition.TOP,
    ).show(context);
  }
}





  Future<void> _resetPassword() async {
    final email = _emailController.text.trim().toLowerCase();
    if (email.isEmpty) {
      Flushbar(
        message: "Please enter your email first",
        duration: const Duration(seconds: 3),
        backgroundColor: Colors.orange,
        flushbarPosition: FlushbarPosition.TOP,
      ).show(context);
      return;
    }

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);

      Flushbar(
        message:
            "Password reset email sent! Check your inbox and follow the link to set a new password.",
        duration: const Duration(seconds: 4),
        backgroundColor: Colors.green,
        flushbarPosition: FlushbarPosition.TOP,
      ).show(context);
    } catch (e) {
      Flushbar(
        message: "Error: ${e.toString()}",
        duration: const Duration(seconds: 3),
        backgroundColor: Colors.red,
        flushbarPosition: FlushbarPosition.TOP,
      ).show(context);
    }
  }

  Future<void> _signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      final user = userCredential.user;
      final email = user?.email?.toLowerCase();
      final role = (email == 'admin@gmail.com') ? 'Admin' : 'User';

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .set({
        'UserName': user.displayName,
        'Email': email,
        'Role': role,
      }, SetOptions(merge: true));

      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setBool('isLoggedin', true);
      prefs.setString('userEmail', email!);

      Flushbar(
        message: "Google Sign-In successful as $role!",
        duration: const Duration(seconds: 3),
        backgroundColor: Colors.green,
        flushbarPosition: FlushbarPosition.TOP,
      ).show(context);

      Future.delayed(const Duration(seconds: 2), () {
        if (role == 'Admin') {
          Navigator.pushReplacementNamed(context, '/AdminIndex');
        } else {
          Navigator.pushReplacementNamed(context, '/mainhome');
        }
      });
    } catch (e) {
      Flushbar(
        message: "Google Sign-In failed: ${e.toString()}",
        duration: const Duration(seconds: 3),
        backgroundColor: Colors.red,
        flushbarPosition: FlushbarPosition.TOP,
      ).show(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:Colors.green.shade50, // eco-friendly light background
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
             

              // Card Container
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
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Eco Logo
              Image.asset(
                "assets/images/Eco.png",
                height: 70,
              ),
              const SizedBox(height: 20),

                      // Email Field
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
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Enter your email';
                          }
                          if (value.trim()[0] == value.trim()[0].toUpperCase()) {
                            return 'Email cannot start with uppercase';
                          }
                          final emailRegex = RegExp(
                              r'^[a-z][a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
                          if (!emailRegex.hasMatch(value.trim())) {
                            return 'Enter a valid email address';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Password Field
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          labelStyle: GoogleFonts.inter(),
                          prefixIcon: Icon(Icons.lock, color: Colors.green),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: Colors.green,
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
                        validator: (value) =>
                            value!.length < 6 ? 'Password too short' : null,
                      ),
                      const SizedBox(height: 20),

                      // Login Button
                      ElevatedButton(
                        onPressed: _login,
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
                          'Login',
                          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Divider OR
                      Row(
                        children: [
                          Expanded(
                            child: Divider(color: Colors.grey.shade400, thickness: 1),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Text(
                              "OR",
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.black54,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Divider(color: Colors.grey.shade400, thickness: 1),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Google Sign In Button
                      ElevatedButton.icon(
                        onPressed: _signInWithGoogle,
                        icon: Image.asset(
                          'assets/images/google.png',
                          height: 24,
                          width: 24,
                        ),
                        label: Text(
                          'Continue with Google',
                          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black87,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          side: const BorderSide(color: Colors.grey),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Forgot Password
                      TextButton(
                        onPressed: _resetPassword,
                        child: Text(
                          'Forgot Password?',
                          style: GoogleFonts.inter(
                            color: Colors.green,
                            fontWeight: FontWeight.w600,
                          ),
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
