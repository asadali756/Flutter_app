import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SellerRegisterForm extends StatefulWidget {
  const SellerRegisterForm({Key? key}) : super(key: key);

  @override
  _SellerRegisterFormState createState() => _SellerRegisterFormState();
}

class _SellerRegisterFormState extends State<SellerRegisterForm> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for text fields
  final TextEditingController sellerNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController brandNameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController imageUrlController = TextEditingController();

  List<String> selectedCategories = [];
  List<String> allCategories = [];

  @override
  void initState() {
    super.initState();
    fetchCategories();
  }

  // Fetch categories from sellercategory collection
  Future<void> fetchCategories() async {
    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('sellercategory').get();
    List<String> categories = snapshot.docs
        .map((doc) => doc['categoryname'].toString())
        .toList();
    setState(() {
      allCategories = categories;
    });
  }

  Future<void> saveSeller() async {
    if (_formKey.currentState!.validate() && selectedCategories.isNotEmpty) {
      await FirebaseFirestore.instance.collection('sellers').add({
        "sellerName": sellerNameController.text,
        "lastName": lastNameController.text,
        "email": emailController.text,
        "phone": phoneController.text,
        "password": passwordController.text,
        "brandName": brandNameController.text,
        "address": addressController.text,
        "image_url": imageUrlController.text,
        "categories": selectedCategories,
        "status": "Requested",
        "created_at": Timestamp.now(),
      });

      // Show confirmation dialog
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Success"),
          content: const Text("Seller registered successfully!"),
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
    } else if (selectedCategories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select at least one category")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Seller Registration" , style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.green.shade700,
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
  children: [
    buildTextField("Seller Name", sellerNameController, icon: Icons.person),
    buildTextField("Last Name", lastNameController, icon: Icons.person_outline),
    buildTextField("Email", emailController, keyboardType: TextInputType.emailAddress, icon: Icons.email),
    buildTextField("Phone", phoneController, keyboardType: TextInputType.phone, icon: Icons.phone),
    buildTextField("Password", passwordController, obscureText: true, icon: Icons.lock),
    buildTextField("Brand Name", brandNameController, icon: Icons.store),
    buildTextField("Address", addressController, icon: Icons.location_on),
    buildTextField("Image URL", imageUrlController, icon: Icons.image),
    const SizedBox(height: 16),

    Align(
      alignment: Alignment.centerLeft,
      child: Text(
        "Select Categories",
        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
      ),
    ),
    const SizedBox(height: 8),
    Wrap(
      spacing: 8.0,
      children: allCategories.map((category) {
        final isSelected = selectedCategories.contains(category);
        return FilterChip(
          label: Text(category),
          selected: isSelected,
          selectedColor: Colors.green.shade200,
          onSelected: (bool selected) {
            setState(() {
              if (selected) {
                selectedCategories.add(category);
              } else {
                selectedCategories.remove(category);
              }
            });
          },
        );
      }).toList(),
    ),
    const SizedBox(height: 24),
    ElevatedButton(
      onPressed: saveSeller,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: const Text("Register Seller", style: TextStyle(fontSize: 16)),
    ),
  ],
)
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
