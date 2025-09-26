import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project/Components/MyAppBar.dart';
import 'package:project/Components/bottomNav.dart';
import 'package:project/Components/userCamera.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class SellWaste extends StatefulWidget {
  const SellWaste({Key? key}) : super(key: key);

  @override
  _SellWasteState createState() => _SellWasteState();
}

class _SellWasteState extends State<SellWaste> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController contactCtrl = TextEditingController();
  final TextEditingController addressCtrl = TextEditingController();
  final Map<String, TextEditingController> qtyControllers = {};

  List<Map<String, dynamic>> wasteCategories = [];
  List<Map<String, dynamic>> selectedCategories = [];

  bool homePickup = false;
  XFile? pickedImage;
  Uint8List? webImage;

  @override
  void initState() {
    super.initState();
    fetchWasteCategories();
  }

  Future<void> fetchWasteCategories() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('waste_submissions').get();
    setState(() {
      wasteCategories =
          snapshot.docs.map((doc) => {"id": doc.id, ...doc.data()}).toList();
      for (var w in wasteCategories) {
        qtyControllers[w['category']] = TextEditingController();
      }
    });
  }

  int get totalPrice {
    int total = 0;
    for (var cat in selectedCategories) {
      int qty = int.tryParse(qtyControllers[cat['category']]!.text) ?? 0;
      int base = (cat['rate'] ?? 0) * qty;
      total += base;
    }
    int pickupFee = homePickup ? 500 : 0;
    return total - pickupFee ; // +10 PKR platform fee
  }

  Future<void> pickImage() async {
    final source = await showDialog<ImageSource>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Select Image Source"),
        content: const Text("Choose where to get the image from:"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, ImageSource.camera),
              child: const Text("Camera")),
          TextButton(
              onPressed: () => Navigator.pop(context, ImageSource.gallery),
              child: const Text("Gallery")),
        ],
      ),
    );

    if (source == ImageSource.camera) {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const CameraUser()),
      );
      if (result != null) {
        setState(() {
          pickedImage = result['file'];
          webImage = result['bytes'];
        });
      }
    } else if (source == ImageSource.gallery) {
      final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (picked != null) {
        final bytes = await picked.readAsBytes();
        setState(() {
          pickedImage = picked;
          webImage = bytes;
        });
      }
    }
  }

  Future<String> uploadImageToCloudinary(Uint8List imageBytes) async {
    final url = Uri.parse(
        "https://api.cloudinary.com/v1_1/dlntmuhv5/image/upload");
    final request = http.MultipartRequest('POST', url);
    request.fields['upload_preset'] = "SocialPosts";
    request.files.add(http.MultipartFile.fromBytes('file', imageBytes,
        filename: "waste_${DateTime.now().millisecondsSinceEpoch}.jpg"));
    final response = await request.send();
    if (response.statusCode == 200) {
      final resStr = await response.stream.bytesToString();
      final resJson = json.decode(resStr);
      return resJson['secure_url'];
    } else {
      throw Exception("Image upload failed: ${response.statusCode}");
    }
  }

  Future<void> submitForm() async {
    if (_formKey.currentState!.validate() &&
        selectedCategories.isNotEmpty &&
        pickedImage != null) {
      final prefs = await SharedPreferences.getInstance();
      String? email = prefs.getString('userEmail');
      if (email == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("User email not found!")),
        );
        return;
      }

      final confirm = await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
                title: const Text("Confirm Submission"),
                content: Text(
                  homePickup
                      ? "Your waste will be picked up. If waste is not as per description, delivery partner will charge 200 PKR. Otherwise, you will receive total amount - 500 PKR pickup fee."
                      : "Drop your waste at Ecocycle.pk, abc Street , x block , karachi , Pakistan. For further contact, reach out to support.",
                ),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text("Cancel")),
                  TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text("Confirm")),
                ],
              ));

      if (confirm != true) return;

      String imageUrl = await uploadImageToCloudinary(webImage!);

      List<Map<String, dynamic>> wasteData = selectedCategories.map((cat) {
        int qty = int.tryParse(qtyControllers[cat['category']]!.text) ?? 0;
        return {
          'category': cat['category'],
          'quantity': qty,
          'rate': cat['rate'],
        };
      }).toList();

      await FirebaseFirestore.instance.collection('WasteReq').add({
        'wastes': wasteData,
        'user_name': nameCtrl.text,
        'email': email,
        'contact': contactCtrl.text,
        'address': addressCtrl.text,
        'pickup': homePickup,
        'total_amount': totalPrice,
        'created_at': Timestamp.now(),
        'image_url': imageUrl,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Request submitted! Total: PKR $totalPrice")),
      );

      _formKey.currentState!.reset();
      setState(() {
        selectedCategories.clear();
        pickedImage = null;
        webImage = null;
        homePickup = false;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                "Please fill all fields, select at least one waste category, and upload an image.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      bottomNavigationBar: const AppBottomNav(currentIndex: 2),
      appBar: MyAppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hero
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        "Waste to Wealth 💡\nTurn your trash into cash!",
                        style: GoogleFonts.inter(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Image.asset("assets/images/trash.png", height: 100),
                  ],
                ),
                const SizedBox(height: 20),

                // Waste Multiple Selection
                Text("Select Waste Types",
                    style: GoogleFonts.inter(
                        fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: wasteCategories.map((cat) {
                    final isSelected =
                        selectedCategories.contains(cat);
                    return FilterChip(
                      label: Text("${cat['category']} (Rs ${cat['rate']}/kg)"),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            selectedCategories.add(cat);
                          } else {
                            selectedCategories.remove(cat);
                          }
                        });
                      },
                      selectedColor: Colors.green.shade400,
                      backgroundColor: Colors.white,
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),

                // Quantity for each selected category
                Column(
                  children: selectedCategories.map((cat) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: _glassTextField(
                          "Quantity for ${cat['category']} (kg)",
                          qtyControllers[cat['category']]!,
                          Icons.scale,
                          keyboard: TextInputType.number),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),

                // Name, Contact, Address
                _glassTextField("Full Name", nameCtrl, Icons.person),
                const SizedBox(height: 16),
                _glassTextField("Contact Number", contactCtrl, Icons.phone,
                    keyboard: TextInputType.phone),
                const SizedBox(height: 16),
                _glassTextField("Pickup Address", addressCtrl, Icons.home),
                const SizedBox(height: 16),

                // Pickup
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 6,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: SwitchListTile(
                    value: homePickup,
                    onChanged: (val) => setState(() => homePickup = val),
                    title: const Text("Home Pickup (-500 PKR)"),
                    activeColor: Colors.green,
                  ),
                ),
                const SizedBox(height: 16),

              // Image Picker with big camera/gallery buttons
Center(
  child: Column(
    children: [
      if (webImage != null)
        Container(
          height: 180,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey.shade300),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 6,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.memory(
              webImage!,
              fit: BoxFit.cover,
            ),
          ),
        ),
      const SizedBox(height: 16),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Camera Button
          InkWell(
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CameraUser()),
              );
              if (result != null) {
                setState(() {
                  pickedImage = result['file'];
                  webImage = result['bytes'];
                });
              }
            },
            child: CircleAvatar(
              radius: 40,
              backgroundColor: Colors.green.shade400,
              child: const Icon(Icons.camera_alt, color: Colors.white, size: 40),
            ),
          ),

          // Gallery Button
          InkWell(
            onTap: () async {
              final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
              if (picked != null) {
                final bytes = await picked.readAsBytes();
                setState(() {
                  pickedImage = picked;
                  webImage = bytes;
                });
              }
            },
            child: CircleAvatar(
              radius: 40,
              backgroundColor: Colors.blue.shade400,
              child: const Icon(Icons.photo_library, color: Colors.white, size: 40),
            ),
          ),
        ],
      ),
    ],
  ),
),
  const SizedBox(height: 16),

                // Payable/receivable info
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    homePickup
                        ? "Soon our delivery partner will receive your waste and hand over your payable amount."
                        : "Drop your waste at Ecocycle.pk, abc Street , x block , karachi , Pakistan. For further contact, reach out to support.",
                    style: GoogleFonts.inter(color: Colors.green.shade900),
                  ),
                ),
                const SizedBox(height: 16),

                // Total
                Text("Total: PKR $totalPrice",
                    style: GoogleFonts.inter(
                        fontSize: 18, fontWeight: FontWeight.w600)),
                const SizedBox(height: 20),

                // Submit
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (_) => const Center(
                          child:
                              CircularProgressIndicator(color: Colors.green),
                        ),
                      );
                      await submitForm();
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                    ),
                    child: Text(
                      "Submit",
                      style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _glassTextField(String label, TextEditingController controller,
      IconData icon,
      {TextInputType keyboard = TextInputType.text}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboard,
        validator: (value) =>
            value == null || value.isEmpty ? 'Required' : null,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.green),
          border: InputBorder.none,
        ),
      ),
    );
  }
}
