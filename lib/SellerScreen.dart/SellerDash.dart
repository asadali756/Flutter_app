import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SellerDash extends StatefulWidget {
  const SellerDash({Key? key}) : super(key: key);

  @override
  _SellerDashState createState() => _SellerDashState();
}

class _SellerDashState extends State<SellerDash> {
  String sellerName = "";
  String brandName = "";
  String profilePic = "";
  List<String> categories = [];

  @override
  void initState() {
    super.initState();
    _loadSellerData();
  }

  Future<void> _loadSellerData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      sellerName = prefs.getString("sellerName") ?? "Unknown Seller";
      brandName = prefs.getString("brandName") ?? "No Brand";
      profilePic = prefs.getString("image_url") ?? "";
      categories = prefs.getStringList("categories") ?? [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     
      body: Card(
        elevation: 3,
        margin: const EdgeInsets.all(10),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Profile Image
              CircleAvatar(
                radius: 40,
                backgroundImage:
                    profilePic.isNotEmpty ? NetworkImage(profilePic) : null,
                child: profilePic.isEmpty
                    ? const Icon(Icons.person, size: 40)
                    : null,
              ),
              const SizedBox(height: 12),
      
              // Seller Name
              Text(
                sellerName,
                style: const TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold),
              ),
      
              const SizedBox(height: 6),
      
              // Brand Name
              Text(
                "Brand: $brandName",
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
      
              const Divider(height: 30, thickness: 1),
      
              // Categories
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Categories:",
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.green.shade700),
                ),
              ),
              const SizedBox(height: 8),
              categories.isEmpty
                  ? const Text("No categories found")
                  : Wrap(
                      spacing: 8,
                      children: categories
                          .map((cat) => Chip(
                                label: Text(cat),
                                backgroundColor: Colors.green.shade100,
                              ))
                          .toList(),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
