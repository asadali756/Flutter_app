import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NGODash extends StatefulWidget {
  const NGODash({Key? key}) : super(key: key);

  @override
  _NGODashState createState() => _NGODashState();
}

class _NGODashState extends State<NGODash> {
  String ngoname = "";
  String email = "";
  String phone = "";
  String address = "";
  String status = "";
  String type = "";
  String createdAt = "";
  String imageUrl = "";

  @override
  void initState() {
    super.initState();
    _loadNGOData();
  }

  Future<void> _loadNGOData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      ngoname = prefs.getString("ngoname") ?? "NGO Name";
      email = prefs.getString("email") ?? "";
      phone = prefs.getString("phone") ?? "";
      address = prefs.getString("address") ?? "";
      status = prefs.getString("status") ?? "";
      type = prefs.getString("type") ?? "";
      createdAt = prefs.getString("created_at") ?? "";
      imageUrl = prefs.getString("image_url") ??
          "https://via.placeholder.com/150"; // fallback
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 🔹 Banner with NGO image
            Container(
              height: 180,
              width: double.infinity,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(imageUrl),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                alignment: Alignment.bottomLeft,
                padding: const EdgeInsets.all(16),
                color: Colors.black.withOpacity(0.4),
                child: Text(
                  ngoname,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // 🔹 NGO Details
            _infoTile("Email", email, Icons.email),
            _infoTile("Phone", phone, Icons.phone),
            _infoTile("Address", address, Icons.location_on),
            _infoTile("Status", status, Icons.verified),
            _infoTile("Type", type, Icons.group),
          ],
        ),
      ),
    );
  }

  // 🔹 Reusable Info Tile
  Widget _infoTile(String label, String value, IconData icon) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: Colors.green),
        title: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(value.isNotEmpty ? value : "Not available"),
      ),
    );
  }
}
