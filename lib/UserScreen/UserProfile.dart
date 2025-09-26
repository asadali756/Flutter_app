import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:project/Components/MyAppBar.dart';

class UserProfile extends StatefulWidget {
  const UserProfile({Key? key}) : super(key: key);

  @override
  _UserProfileState createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  String userName = "";
  String email = "";
  String address = "";
  String userId = "";

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return;

      String uid = currentUser.uid;
      setState(() {
        userId = uid;
      });

      DocumentSnapshot profileSnap = await FirebaseFirestore.instance
          .collection("user_profiles")
          .doc(uid)
          .get();

      if (profileSnap.exists) {
        setState(() {
          email = profileSnap["email"] ?? "";
          address = profileSnap["address"] ?? "";
        });
      }

      DocumentSnapshot userSnap =
          await FirebaseFirestore.instance.collection("users").doc(uid).get();

      if (userSnap.exists) {
        setState(() {
          userName = userSnap["UserName"] ?? "";
        });
      }

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      print("Error loading profile: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: MyAppBar(),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  // 🔹 Hero Section with curved bottom
// 🔹 Hero Section with curved bottom and centered text
ClipPath(
  clipper: BottomCurveClipper(),
  child: Container(
    height: 250,
    width: double.infinity,
    decoration: BoxDecoration(
      image: DecorationImage(
        image: NetworkImage(
          "https://images.unsplash.com/photo-1604187351574-c75ca79f5807?q=80&w=1170&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
        ),
        fit: BoxFit.cover,
      ),
    ),
    child: Container(
      color: Colors.black.withOpacity(0.3), // overlay
      padding: const EdgeInsets.symmetric(horizontal: 16),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Text(
            "Welcome to EcoiCycle",
            textAlign: TextAlign.center,
            style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            "Track and manage your recycling journey easily!",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
        ],
      ),
    ),
  ),
),


                  const SizedBox(height: 16),

                  // 🔹 Username below hero image
                  if (userName.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Card(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          leading: const Icon(Icons.person, color: Colors.green),
                          title: const Text(
                            "Username",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(userName),
                        ),
                      ),
                    ),

                  const SizedBox(height: 8),

                  // 🔹 Email & Address Info Tiles
                  _infoTile("Email", email, Icons.email),
                  _infoTile("Address", address, Icons.location_on),
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

// 🔹 Custom clipper for bottom curve
class BottomCurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height - 40);
    path.quadraticBezierTo(
        size.width / 2, size.height, size.width, size.height - 40);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
