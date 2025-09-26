import 'dart:io';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import 'package:project/Components/AppColors.dart';

class SellerProduct extends StatefulWidget {
  const SellerProduct({Key? key}) : super(key: key);

  @override
  State<SellerProduct> createState() => _SellerProductState();
}

class _SellerProductState extends State<SellerProduct> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  String? selectedCategory;
  List<String> categories = [];
  File? selectedImage;
  Uint8List? webImage;

  final String imgBBApiKey = "90cb66237e5781971422bd58ed770554";

  @override
  void initState() {
    super.initState();
    fetchCategories();
  }

  void fetchCategories() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('sellercategory').get();
      setState(() {
        categories =
            snapshot.docs.map((doc) => doc['categoryname'].toString()).toList();
      });
    } catch (e) {
      if (kDebugMode) print('Error fetching categories: $e');
    }
  }

  Future pickImage() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        if (kIsWeb) {
          final bytes = await pickedFile.readAsBytes();
          setState(() {
            webImage = bytes;
            selectedImage = null;
          });
        } else {
          setState(() {
            selectedImage = File(pickedFile.path);
            webImage = null;
          });
        }
      }
    } catch (e) {
      if (kDebugMode) print('Error picking image: $e');
    }
  }

  Future<String> uploadImageToImgBB() async {
    final uri =
        Uri.parse("https://api.imgbb.com/1/upload?key=$imgBBApiKey");

    var request = http.MultipartRequest("POST", uri);

    if (kIsWeb && webImage != null) {
      request.files.add(http.MultipartFile.fromBytes(
        'image',
        webImage!,
        filename: "upload.png",
      ));
    } else if (selectedImage != null) {
      request.files.add(await http.MultipartFile.fromPath(
        'image',
        selectedImage!.path,
      ));
    } else {
      throw 'No image selected';
    }

    var response = await request.send();
    var resBody = await response.stream.bytesToString();
    var data = jsonDecode(resBody);

    if (response.statusCode == 200 && data["success"] == true) {
      return data["data"]["url"];
    } else {
      throw Exception("ImgBB Upload failed: ${data["error"]["message"]}");
    }
  }

  void submitForm() async {
    if (_formKey.currentState!.validate() &&
        selectedCategory != null &&
        (selectedImage != null || webImage != null)) {
      try {
        DocumentReference docRef =
            await FirebaseFirestore.instance.collection('SellerProduct').add({
          'title': _titleController.text.trim(),
          'description': _descController.text.trim(),
          'price': double.parse(_priceController.text.trim()),
          'category': selectedCategory,
          'image_url': '',
            'status': 'new',
          'created_at': FieldValue.serverTimestamp(),
        });

        try {
          String imageUrl = await uploadImageToImgBB();
          await docRef.update({'image_url': imageUrl});
        } catch (e) {
          if (kDebugMode) print('Image upload failed: $e');
        }

        // Success dialog
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            backgroundColor: AppColors.softWhite,
            title: Text("✅ Success",
                style: GoogleFonts.spaceGrotesk(
                    color: AppColors.paleGreen, fontWeight: FontWeight.bold)),
            content: Text("Product has been added successfully!",
                style: GoogleFonts.inter()),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("OK",
                    style: GoogleFonts.inter(color: AppColors.paleGreen)),
              )
            ],
          ),
        );

        _formKey.currentState!.reset();
        setState(() {
          selectedCategory = null;
          selectedImage = null;
          webImage = null;
        });
      } catch (e) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Fill all fields and pick an image')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.iceBlue,
     appBar: AppBar(
  backgroundColor: AppColors.paleGreen,
  iconTheme: const IconThemeData(color: Colors.white), // ✅ back icon white
  centerTitle: true,
  title: Column(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      Text(
        "Add Product",
        style: GoogleFonts.spaceGrotesk(
          color: AppColors.iceBlue,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      const SizedBox(height: 2),
      Text(
        "Adding hand-made products with love", // ✅ punch line
        style: GoogleFonts.spaceGrotesk(
          color: Colors.white, // subtitle in white
          fontSize: 12,
        ),
      ),
    ],
  ),
),
  body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [

                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _titleController,
                        decoration: InputDecoration(
                          labelText: 'Title',
                          labelStyle: GoogleFonts.inter(),
                          filled: true,
                          fillColor: AppColors.softWhite,
                          border: const OutlineInputBorder(),
                        ),
                        validator: (val) =>
                            val!.isEmpty ? 'Enter title' : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _descController,
                        decoration: InputDecoration(
                          labelText: 'Description',
                          labelStyle: GoogleFonts.inter(),
                          filled: true,
                          fillColor: AppColors.softWhite,
                          border: const OutlineInputBorder(),
                        ),
                        validator: (val) =>
                            val!.isEmpty ? 'Enter description' : null,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _priceController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Price',
                          labelStyle: GoogleFonts.inter(),
                          filled: true,
                          fillColor: AppColors.softWhite,
                          border: const OutlineInputBorder(),
                        ),
                        validator: (val) =>
                            val!.isEmpty ? 'Enter price' : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: selectedCategory,
                        items: categories
                            .map((cat) => DropdownMenuItem(
                                  value: cat,
                                  child: Text(cat, style: GoogleFonts.inter()),
                                ))
                            .toList(),
                        onChanged: (val) =>
                            setState(() => selectedCategory = val),
                        decoration: InputDecoration(
                          labelText: 'Category',
                          labelStyle: GoogleFonts.inter(),
                          filled: true,
                          fillColor: AppColors.softWhite,
                          border: const OutlineInputBorder(),
                        ),
                        validator: (val) =>
                            val == null ? 'Select category' : null,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                Row(
                  children: [
                    // If image selected show preview, else show pick button
                    InkWell(
                      onTap: pickImage,
                      child: CircleAvatar(
                        radius: 26,
                        backgroundColor: AppColors.paleGreen,
                        backgroundImage: selectedImage != null
                            ? FileImage(selectedImage!)
                            : (webImage != null
                                ? MemoryImage(webImage!)
                                : null) as ImageProvider?,
                        child: (selectedImage == null && webImage == null)
                            ? const Icon(Icons.add_a_photo,
                                color: Colors.white, size: 26)
                            : null,
                      ),
                    ),

                    const SizedBox(width: 16),

                    // Add Product Button
                    Expanded(
                      child: ElevatedButton(
                        onPressed: submitForm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.paleGreen,
                          padding: const EdgeInsets.symmetric(
                              vertical: 16, horizontal: 20),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        child: Text("Add Product",
                            style: GoogleFonts.spaceGrotesk(
                                fontSize: 16, color: AppColors.iceBlue)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
