import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import 'package:project/Components/AppColors.dart';
import 'package:project/Components/MyAppBar.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({Key? key}) : super(key: key);

  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final _formKey = GlobalKey<FormState>();
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  TextEditingController emailController = TextEditingController();
  TextEditingController userNameController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController phoneController = TextEditingController();

  bool _loading = true;
  LatLng _pickedLatLng = LatLng(24.8607, 67.0011); // Karachi default
  List<dynamic> _searchResults = [];
  double _zoom = 13;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        final userDoc = await _firestore.collection('users').doc(user.uid).get();
        emailController.text = userDoc['Email'] ?? '';
        userNameController.text = userDoc['UserName'] ?? '';

        final profileDoc = await _firestore.collection('user_profiles').doc(user.uid).get();
        if (profileDoc.exists) {
          final data = profileDoc.data();
          addressController.text = data?['address'] ?? '';
          phoneController.text = data?['phonenumber'] ?? '';
        }
      }
    } catch (e) {
      print("Error fetching data: $e");
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> searchLocation(String query) async {
    final url = Uri.parse(
        'https://nominatim.openstreetmap.org/search?q=$query&countrycodes=pk&format=json');
    final response = await http.get(url, headers: {
      'User-Agent': 'FlutterApp/1.0 (contact@example.com)',
    });

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      setState(() {
        _searchResults = data;
      });
    }
  }

  void onAreaSelect(Map<String, dynamic> item) {
    double lat = double.parse(item['lat']);
    double lon = double.parse(item['lon']);
    String displayName = item['display_name'];

    setState(() {
      _pickedLatLng = LatLng(lat, lon);
      _zoom = 15;
      addressController.text = displayName;
      _searchResults = [];
    });
  }

  Future<void> getAddressFromLatLng(double lat, double lon) async {
    final url = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse?lat=$lat&lon=$lon&format=json');
    final response = await http.get(url, headers: {
      'User-Agent': 'FlutterApp/1.0',
    });

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        addressController.text = data['display_name'];
      });
    }
  }

  Future<void> saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    final user = _auth.currentUser;

    if (user != null) {
      try {
        await _firestore.collection('users').doc(user.uid).update({
          'UserName': userNameController.text.trim(),
        });

        await _firestore.collection('user_profiles').doc(user.uid).set({
          'UserId': user.uid,
          'address': addressController.text.trim(),
          'phonenumber': phoneController.text.trim(),
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Profile updated successfully"),
          backgroundColor: Colors.green,
        ));
      } catch (e) {
        print("Error saving profile: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.iceBlue,
      appBar: MyAppBar(),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.deepTeal))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: Card(
                  color: AppColors.softWhite,
                  elevation: 8,
                  shadowColor: Colors.black38,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Column(
                              children: [
                                const SizedBox(height: 10),
                                Text(
                                  "Edit Your Shipping Profile!",
                                  style: GoogleFonts.spaceGrotesk(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.deepTeal,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "Please fill this address carefully. This will be your shipping location.",
                                  style: GoogleFonts.inter(
                                      fontSize: 13, color: AppColors.deepTeal),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 25),
                                SizedBox(
                                  width: 60,
                                  height: 60,
                                  child: Image.asset("assets/images/profile.png"),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 25),
                          buildTextField(
                            controller: userNameController,
                            icon: Icons.person,
                            label: 'User Name',
                            validator: (val) => val == null || val.trim().isEmpty
                                ? 'User Name is required'
                                : null,
                          ),
                          const SizedBox(height: 15),
                          buildTextField(
                            controller: emailController,
                            icon: Icons.email,
                            label: 'Email',
                            readOnly: true,
                          ),
                          const SizedBox(height: 15),
                          buildTextField(
                            controller: phoneController,
                            icon: Icons.phone,
                            label: 'Phone Number',
                            keyboardType: TextInputType.phone,
                            maxLength: 11,
                            validator: (val) =>
                                val == null || val.length != 11 ? 'Enter 11-digit number' : null,
                          ),
                          const SizedBox(height: 15),
                          buildTextField(
                            controller: addressController,
                            icon: Icons.search,
                            label: 'Search Area',
                            onChanged: (val) {
                              if (val.length > 3) searchLocation(val);
                            },
                          ),
                          const SizedBox(height: 10),
                          ..._searchResults.map((item) => ListTile(
                                leading: const Icon(Icons.location_on, color: AppColors.deepTeal),
                                title: Text(item['display_name'],
                                    style: GoogleFonts.inter(fontSize: 13)),
                                onTap: () => onAreaSelect(item),
                              )),
                          const SizedBox(height: 15),
                          SizedBox(
                            height: 300,
                            child: FlutterMap(
                              options: MapOptions(
                                initialCenter: _pickedLatLng,
                                initialZoom: _zoom,
                                onTap: (tapPosition, latLng) {
                                  setState(() {
                                    _pickedLatLng = latLng;
                                  });
                                  getAddressFromLatLng(latLng.latitude, latLng.longitude);
                                },
                              ),
                              children: [
                                TileLayer(
                                  urlTemplate:
                                      'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                                  subdomains: ['a', 'b', 'c'],
                                ),
                                MarkerLayer(
                                  markers: [
                                    Marker(
                                      point: _pickedLatLng,
                                      width: 40,
                                      height: 40,
                                      child: const Icon(Icons.location_pin,
                                          size: 40, color: Colors.red),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                  onPressed: () => setState(() => _zoom += 1),
                                  icon: const Icon(Icons.add_circle, color: AppColors.deepTeal)),
                              IconButton(
                                  onPressed: () => setState(() => _zoom -= 1),
                                  icon: const Icon(Icons.remove_circle, color: AppColors.deepTeal)),
                            ],
                          ),
                          const SizedBox(height: 25),
                          Center(
                            child: ElevatedButton.icon(
                              onPressed: saveProfile,
                              icon: const Icon(Icons.save, color: Colors.white),
                              label: Text("Save Changes",
                                  style: GoogleFonts.inter(
                                      fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.deepTeal,
                                padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 14),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  Widget buildTextField({
    required TextEditingController controller,
    required IconData icon,
    required String label,
    String? Function(String?)? validator,
    bool readOnly = false,
    TextInputType keyboardType = TextInputType.text,
    int? maxLength,
    void Function(String)? onChanged,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      keyboardType: keyboardType,
      maxLength: maxLength,
      validator: validator,
      onChanged: onChanged,
      style: GoogleFonts.inter(color: AppColors.deepTeal, fontSize: 15),
      decoration: InputDecoration(
        label: Text(label, style: GoogleFonts.spaceGrotesk(fontSize: 14, color: AppColors.deepTeal)),
        prefixIcon: Icon(icon, color: AppColors.paleGreen),
        filled: true,
        fillColor: Colors.grey.shade100,
        counterText: '',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.paleGreen),
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.deepTeal, width: 1.5),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
