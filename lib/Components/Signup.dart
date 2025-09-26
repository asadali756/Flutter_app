import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:project/Components/AppColors.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Your custom color file

class Signup extends StatefulWidget {
  const Signup({Key? key}) : super(key: key);

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _signup() async {
    if (_formKey.currentState!.validate()) {
      try {
        final email = _emailController.text.trim().toLowerCase();
        final role = (email == 'admin@gmail.com') ? 'Admin' : 'User';

        UserCredential userCredential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: _passwordController.text.trim(),
        );

        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .set({
          'UserName': _usernameController.text.trim(),
          'Email': email,
          'Password': _passwordController.text.trim(),
          'Role': role,
        });

        _usernameController.clear();
        _emailController.clear();
        _passwordController.clear();

        Flushbar(
          message: "Signup successful as $role!",
          duration: const Duration(seconds: 3),
          backgroundColor: Colors.green,
          flushbarPosition: FlushbarPosition.TOP,
        ).show(context);


SharedPreferences prefs = await SharedPreferences.getInstance();
prefs.setBool('isLoggedin', true);

        Future.delayed(const Duration(seconds: 2), () {
          if (role == 'Admin') {
            Navigator.pushReplacementNamed(context, '/admin');
          } else {
            Navigator.pushReplacementNamed(context, '/mainhome');
          }
        });
      } catch (e) {
        Flushbar(
          message: "Signup failed: ${e.toString()}",
          duration: const Duration(seconds: 3),
          backgroundColor: Colors.red,
          flushbarPosition: FlushbarPosition.TOP,
        ).show(context);
      }
    }
  }

  Future<void> signInWithGoogle(BuildContext context) async {
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

      Flushbar(
        message: "Google Sign-In successful as $role!",
        duration: const Duration(seconds: 3),
        backgroundColor: Colors.green,
        flushbarPosition: FlushbarPosition.TOP,
      ).show(context);

      Future.delayed(const Duration(seconds: 2), () {
        if (role == 'Admin') {
          Navigator.pushReplacementNamed(context, '/admin');
        } else {
          Navigator.pushReplacementNamed(context, '/mainhome');
        }
      });
    } catch (e) {
      print('Google Sign-In error: $e');
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
      backgroundColor: AppColors.iceBlue,
      body: Center(
        child: Container(
          width: 350,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.softWhite,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 8)],
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Sign Up',
                  style: GoogleFonts.inter(
                    fontSize: 26,
                    color: AppColors.deepTeal,
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    labelText: 'User Name',
                    labelStyle: GoogleFonts.inter(),
                  ),
                  validator: (value) =>
                      value!.isEmpty ? 'Enter your name' : null,
                ),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    labelStyle: GoogleFonts.inter(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Enter your email';
                    }
                    if (value.trim()[0] == value.trim()[0].toUpperCase()) {
                      return 'Email cannot start with an uppercase letter';
                    }
                    final emailRegex = RegExp(
                        r'^[a-z][a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
                    if (!emailRegex.hasMatch(value.trim())) {
                      return 'Enter a valid email address';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    labelStyle: GoogleFonts.inter(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: AppColors.deepTeal,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                  validator: (value) =>
                      value!.length < 6 ? 'Password too short' : null,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _signup,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.deepTeal,
                    foregroundColor: AppColors.iceBlue,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    'Register',
                    style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                  ),
                ),

                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Divider(
                        color: Colors.grey.shade400,
                        thickness: 1,
                        height: 1,
                      ),
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
                      child: Divider(
                        color: Colors.grey.shade400,
                        thickness: 1,
                        height: 1,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                ElevatedButton.icon(
                  onPressed: () => signInWithGoogle(context),
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
                    backgroundColor: AppColors.softWhite,
                    foregroundColor: Colors.black87,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    side: const BorderSide(color: Colors.grey),
                  ),
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () =>
                      Navigator.pushReplacementNamed(context, "/Login"),
                  child: Text(
                    "Already have an account? Login",
                    style: GoogleFonts.inter(
                      color: AppColors.deepTeal,
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
