import 'dart:convert';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project/Components/AppColors.dart';

class ShowWorkers extends StatefulWidget {
  const ShowWorkers({Key? key}) : super(key: key);

  @override
  _ShowWorkersState createState() => _ShowWorkersState();
}

class _ShowWorkersState extends State<ShowWorkers> {
  final CollectionReference workersRef = FirebaseFirestore.instance.collection('workers');
  String statusFilter = 'All';

  final Map<String, IconData> filterIcons = {
    'All': Icons.list,
    'Active': Icons.check_circle_outline,
    'Inactive': Icons.block,
  };

  Future<void> _confirmDelete(String docId) async {
    bool? confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.paleGreen,
        title: const Text("Confirm Delete", style: TextStyle(color: Colors.white)),
        content: const Text("Are you sure you want to delete this worker?", style: TextStyle(color: Colors.white)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text("No", style: TextStyle(color: Colors.white)),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text("Yes", style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await workersRef.doc(docId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Worker deleted successfully")),
      );
    }
  }

  void _showEditModal(BuildContext context, String docId, Map<String, dynamic> data) {
    final nameController = TextEditingController(text: data['WorkerName']);
    final emailController = TextEditingController(text: data['email']);
    final phoneController = TextEditingController(text: data['phone']);
    final addressController = TextEditingController(text: data['address']);
    final experienceController = TextEditingController(text: data['experience']);
    final startTimeController = TextEditingController(text: data['start_time']);
    final endTimeController = TextEditingController(text: data['end_time']);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.iceBlue,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
         title: Center(
      child: Text(
        "Edit Worker",
        style: GoogleFonts.spaceGrotesk(
          color: AppColors.paleGreen,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
    ),

          content: SingleChildScrollView(
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(child: _buildEditField("Full Name", nameController)),
                    const SizedBox(width: 10),
                    Expanded(child: _buildEditField("Email", emailController)),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(child: _buildEditField("Phone", phoneController)),
                    const SizedBox(width: 10),
                    Expanded(child: _buildEditField("Address", addressController)),
                  ],
                ),
                const SizedBox(height: 10),
                _buildEditField("Experience", experienceController),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(child: _buildEditField("Start Time", startTimeController)),
                    const SizedBox(width: 10),
                    Expanded(child: _buildEditField("End Time", endTimeController)),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancel", style: TextStyle(color: Colors.redAccent)),
            ),
            TextButton(
              onPressed: () async {
                await workersRef.doc(docId).update({
                  'WorkerName': nameController.text.trim(),
                  'email': emailController.text.trim(),
                  'phone': phoneController.text.trim(),
                  'address': addressController.text.trim(),
                  'experience': experienceController.text.trim(),
                  'start_time': startTimeController.text.trim(),
                  'end_time': endTimeController.text.trim(),
                });
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Worker updated successfully")),
                );
              },
              child: const Text("Save", style: TextStyle(color: AppColors.paleGreen)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEditField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.iceBlue,
      // appBar: AppBar(
      //   backgroundColor: AppColors.paleGreen,
      //   title: Text(
      //     "Workers Info",
      //     style: GoogleFonts.spaceGrotesk(
      //       color: Colors.white,
      //       fontWeight: FontWeight.bold,
      //       fontSize: 20,
      //     ),
      //   ),
      //   iconTheme: const IconThemeData(color: Colors.white),
      // ),
      body: Column(
        children: [
          // 🔹 Filter Buttons with Icons
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(12),
            child: Row(
              children: filterIcons.entries.map((entry) {
                final isSelected = statusFilter == entry.key;
                return Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: ElevatedButton.icon(
                    icon: Icon(entry.value, size: 18),
                    label: Text(entry.key),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isSelected ? AppColors.paleGreen : Colors.grey.shade300,
                      foregroundColor: isSelected ? Colors.white : Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () => setState(() => statusFilter = entry.key),
                  ),
                );
              }).toList(),
            ),
          ),

          // 🔹 Firestore List
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: workersRef.orderBy('created_at', descending: true).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) return const Center(child: Text("Error loading data"));
                if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("No workers registered yet."));
                }

                final docs = statusFilter == 'All'
                    ? snapshot.data!.docs
                    : snapshot.data!.docs.where((doc) =>
                        (doc['status'] ?? '').toString().toLowerCase() == statusFilter.toLowerCase()).toList();

                if (docs.isEmpty) {
                  return const Center(
                    child: Text(
                      "No Workers Found",
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    var doc = docs[index];
                    var data = doc.data() as Map<String, dynamic>;

                    Uint8List? imageBytes;
                    if (data['image'] != null && data['image'] != "") {
                      imageBytes = base64Decode(data['image']);
                    }

                    return Card(
                      elevation: 4,
                      color: AppColors.paleGreen,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      child: Padding(
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(
                              child: CircleAvatar(
                                radius: 45,
                                backgroundColor: AppColors.peach.withOpacity(0.8),
                                backgroundImage: imageBytes != null ? MemoryImage(imageBytes) : null,
                                child: imageBytes == null
                                    ? const Icon(Icons.person, size: 40, color: Colors.white)
                                    : null,
                              ),
                            ),
                            const SizedBox(height: 12),
                            const Divider(color: Colors.white70, thickness: 1),
                            const SizedBox(height: 12),
                            _infoRow("Name", data['WorkerName'], Icons.person, "Email", data['email'], Icons.email),
                            _infoRow("Phone", data['phone'], Icons.phone, "Address", data['address'], Icons.location_on),
                            _infoRow("Experience", data['experience'], Icons.star, "Availability", data['availability'], Icons.access_time),
                            _infoRow("Start Time", data['start_time'], Icons.play_arrow, "End Time", data['end_time'], Icons.stop),
                            _infoRow("Working Hours", data['working_hours'], Icons.timelapse, "Active", data['status'], Icons.assignment_turned_in),
                            const SizedBox(height: 14),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                // const Icon(Icons.download, color: Colors.white, size: 24),
                                GestureDetector(
                                  onTap: () => _showEditModal(context, doc.id, data),
                                  child: const Icon(Icons.edit, color: Colors.white, size: 24),
                                ),
                                GestureDetector(
                                  onTap: () => _confirmDelete(doc.id),
                                  child: const Icon(Icons.delete, color: Colors.white, size: 24),
                                ),
                                const Icon(Icons.send, color: Colors.white, size: 24),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _info(String title, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, color: Colors.white70, size: 18),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              "$title: ${value.isNotEmpty ? value : "N/A"}",
              style: GoogleFonts.spaceGrotesk(
                fontSize: 14,
                color: AppColors.softWhite,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String title1, String value1, IconData icon1, String title2, String value2, IconData icon2) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(child: _info(title1, value1, icon1)),
          const SizedBox(width: 8),
          Expanded(child: _info(title2, value2, icon2)),
        ],
      ),
    );
  }
}
