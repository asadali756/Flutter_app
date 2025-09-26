import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class WorkerProfile extends StatefulWidget {
  const WorkerProfile({super.key});

  @override
  State<WorkerProfile> createState() => _WorkerProfileState();
}

class _WorkerProfileState extends State<WorkerProfile> {
  String workerId = "";
  String workerName = "";
  String email = "";
  String phone = "";
  String address = "";
  String availability = "";
  String status = "";
  String imageUrl = "";
  String workingHours = "";
  String startTime = "";
  String endTime = "";
  String createdAt = "";

  bool isLoading = true;

  // ✅ Text controllers for editing
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController availabilityController = TextEditingController();
  final TextEditingController statusController = TextEditingController();
  final TextEditingController workingHoursController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadWorkerData();
  }

  Future<void> loadWorkerData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      workerId = prefs.getString('workerId') ?? "";
      workerName = prefs.getString('WorkerName') ?? "";
      email = prefs.getString('email') ?? "";
      phone = prefs.getString('phone') ?? "";
      address = prefs.getString('address') ?? "";
      availability = prefs.getString('availability') ?? "";
      status = prefs.getString('status') ?? "";
      imageUrl = prefs.getString('image_url') ?? "";
      workingHours = prefs.getString('working_hours') ?? "";
      startTime = prefs.getString('start_time') ?? "";
      endTime = prefs.getString('end_time') ?? "";
      createdAt = prefs.getString('created_at') ?? "";

      // ✅ set controllers
      nameController.text = workerName;
      phoneController.text = phone;
      addressController.text = address;
      availabilityController.text = availability;
      statusController.text = status;
      workingHoursController.text = workingHours;

      isLoading = false;
    });
  }

  Future<void> updateWorkerData() async {
    if (workerId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Worker ID not found")),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance
          .collection("workers")
          .doc(workerId) // ✅ doc id must be same as workerId
          .update({
        "WorkerName": nameController.text.trim(),
        "phone": phoneController.text.trim(),
        "address": addressController.text.trim(),
        "availability": availabilityController.text.trim(),
        "status": statusController.text.trim(),
        "working_hours": workingHoursController.text.trim(),
        "updated_at": DateTime.now().toIso8601String(),
      });

      // ✅ Also update locally
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString("WorkerName", nameController.text.trim());
      await prefs.setString("phone", phoneController.text.trim());
      await prefs.setString("address", addressController.text.trim());
      await prefs.setString("availability", availabilityController.text.trim());
      await prefs.setString("status", statusController.text.trim());
      await prefs.setString("working_hours", workingHoursController.text.trim());

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile updated successfully")),
      );

      setState(() {
        workerName = nameController.text.trim();
        phone = phoneController.text.trim();
        address = addressController.text.trim();
        availability = availabilityController.text.trim();
        status = statusController.text.trim();
        workingHours = workingHoursController.text.trim();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Update failed: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
     appBar: AppBar(
  title: const Text(
    "My Profile",
    style: TextStyle(color: Colors.white), // ✅ Title text in white
  ),
  backgroundColor: Colors.green, // ✅ Green background
  foregroundColor: Colors.white, // ✅ Icons in white
  actions: [
    IconButton(
      icon: const Icon(Icons.save, color: Colors.white), // ✅ Save icon white
      onPressed: updateWorkerData, // ✅ Save changes
    ),
  ],
),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Profile Picture
            CircleAvatar(
              radius: 60,
              backgroundImage: imageUrl.isNotEmpty
                  ? NetworkImage(imageUrl)
                  : const AssetImage("assets/default_profile.png")
                      as ImageProvider,
            ),
            const SizedBox(height: 16),

            // Name
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "Name"),
            ),
            const SizedBox(height: 8),

            // Email (not editable)
            Text(
              email,
              style: const TextStyle(color: Colors.grey, fontSize: 16),
            ),
            const SizedBox(height: 20),

            // Editable fields
            buildEditableTile("Phone", phoneController),
            buildEditableTile("Address", addressController),
            buildEditableTile("Availability", availabilityController),
            buildEditableTile("Status", statusController),
            buildEditableTile("Working Hours", workingHoursController),

            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: updateWorkerData,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              child: const Text("Update Profile"),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildEditableTile(String title, TextEditingController controller) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        title: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: title,
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }
}
