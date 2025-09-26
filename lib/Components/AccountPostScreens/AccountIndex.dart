import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:project/Components/AccountPostScreens/Post.dart';
import 'package:project/Components/AdminProfile..dart';
import 'package:project/Components/AppColors.dart';
import 'package:project/UserScreen/CreatePost.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AccountIndex extends StatefulWidget {
  const AccountIndex({Key? key}) : super(key: key);

  @override
  _AccountIndexState createState() => _AccountIndexState();
}

class _AccountIndexState extends State<AccountIndex>
    with TickerProviderStateMixin {
  late TabController _tabController;

  // User data
  String accountName = '';
  String profilePic = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      accountName = prefs.getString('accountName') ?? '';
      profilePic = prefs.getString('profilePic') ?? '';
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        toolbarHeight: 80,
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Stack(
          alignment: Alignment.center,
          children: [
            // Left: Profile Picture + Name
            Align(
              alignment: Alignment.centerLeft,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundImage: profilePic.isNotEmpty
                        ? NetworkImage(profilePic)
                        : const AssetImage('assets/default_profile.png')
                            as ImageProvider,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    accountName.isNotEmpty ? accountName : "Admin",
                    style: GoogleFonts.spaceGrotesk(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87),
                  ),
                ],
              ),
            ),

            // Center: Eco Logo
            Center(
              child: Image.asset(
                "assets/images/Eco.png",
                height: 28,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.red),
            onPressed: () {
              Navigator.pushReplacementNamed(context, "/MasterLogin");
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(40),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: TabBar(
              controller: _tabController,
              indicatorColor: AppColors.paleGreen,
              labelColor: AppColors.paleGreen,
              unselectedLabelColor: const Color.fromARGB(255, 82, 81, 81),
              labelStyle: GoogleFonts.spaceGrotesk(fontSize: 11),
              tabs: const [
                Tab(icon: Icon(LucideIcons.mailOpen, size: 18), text: "Add Post"),
                Tab(icon: Icon(LucideIcons.pocket, size: 18), text: "Manage Posts"),
                Tab(icon: Icon(LucideIcons.userCheck2, size: 18), text: "Profile"),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          const CreatePostScreen(),
          const Post(),
          AdminProfile()
        ],
      ),
    );
  }
}
