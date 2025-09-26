import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:project/Components/AppColors.dart';
import 'package:project/Components/NgoScreen/AcceptedReq.dart';
import 'package:project/Components/NgoScreen/AllReq.dart';
import 'package:project/Components/NgoScreen/NGODash.dart';

class NgoIndex extends StatefulWidget {
  const NgoIndex({Key? key}) : super(key: key);

  @override
  _NgoIndexState createState() => _NgoIndexState();
}

class _NgoIndexState extends State<NgoIndex> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onBottomTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.iceBlue,
      appBar: AppBar(
        toolbarHeight: 80,
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Center(
            child: Image.asset(
              "assets/images/Eco.png",
              height: 28,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.red), // 🔴 Logout icon
            onPressed: () {
              Navigator.pushReplacementNamed(context, "/Login");
              // ✅ Make sure your Login route is defined in MaterialApp routes
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
                Tab(icon: Icon(LucideIcons.database, size: 18), text: "Dashboard"),
                Tab(icon: Icon(LucideIcons.plusSquare, size: 18), text: "Accepted Request"),
                Tab(icon: Icon(LucideIcons.messageCircle, size: 18), text: "All Request"),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          NGODash(),
          AcceptedReq(),
          AllReq()
        ],
      ),
    );
  }

  // ✅ Helper widget for menu items
  Widget _menuItem(BuildContext context, IconData icon, String label, String route) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => Navigator.pushNamed(context, route),
        child: _iconBox(icon: icon, label: label),
      ),
    );
  }

  // ✅ Icon box widget
  Widget _iconBox({required IconData icon, required String label}) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: AppColors.paleGreen,
        borderRadius: BorderRadius.circular(12),
      ),
      width: 80,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: AppColors.iceBlue, size: 24),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(fontSize: 10, color: AppColors.iceBlue),
          ),
        ],
      ),
    );
  }

  // ✅ Message tile widget
  Widget _messageTile({required String name, required String message}) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 4),
      leading: const CircleAvatar(
        backgroundColor: AppColors.mint,
        child: Icon(Icons.person, size: 16, color: AppColors.iceBlue),
        radius: 18,
      ),
      title: Text(
        name,
        style: GoogleFonts.spaceGrotesk(fontSize: 12, color: AppColors.paleGreen),
      ),
      subtitle: Text(
        message,
        style: GoogleFonts.inter(fontSize: 8, color: Colors.black87),
      ),
      dense: true,
      minLeadingWidth: 0,
    );
  }
}
