import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class NGORegisterForm extends StatefulWidget {
  const NGORegisterForm({Key? key}) : super(key: key);

  @override
  _NGORegisterFormState createState() => _NGORegisterFormState();
}

class _NGORegisterFormState extends State<NGORegisterForm> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController ngonameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController imageUrlController = TextEditingController();

  Future<void> saveNGO() async {
    if (_formKey.currentState!.validate()) {
      await FirebaseFirestore.instance.collection('ngos').add({
        "ngoname": ngonameController.text,
        "email": emailController.text,
        "phone": phoneController.text,
        "password": passwordController.text,
        "address": addressController.text,
        "image_url": imageUrlController.text,
        "status": "Requested", // Default status
        "type": "NGO",
        "created_at": Timestamp.now(),
      });

      // Show confirmation dialog
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Success"),
          content: const Text("NGO registered successfully!"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Close form
              },
              child: const Text("OK"),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("NGO Registration", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.green.shade700,
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              buildTextField("NGO Name", ngonameController, icon: Icons.business),
              buildTextField("Email", emailController, keyboardType: TextInputType.emailAddress, icon: Icons.email),
              buildTextField("Phone", phoneController, keyboardType: TextInputType.phone, icon: Icons.phone),
              buildTextField("Password", passwordController, obscureText: true, icon: Icons.lock),
              buildTextField("Address", addressController, icon: Icons.location_on),
              buildTextField("Image URL", imageUrlController, icon: Icons.image),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: saveNGO,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade700,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text("Register NGO", style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTextField(
    String label,
    TextEditingController controller, {
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    IconData? icon,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        validator: (value) =>
            value == null || value.isEmpty ? "Enter $label" : null,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: icon != null ? Icon(icon, color: Colors.green) : null,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.green.shade700),
          ),
        ),
      ),
    );
  }
}
