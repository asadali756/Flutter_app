import 'dart:convert';
import 'dart:typed_data';
import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:project/Components/AppColors.dart';

class AddCatgeory extends StatefulWidget {
  const AddCatgeory({Key? key}) : super(key: key);

  @override
  _AddCatgeoryState createState() => _AddCatgeoryState();
}

class _AddCatgeoryState extends State<AddCatgeory> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _categoryController = TextEditingController();
  Uint8List? _imageBytes;
  String? _base64Image;

  void _showFlushBar(String message, Color color, IconData icon) {
    Flushbar(
      margin: const EdgeInsets.all(8),
      borderRadius: BorderRadius.circular(8),
      icon: Icon(icon, color: Colors.white),
      backgroundColor: color,
      duration: const Duration(seconds: 2),
      messageText: Text(
        message,
        style: GoogleFonts.inter(
          color: Colors.white,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),
    ).show(context);
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final imageBytes = await pickedFile.readAsBytes();
      setState(() {
        _imageBytes = imageBytes;
        _base64Image = base64Encode(imageBytes);
      });
    }
  }

  Future<void> _addCategoryToFirestore(String categoryName) async {
    try {
      await FirebaseFirestore.instance.collection('category').add({
        'name': categoryName,
        'image': _base64Image ?? '',
        'createdAt': Timestamp.now(),
      });

      _showFlushBar("Category '$categoryName' added", AppColors.deepTeal, Icons.check_circle);
      _categoryController.clear();
      setState(() {
        _imageBytes = null;
        _base64Image = null;
      });
    } catch (e) {
      _showFlushBar("Error: ${e.toString()}", Colors.red, Icons.error_outline);
    }
  }

  void _handleAddCategory() {
    final category = _categoryController.text.trim();
    if (category.isEmpty) {
      _showFlushBar("Category name is required!", Colors.red, Icons.warning_amber_rounded);
      return;
    }
    if (_imageBytes == null) {
      _showFlushBar("Please select an image!", Colors.red, Icons.image_not_supported_outlined);
      return;
    }
    _addCategoryToFirestore(category);
  }

  Future<void> _showEditDialog(String docId, String oldName, String oldImage) async {
    final TextEditingController _editController = TextEditingController(text: oldName);
    Uint8List? editedImage = base64Decode(oldImage);
    String? editedBase64 = oldImage;

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.softWhite,
        title: Text("Edit Category", style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: () async {
                final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
                if (picked != null) {
                  final bytes = await picked.readAsBytes();
                  setState(() {
                    editedImage = bytes;
                    editedBase64 = base64Encode(bytes);
                  });
                }
              },
              child: Container(
                height: 100,
                width: 100,
                decoration: BoxDecoration(
                  color: AppColors.paleGreen,
                  borderRadius: BorderRadius.circular(8),
                  image: editedImage != null
                      ? DecorationImage(image: MemoryImage(editedImage!), fit: BoxFit.cover)
                      : null,
                ),
                child: editedImage == null
                    ? const Icon(Icons.add_a_photo, color: Colors.white)
                    : null,
              ),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _editController,
              decoration: InputDecoration(
                labelText: "Category Name",
                labelStyle: GoogleFonts.inter(color: AppColors.deepTeal),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            child: Text("Cancel", style: GoogleFonts.inter()),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: Text("Save", style: GoogleFonts.inter(color: AppColors.deepTeal)),
            onPressed: () async {
              final newName = _editController.text.trim();
              if (newName.isNotEmpty) {
                await FirebaseFirestore.instance.collection('category').doc(docId).update({
                  'name': newName,
                  'image': editedBase64 ?? '',
                });
                _showFlushBar("Category updated", Colors.green, Icons.edit);
              }
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.iceBlue,
      appBar: AppBar(
        backgroundColor: AppColors.deepTeal,
        title: Text(
          "Add Category",
          style: GoogleFonts.spaceGrotesk(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.iceBlue,
          ),
        ),
        iconTheme: const IconThemeData(color: AppColors.iceBlue),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 16),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _categoryController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AppColors.softWhite,
                      labelText: "Category Name",
                      labelStyle: GoogleFonts.inter(fontSize: 14, color: AppColors.deepTeal),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      height: 40,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppColors.paleGreen,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Center(
                        child: Text("Select Image", style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _handleAddCategory,
                      icon: const Icon(Icons.add, color: AppColors.iceBlue),
                      label: Text(
                        "Add Category",
                        style: GoogleFonts.inter(
                          color: AppColors.iceBlue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.paleGreen,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        elevation: 3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('category')
                    .orderBy('createdAt', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Center(child: Text("Something went wrong"));
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final categories = snapshot.data!.docs;

                  if (categories.isEmpty) {
                    return Text("No categories yet.",
                        style: GoogleFonts.inter(color: AppColors.deepTeal));
                  }

                  return ListView.builder(
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final doc = categories[index];
                      final name = doc['name'];
                      final image = doc['image'];

                      return Card(
                        color: AppColors.softWhite,
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            children: [
                              // Image on left
                              if (image.isNotEmpty)
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.memory(
                                    base64Decode(image),
                                    height: 50,
                                    width: 50,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              else
                                Container(
                                  height: 50,
                                  width: 50,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(Icons.image_not_supported),
                                ),

                              const SizedBox(width: 12),

                              // Name in center
                              Expanded(
                                child: Text(
                                  name,
                                  style: GoogleFonts.spaceGrotesk(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.deepTeal,
                                  ),
                                ),
                              ),

                              // Edit and delete icons
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.orange),
                                onPressed: () => _showEditDialog(doc.id, name, image ?? ''),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () async {
                                  await FirebaseFirestore.instance
                                      .collection('category')
                                      .doc(doc.id)
                                      .delete();
                                  _showFlushBar("Category '$name' deleted", Colors.red, Icons.delete);
                                },
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
      ),
    );
  }
}
