import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project/Components/AppColors.dart';
import 'package:project/Components/AdminbottomBar.dart';

class AddSeller extends StatefulWidget {
  const AddSeller({Key? key}) : super(key: key);

  @override
  State<AddSeller> createState() => _AddSellerState();
}

class _AddSellerState extends State<AddSeller> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController fullName = TextEditingController();
  final TextEditingController lastName = TextEditingController();
  final TextEditingController email = TextEditingController();
  final TextEditingController phone = TextEditingController();
  final TextEditingController password = TextEditingController();
  final TextEditingController brandName = TextEditingController();
  final TextEditingController address = TextEditingController();

  Uint8List? _imageBytes;
  String? _base64Image;

  List<String> categoryList = [];
  List<String> selectedCategories = [];

  @override
  void initState() {
    super.initState();
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('category').get();
      setState(() {
        categoryList = snapshot.docs.map((doc) => doc['name'].toString()).toList();
      });
    } catch (e) {
      print("Error fetching categories: $e");
    }
  }

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

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate() && selectedCategories.isNotEmpty) {
      try {
await FirebaseFirestore.instance.collection('sellers').add({
  'fullName': fullName.text.trim(),
  'lastName': lastName.text.trim(),
  'email': email.text.trim(),
  'phone': phone.text.trim(),
  'password': password.text.trim(),
  'brandName': brandName.text.trim(),
  'address': address.text.trim(),
  'categories': selectedCategories,
  'status': 'Active', // <-- Added line
  'image': _base64Image ?? '',
  'created_at': FieldValue.serverTimestamp(),
});


        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Seller Registered Successfully!'),
            backgroundColor: AppColors.deepTeal,
          ),
        );

        fullName.clear();
        lastName.clear();
        email.clear();
        phone.clear();
        password.clear();
        brandName.clear();
        address.clear();
        setState(() {
          selectedCategories.clear();
          _imageBytes = null;
          _base64Image = null;
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
    }
  }

  Widget _buildTextField(String label, TextEditingController controller, IconData icon,
      {bool isPassword = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword,
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
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  children: [
                    Container(
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage('assets/images/designcard.jpg'),
                          fit: BoxFit.cover,
                          colorFilter: ColorFilter.mode(
                            Colors.black45,
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
                                    ? const Icon(Icons.add_a_photo,
                                        size: 30, color: Colors.white)
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
                            children: selectedCategories.map((cat) {
                              return Chip(label: Text(cat, style: const TextStyle(color: Colors.white)), backgroundColor: AppColors.peach);
                            }).toList(),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(child: _buildTextField("Full Name", fullName, Icons.person)),
                        const SizedBox(width: 12),
                        Expanded(child: _buildTextField("Last Name", lastName, Icons.person_2)),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(child: _buildTextField("Email", email, Icons.email)),
                        const SizedBox(width: 12),
                        Expanded(child: _buildTextField("Phone", phone, Icons.phone)),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(child: _buildTextField("Password", password, Icons.lock, isPassword: true)),
                        const SizedBox(width: 12),
                        Expanded(child: _buildTextField("Shop/Brand Name", brandName, Icons.store)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: address,
                      validator: (value) => value == null || value.isEmpty ? 'Enter Address' : null,
                      decoration: InputDecoration(
                        labelText: "Address",
                        suffixIcon: const Icon(Icons.location_on, color: AppColors.paleGreen),
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
                    const SizedBox(height: 16),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text("Categories to Sell In", style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.bold)),
                    ),
      Wrap(
  spacing: 10,
  children: categoryList.map((category) {
    final isSelected = selectedCategories.contains(category);
    return FilterChip(
      label: Text(
        category,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.black,
        ),
      ),
      selected: isSelected,
      onSelected: (bool selected) {
        setState(() {
          if (selected) {
            selectedCategories.add(category);
          } else {
            selectedCategories.remove(category);
          }
        });
      },
      selectedColor: AppColors.deepTeal,
      backgroundColor: const Color.fromARGB(217, 233, 239, 242),
    );
  }).toList(),
),

                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _submitForm,
                        icon: const Icon(Icons.person_add_alt_1, color: Colors.white),
                        label: const Text("Register Seller", style: TextStyle(fontSize: 16, color: Colors.white)),
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
