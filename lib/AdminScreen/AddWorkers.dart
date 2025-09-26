import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project/Components/AdminbottomBar.dart';
import 'package:project/Components/AppColors.dart';

class AddWorkers extends StatefulWidget {
  const AddWorkers({Key? key}) : super(key: key);

  @override
  _AddWorkersState createState() => _AddWorkersState();
}

class _AddWorkersState extends State<AddWorkers> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController fullName = TextEditingController();
  final TextEditingController email = TextEditingController();
  final TextEditingController phone = TextEditingController();
  final TextEditingController address = TextEditingController();
  final TextEditingController experience = TextEditingController();
  final TextEditingController startTime = TextEditingController();
  final TextEditingController endTime = TextEditingController();
  final TextEditingController workingHours = TextEditingController();
  final TextEditingController password = TextEditingController();

  String availability = 'Morning';

  Uint8List? _imageBytes;
  String? _base64Image;

  Future<void> pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final imageBytes = await pickedFile.readAsBytes();
      setState(() {
        _imageBytes = imageBytes;
        _base64Image = base64Encode(imageBytes);
      });
    }
  }

  void _calculateWorkingHours() {
    if (startTime.text.isEmpty || endTime.text.isEmpty) return;

    try {
      TimeOfDay start = TimeOfDay(
        hour: int.parse(startTime.text.split(':')[0]),
        minute: 0,
      );
      TimeOfDay end = TimeOfDay(
        hour: int.parse(endTime.text.split(':')[0]),
        minute: 0,
      );

      final duration = end.hour - start.hour;
      workingHours.text = duration > 0 ? '$duration hours' : 'Invalid time';
    } catch (_) {
      workingHours.text = 'Invalid format';
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      if (_base64Image == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select an image')),
        );
        return;
      }

      _calculateWorkingHours();

      try {
        await FirebaseFirestore.instance.collection('workers').add({
          'WorkerName': fullName.text.trim(),
          'email': email.text.trim(),
          'phone': phone.text.trim(),
          'address': address.text.trim(),
          'availability': availability,
          'start_time': startTime.text.trim(),
          'end_time': endTime.text.trim(),
          'working_hours': workingHours.text.trim(),
          'experience': experience.text.trim(),
          'status': 'Active',
          'image': _base64Image,
          'created_at': FieldValue.serverTimestamp(),
          'password': password.text.trim(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Worker Registered Successfully!'),
            backgroundColor: AppColors.peach,
          ),
        );

        fullName.clear();
        email.clear();
        phone.clear();
        address.clear();
        experience.clear();
        startTime.clear();
        endTime.clear();
        workingHours.clear();
        password.clear();

        setState(() {
          _imageBytes = null;
          _base64Image = null;
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Widget _profileText(String title, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Icon(icon, color: Colors.white70, size: 18),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              "$title: $value",
              style: GoogleFonts.spaceGrotesk(
                fontSize: 14,
                color: AppColors.softWhite,
                fontWeight: FontWeight.w400,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              softWrap: false,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, IconData icon,
      {bool isTime = false, bool isPassword = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: TextFormField(
        controller: controller,
        readOnly: isTime,
        obscureText: isPassword,
        onChanged: (_) => setState(() {}),
        onTap: isTime
            ? () async {
                TimeOfDay? picked = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                );
                if (picked != null) {
                  controller.text = picked.format(context);
                  _calculateWorkingHours();
                  setState(() {});
                }
              }
            : null,
        validator: (value) => (value == null || value.isEmpty) ? 'Enter $label' : null,
        decoration: InputDecoration(
          labelText: label,
          suffixIcon: Icon(icon, color: AppColors.paleGreen),
          filled: true,
          fillColor: const Color.fromARGB(217, 233, 239, 242),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.mint),
          ),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: AppColors.peach, width: 1.5),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.iceBlue,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Card with Image + Info + Icons
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: const AssetImage('assets/images/designcard.jpg'),
                          fit: BoxFit.cover,
                          colorFilter: ColorFilter.mode(
                            Colors.black.withOpacity(0.4),
                            BlendMode.darken,
                          ),
                        ),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          const SizedBox(height: 10),
                          Center(
                            child: GestureDetector(
                              onTap: pickImage,
                              child: CircleAvatar(
                                radius: 45,
                                backgroundColor: AppColors.peach,
                                backgroundImage: _imageBytes != null
                                    ? MemoryImage(_imageBytes!)
                                    : null,
                                child: _imageBytes == null
                                    ? const Icon(Icons.add_a_photo, size: 30, color: Colors.white)
                                    : null,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Divider(color: Colors.white, thickness: 1),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 16,
                            runSpacing: 8,
                            children: [
                              SizedBox(width: 160, child: _profileText("Name", fullName.text, Icons.person)),
                              SizedBox(width: 160, child: _profileText("Email", email.text, Icons.email)),
                              SizedBox(width: 160, child: _profileText("Phone", phone.text, Icons.phone)),
                              SizedBox(width: 160, child: _profileText("Address", address.text, Icons.location_on)),
                              SizedBox(width: 160, child: _profileText("Experience", experience.text, Icons.star)),
                              SizedBox(width: 160, child: _profileText("Availability", availability, Icons.access_time)),
                              SizedBox(width: 160, child: _profileText("Start Time", startTime.text, Icons.play_arrow)),
                              SizedBox(width: 160, child: _profileText("End Time", endTime.text, Icons.stop)),
                              SizedBox(width: 160, child: _profileText("Working Hours", workingHours.text, Icons.timelapse)),
                              SizedBox(width: 160, child: _profileText("Password", password.text, Icons.lock)),
                            ],
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: const [
                  Icon(Icons.download_rounded, color: AppColors.paleGreen, size: 28),
                  Icon(Icons.edit, color: AppColors.paleGreen, size: 28),
                  Icon(Icons.delete_forever, color: AppColors.paleGreen, size: 28),
                  Icon(Icons.send, color: AppColors.paleGreen, size: 28),
                ],
              ),
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 20),

              /// Form Fields
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(child: _buildTextField("Full Name", fullName, Icons.person)),
                        const SizedBox(width: 12),
                        Expanded(child: _buildTextField("Email", email, Icons.email)),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(child: _buildTextField("Phone", phone, Icons.phone)),
                        const SizedBox(width: 12),
                        Expanded(child: _buildTextField("Address", address, Icons.location_on)),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(child: _buildTextField("Experience", experience, Icons.star)),
                        const SizedBox(width: 12),
                        Expanded(child: _buildTextField("Start Time", startTime, Icons.access_time, isTime: true)),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(child: _buildTextField("End Time", endTime, Icons.access_time, isTime: true)),
                        const SizedBox(width: 12),
                        Expanded(child: _buildTextField("Working Hours", workingHours, Icons.timelapse)),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(child: _buildTextField("Password", password, Icons.lock, isPassword: true)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: DropdownButtonFormField<String>(
                              value: availability,
                              decoration: InputDecoration(
                                labelText: "Availability",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                filled: true,
                                fillColor: const Color.fromARGB(217, 233, 239, 242),
                              ),
                              items: const [
                                DropdownMenuItem(value: "Morning", child: Text("Morning")),
                                DropdownMenuItem(value: "Evening", child: Text("Evening")),
                              ],
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() => availability = value);
                                }
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _submitForm,
                        icon: const Icon(Icons.person_add_alt_1, color: Colors.white),
                        label: const Text("Register Worker", style: TextStyle(fontSize: 16, color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.peach,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: AdminBottomBar(),
    );
  }
}
