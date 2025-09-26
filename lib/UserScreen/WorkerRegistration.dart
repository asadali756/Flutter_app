import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class WorkerRegisterForm extends StatefulWidget {
  const WorkerRegisterForm({Key? key}) : super(key: key);

  @override
  _WorkerRegisterFormState createState() => _WorkerRegisterFormState();
}

class _WorkerRegisterFormState extends State<WorkerRegisterForm> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController workerNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController imageUrlController = TextEditingController();
  final TextEditingController availabilityController = TextEditingController();
  final TextEditingController startTimeController = TextEditingController();
  final TextEditingController endTimeController = TextEditingController();
  final TextEditingController workingHoursController = TextEditingController();

  Future<void> saveWorker() async {
    if (_formKey.currentState!.validate()) {
      await FirebaseFirestore.instance.collection('workers').add({
        "WorkerName": workerNameController.text,
        "email": emailController.text,
        "phone": phoneController.text,
        "password": passwordController.text,
        "address": addressController.text,
        "image_url": imageUrlController.text,
        "availability": availabilityController.text,
        "start_time": startTimeController.text,
        "end_time": endTimeController.text,
        "working_hours": workingHoursController.text,
        "status": "Requested", // default status
        "created_at": Timestamp.now(),
        "updated_at": DateTime.now().toIso8601String(),
      });

      // Show confirmation dialog
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Success"),
          content: const Text("Worker registered successfully!"),
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
        title: const Text("Worker Registration", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.green.shade700,
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              buildTextField("Worker Name", workerNameController, icon: Icons.person),
              buildTextField("Email", emailController, keyboardType: TextInputType.emailAddress, icon: Icons.email),
              buildTextField("Phone", phoneController, keyboardType: TextInputType.phone, icon: Icons.phone),
              buildTextField("Password", passwordController, obscureText: true, icon: Icons.lock),
              buildTextField("Address", addressController, icon: Icons.location_on),
              buildTextField("Image URL", imageUrlController, icon: Icons.image),
              buildTextField("Availability", availabilityController, icon: Icons.schedule),
              buildTextField("Start Time", startTimeController, icon: Icons.access_time),
              buildTextField("End Time", endTimeController, icon: Icons.access_time),
              buildTextField("Working Hours", workingHoursController, icon: Icons.timelapse),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: saveWorker,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade700,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text("Register Worker", style: TextStyle(fontSize: 16)),
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
