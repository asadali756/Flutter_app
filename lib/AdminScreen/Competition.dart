import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:project/Components/AppColors.dart';
import 'package:google_fonts/google_fonts.dart';

class Competition extends StatefulWidget {
  const Competition({Key? key}) : super(key: key);

  @override
  _CompetitionState createState() => _CompetitionState();
}

class _CompetitionState extends State<Competition> {
  String? selectedCompetitionType;
  String? selectedAudience;
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  DateTime? startDate;
  DateTime? endDate;
  File? selectedImage;
  Uint8List? webImage;
  String? _base64Image;

  Future<void> _pickDate(bool isStartDate) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          startDate = picked;
        } else {
          endDate = picked;
        }
      });
    }
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      final bytes = await picked.readAsBytes();
      setState(() {
        if (kIsWeb) {
          webImage = bytes;
        } else {
          selectedImage = File(picked.path);
        }
        _base64Image = base64Encode(bytes);
      });
    }
  }

  void _showAddModal(String type) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.softWhite,
        title: Text('Add $type',
            style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.bold)),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: 'Enter $type',
            labelStyle: GoogleFonts.inter(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                FirebaseFirestore.instance
                    .collection(type)
                    .add({'name': controller.text});
                Navigator.pop(context);
              }
            },
            child: Text('Add', style: GoogleFonts.inter(color: AppColors.deepTeal)),
          ),
        ],
      ),
    );
  }

  void _submitForm() async {
    if (titleController.text.isNotEmpty &&
        descriptionController.text.isNotEmpty &&
        selectedCompetitionType != null &&
        selectedAudience != null &&
        startDate != null &&
        endDate != null &&
        _base64Image != null) {
      await FirebaseFirestore.instance.collection('Competition').add({
        'title': titleController.text,
        'description': descriptionController.text,
        'startDate': startDate!.toIso8601String(),
        'endDate': endDate!.toIso8601String(),
        'competitionType': selectedCompetitionType,
        'audience': selectedAudience,
        'image': _base64Image,
      });

await FirebaseFirestore.instance.collection('Notifications').add({
  'title': '🎉 New Competition Announcement!',
  'body': 'A new competition has been added. Tap to check it out!',
  'route': '/AddCompetition', // Route defined in MaterialApp
  'timestamp': Timestamp.now(),
  'isRead': false,
});



      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Competition Added")));

      setState(() {
        titleController.clear();
        descriptionController.clear();
        selectedAudience = null;
        selectedCompetitionType = null;
        startDate = null;
        endDate = null;
        selectedImage = null;
        webImage = null;
        _base64Image = null;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please fill all fields and select an image")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.iceBlue,
      appBar: AppBar(
        backgroundColor: AppColors.deepTeal,
        title: Text("Add Competition",
            style: GoogleFonts.spaceGrotesk(color: AppColors.iceBlue)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.softWhite,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.deepTeal,
                    ),
                    onPressed: () => _showAddModal('CompetitionType'),
                    child: Text("Add Competition Type",
                        style: GoogleFonts.inter(color: AppColors.iceBlue)),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.deepTeal,
                    ),
                    onPressed: () => _showAddModal('TargetAudience'),
                    child: Text("Add Who Can Participate",
                        style: GoogleFonts.inter(color: AppColors.iceBlue)),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              TextField(
                controller: titleController,
                style: GoogleFonts.inter(),
                decoration: InputDecoration(
                  labelText: 'Title',
                  labelStyle: GoogleFonts.inter(),
                  filled: true,
                  fillColor: AppColors.paleGreen.withOpacity(0.1),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descriptionController,
                style: GoogleFonts.inter(),
                decoration: InputDecoration(
                  labelText: 'Description',
                  labelStyle: GoogleFonts.inter(),
                  filled: true,
                  fillColor: AppColors.paleGreen.withOpacity(0.1),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      startDate == null
                          ? 'Start Date not selected'
                          : 'Start: ${startDate.toString().split(' ')[0]}',
                      style: GoogleFonts.inter(),
                    ),
                  ),
                  TextButton(
                    onPressed: () => _pickDate(true),
                    child: Text("Pick Start Date",
                        style: GoogleFonts.inter(
                          color: AppColors.deepTeal,
                        )),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      endDate == null
                          ? 'End Date not selected'
                          : 'End: ${endDate.toString().split(' ')[0]}',
                      style: GoogleFonts.inter(),
                    ),
                  ),
                  TextButton(
                    onPressed: () => _pickDate(false),
                    child: Text("Pick End Date",
                        style: GoogleFonts.inter(
                          color: AppColors.deepTeal,
                        )),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: _pickImage,
                    style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.deepTeal),
                    child: Text("Pick Image",
                        style: GoogleFonts.inter(color: AppColors.iceBlue)),
                  ),
                  const SizedBox(width: 10),
                  selectedImage != null || webImage != null
                      ? kIsWeb
                          ? Image.memory(webImage!, height: 50, width: 50)
                          : Image.file(selectedImage!, height: 50, width: 50)
                      : Text("No image selected",
                          style: GoogleFonts.inter(color: Colors.grey)),
                ],
              ),
              const SizedBox(height: 16),
              _buildDropdown(
                title: "Select Competition Type",
                value: selectedCompetitionType,
                stream: FirebaseFirestore.instance
                    .collection('CompetitionType')
                    .snapshots(),
                onChanged: (val) => setState(() => selectedCompetitionType = val),
              ),
              const SizedBox(height: 8),
              _buildDropdown(
                title: "Select Audience",
                value: selectedAudience,
                stream: FirebaseFirestore.instance
                    .collection('TargetAudience')
                    .snapshots(),
                onChanged: (val) => setState(() => selectedAudience = val),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.deepTeal,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                ),
                child: Text("Submit Competition",
                    style: GoogleFonts.spaceGrotesk(
                        fontSize: 14, color: AppColors.iceBlue)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String title,
    required String? value,
    required Stream<QuerySnapshot> stream,
    required Function(String?) onChanged,
  }) {
    return StreamBuilder<QuerySnapshot>(
      stream: stream,
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return DropdownButton<String>(
            hint: Text("$title (Empty)", style: GoogleFonts.inter()),
            value: null,
            items: [
              DropdownMenuItem(value: null, child: Text("No Selected"))
            ],
            onChanged: (_) {},
          );
        }
        return DropdownButton<String>(
          hint: Text(title, style: GoogleFonts.inter()),
          value: value,
          isExpanded: true,
          onChanged: onChanged,
          items: snapshot.data!.docs.map((doc) {
            final name = (doc.data() as Map<String, dynamic>)['name'] ?? 'Unnamed';
            return DropdownMenuItem<String>(
              value: name,
              child: Text(name, style: GoogleFonts.inter()),
            );
          }).toList(),
        );
      },
    );
  }
}