import 'package:flutter/material.dart';
import 'package:project/Components/bottomNav.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Social extends StatefulWidget {
  const Social({Key? key}) : super(key: key);

  @override
  _SocialState createState() => _SocialState();
}

class _SocialState extends State<Social> {
  String? _email;
  Map<String, dynamic>? _userData;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _checkAutoLogin();
  }
 Future<void> _createAccount() async {
  // Controllers for fields except email
  TextEditingController usernameCtrl = TextEditingController();
  TextEditingController accountNameCtrl = TextEditingController();
  TextEditingController bioCtrl = TextEditingController();

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (ctx) => Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          children: [
            const Text(
              "Create Social Account",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            // Username input
            _buildInputField(usernameCtrl, "Username", Icons.person),
            _buildInputField(accountNameCtrl, "Account Name", Icons.badge),
            _buildInputField(bioCtrl, "Bio", Icons.info),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
                backgroundColor: Colors.green.shade800,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.check, color: Colors.white),
              label: const Text(
                "Create Account",
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () async {
                // Get email from SharedPreferences or _email
                SharedPreferences prefs = await SharedPreferences.getInstance();
                String? email = _email ?? prefs.getString("userEmail");

                if (email == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("User not logged in")),
                  );
                  return;
                }

                if (usernameCtrl.text.isEmpty || accountNameCtrl.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Please fill all required fields")),
                  );
                  return;
                }

                Navigator.pop(ctx); // Close bottom sheet

                await FirebaseFirestore.instance.collection("SocialAccount").add({
                  "email": email, // auto-set email
                  "username": usernameCtrl.text,
                  "accountName": accountNameCtrl.text,
                  "bio": bioCtrl.text,
                  "profilePic": "https://i.pravatar.cc/150?u=${usernameCtrl.text}",
                  "followers": 0,
                  "following": 0,
                  "status": "public",
                });

                setState(() {
                  _userData = {
                    "username": usernameCtrl.text,
                    "accountName": accountNameCtrl.text,
                    "bio": bioCtrl.text,
                    "profilePic": "https://i.pravatar.cc/150?u=${usernameCtrl.text}",
                    "followers": 0,
                    "following": 0,
                    "status": "public",
                    "email": email, // store email in userData
                  };
                });

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Account created successfully")),
                );
              },
            ),
          ],
        ),
      ),
    ),
  );
}

Future<void> _deleteAccount() async {
  if (_userData == null) return;

  // Confirm deletion dialog
  bool confirm = await showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text("Delete Account"),
      content: const Text(
          "Are you sure you want to delete your account? This action cannot be undone."),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          onPressed: () => Navigator.pop(ctx, true),
          child: const Text("Delete"),
        ),
      ],
    ),
  );

  if (confirm) {
    // Get user document from Firestore
    var snapshot = await FirebaseFirestore.instance
        .collection("SocialAccount")
        .where("email", isEqualTo: _email)
        .get();

    if (snapshot.docs.isNotEmpty) {
      // Delete the document
      await FirebaseFirestore.instance
          .collection("SocialAccount")
          .doc(snapshot.docs.first.id)
          .delete();

      // Remove saved email from SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove("userEmail");

      setState(() {
        _userData = null;
      });

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Account deleted successfully")),
      );
    }
  }
}

