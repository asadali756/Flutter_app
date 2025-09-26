import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:project/Components/AppColors.dart';
import 'package:project/WorkerScreen/Profile.dart';
import 'package:project/WorkerScreen/Task.dart';
import 'package:project/WorkerScreen/dashboard_widget.dart';
import 'package:project/WorkerScreen/WorkerMessage.dart'; // Import your WorkerMessage screen here

class WorkerIndex extends StatefulWidget {
  const WorkerIndex({Key? key}) : super(key: key);

  @override
  _WorkerIndexState createState() => _WorkerIndexState();
}

class _WorkerIndexState extends State<WorkerIndex> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedIndex = 1;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  void _onBottomTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
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
          Tab(icon: Icon(LucideIcons.clock, size: 18), text: "Tasks"),
          Tab(icon: Icon(LucideIcons.messageCircle, size: 18), text: "Messages"),
          Tab(icon: Icon(LucideIcons.userCheck2, size: 18), text: "Profile"),
        ],
      ),
    ),
  ),
),
body: TabBarView(
        controller: _tabController,
        children: [
          const DashboardWidget(),
          const Tasks(),
          WorkerMessage(),
           WorkerProfile()
        ],
      ),
     
    );
  }
}
