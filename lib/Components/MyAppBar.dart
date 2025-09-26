import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lucide_icons/lucide_icons.dart';

class MyAppBar extends StatefulWidget implements PreferredSizeWidget {
  const MyAppBar({Key? key}) : super(key: key);

  @override
  _MyAppBarState createState() => _MyAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(60);
}

class _MyAppBarState extends State<MyAppBar> {
  bool isLoggedIn = false;
  String? userEmail;

  @override
  void initState() {
    super.initState();
    checkLoginStatus();
  }

  Future<void> checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? loggedIn = prefs.getBool('isLoggedin');
    String? email = prefs.getString("userEmail");
    setState(() {
      isLoggedIn = loggedIn ?? false;
      userEmail = email;
    });
  }

  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    setState(() {
      isLoggedIn = false;
      userEmail = null;
    });

    Navigator.pushReplacementNamed(context, '/Login');
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.grey.shade200,
      elevation: 2,
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          Image.asset(
            "assets/images/Eco.png",
            height: 35,
          ),
        ],
      ),
      centerTitle: false,
      actions: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            /// ✅ Notifications
            if (isLoggedIn)
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('Notifications')
                    .where('isRead', isEqualTo: false)
                    .snapshots(),
                builder: (context, snapshot) {
                  int unreadCount = snapshot.data?.docs.length ?? 0;
                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      IconButton(
                        tooltip: "Notifications",
                        icon: Icon(LucideIcons.bell, color: Colors.green),
                        onPressed: () {
                          Navigator.pushNamed(context, '/PushNotification');
                        },
                      ),
                      if (unreadCount > 0)
                        Positioned(
                          right: 6,
                          top: 12,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              unreadCount.toString(),
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),

            /// ✅ Cart Icon + Count Badge
            StreamBuilder<QuerySnapshot>(
              stream: userEmail == null
                  ? null
                  : FirebaseFirestore.instance
                      .collection("AddToCart")
                      .where("email", isEqualTo: userEmail)
                      .snapshots(),
              builder: (context, snapshot) {
                int cartCount = snapshot.data?.docs.length ?? 0;
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    IconButton(
                      tooltip: "Cart",
                      icon: Icon(LucideIcons.shoppingCart, color: Colors.green),
                      onPressed: () {
                        Navigator.pushNamed(context, '/cart');
                      },
                    ),
                    if (cartCount > 0)
                      Positioned(
                        right: 6,
                        top: 12,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            cartCount.toString(),
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),

            /// ✅ Profile or Account Menu
            isLoggedIn
                ? IconButton(
                    tooltip: "Profile",
                    icon: Icon(LucideIcons.userCircle, color: Colors.green),
                    onPressed: () {
                      Navigator.pushNamed(context, '/EditProfile');
                    },
                  )
                : PopupMenuButton<String>(
                    tooltip: "Account",
                    color: const Color.fromARGB(255, 8, 89, 130),
                    icon: Icon(LucideIcons.userCircle2, color: Colors.green),
                    onSelected: (value) {
                      if (value == 'Signup') {
                        Navigator.pushNamed(context, '/Signup');
                      } else if (value == 'Login') {
                        Navigator.pushNamed(context, '/Login');
                      }
                    },
                    itemBuilder: (BuildContext context) => [
                      const PopupMenuItem<String>(
                        value: 'Signup',
                        child: Text("Signup",
                            style: TextStyle(color: Colors.green)),
                      ),
                      const PopupMenuItem<String>(
                        value: 'Login',
                        child: Text("Login",
                            style: TextStyle(color: Colors.green)),
                      ),
                    ],
                  ),

            /// ✅ Logout
            if (isLoggedIn)
              IconButton(
                tooltip: "Logout",
                icon: Icon(LucideIcons.logOut, color: Colors.green),
                onPressed: () {
                  logout();
                },
              ),
          ],
        ),
        const SizedBox(width: 8),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1.0),
        child: Container(
          color: Colors.grey.shade300,
          height: 1.0,
        ),
      ),
    );
  }
}