Future<void> _editAccount() async {
  if (_userData == null) return;

  TextEditingController usernameCtrl =
      TextEditingController(text: _userData!["username"]);
  TextEditingController accountNameCtrl =
      TextEditingController(text: _userData!["accountName"]);
  TextEditingController bioCtrl =
      TextEditingController(text: _userData!["bio"]);

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (ctx) => Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          children: [
            const Text(
              "Edit Profile",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildInputField(usernameCtrl, "Username", Icons.person),
            _buildInputField(accountNameCtrl, "Account Name", Icons.badge),
            _buildInputField(bioCtrl, "Bio", Icons.info),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
                backgroundColor: Colors.green.shade800,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.save, color: Colors.white),
              label: const Text(
                "Save Changes",
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () async {
                Navigator.pop(ctx); // Close the bottom sheet

                var snapshot = await FirebaseFirestore.instance
                    .collection("SocialAccount")
                    .where("email", isEqualTo: _email)
                    .get();

                if (snapshot.docs.isNotEmpty) {
                  await FirebaseFirestore.instance
                      .collection("SocialAccount")
                      .doc(snapshot.docs.first.id)
                      .update({
                    "username": usernameCtrl.text,
                    "accountName": accountNameCtrl.text,
                    "bio": bioCtrl.text,
                  });

                  setState(() {
                    _userData!["username"] = usernameCtrl.text;
                    _userData!["accountName"] = accountNameCtrl.text;
                    _userData!["bio"] = bioCtrl.text;
                  });

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Profile updated successfully")),
                  );
                }
              },
            ),
          ],
        ),
      ),
    ),
  );
}

  Future<void> _checkAutoLogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedEmail = prefs.getString("userEmail");
    setState(() => _email = savedEmail);

    if (savedEmail != null) {
      var snapshot = await FirebaseFirestore.instance
          .collection("SocialAccount")
          .where("email", isEqualTo: savedEmail)
          .get();

      if (snapshot.docs.isNotEmpty) {
        setState(() => _userData = snapshot.docs.first.data());
      }
    }
    setState(() => _loading = false);
  }

  Widget _buildProfileRow() {
    if (_loading) return const Center(child: CircularProgressIndicator());

    if (_userData == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.person, size: 80, color: Colors.grey),
            const SizedBox(height: 12),
            const Text("No Account Found"),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _createAccount,
              child: const Text("Create Account"),
            ),
          ],
        ),
      );
    } else {
      String status = _userData!["status"] ?? "public";
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage(_userData!["profilePic"]),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _userData!["username"],
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Container(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: status == "public" ? Colors.green : Colors.grey,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          status.toUpperCase(),
                          style: const TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _userData!["accountName"],
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _userData!["bio"],
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.black87),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "${_userData!["followers"]} Followers • ${_userData!["following"]} Following",
                    style: const TextStyle(color: Colors.black),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }
  }

Widget _buildPostsSection() {
  if (_email == null) return Container();

  return StreamBuilder<QuerySnapshot>(
    stream: FirebaseFirestore.instance
        .collection("SocialPost")
        .where("email", isEqualTo: _email)
        .snapshots(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Padding(
          padding: EdgeInsets.all(16),
          child: Center(child: CircularProgressIndicator()),
        );
      }

      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
        return const Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            "No posts yet. Create your first post!",
            style: TextStyle(fontSize: 16, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        );
      }

      var docs = snapshot.data!.docs;
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: docs.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemBuilder: (context, index) {
          var post = docs[index].data() as Map<String, dynamic>;
          List mediaUrls = post["mediaUrls"] ?? [];
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.grey.shade200,
            ),
            child: mediaUrls.isNotEmpty
                ? Image.network(mediaUrls[0], fit: BoxFit.cover)
                : const Center(child: Icon(Icons.image)),
          );
        },
      );
    },
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Text(
          _userData?["username"] ?? "Profile",
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_box_outlined, color: Colors.black),
            onPressed: () {
              Navigator.pushNamed(context, '/createpost');
            },
          ),
          IconButton(
            icon: const Icon(Icons.drafts_outlined, color: Colors.black),
            tooltip: "Drafts",
            onPressed: () {
              Navigator.pushNamed(context, '/drafts'); // implement drafts page
            },
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.settings, color: Colors.black),
            onSelected: (value) {
              switch (value) {
                case "edit":
                  _editAccount();
                  break;
                case "delete":
                  _deleteAccount();
                  break;
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem(value: "edit", child: Text("Edit Account")),
              const PopupMenuItem(value: "delete", child: Text("Delete Account")),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildProfileRow(),
              const Divider(thickness: 1),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  "Your Posts",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              _buildPostsSection(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
Widget _buildInputField(
    TextEditingController controller, String label, IconData icon,
    {int maxLines = 1}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.green.shade800),
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Colors.grey.shade100,
      ),
    ),
  );
}
