import 'package:flutter/material.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:project/UserScreen/Joinus.dart';
import 'package:project/UserScreen/RealTimeApi.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:another_flushbar/flushbar.dart';

import 'package:project/UserScreen/AddCompetition.dart';
import 'package:project/UserScreen/EcoStore.dart';
import 'package:project/UserScreen/MainHome.dart';
import 'package:project/UserScreen/SellWaste.dart';
import 'package:project/UserScreen/SocialScroll.dart';

class AppBottomNav extends StatefulWidget {
  final int currentIndex;

  const AppBottomNav({Key? key, required this.currentIndex}) : super(key: key);

  @override
  _AppBottomNavState createState() => _AppBottomNavState();
}

class _AppBottomNavState extends State<AppBottomNav> {
  bool isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    checkLoginStatus();
  }

  Future<void> checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? loggedIn = prefs.getBool('isLoggedin');
    setState(() {
      isLoggedIn = loggedIn ?? false;
    });
  }

  void showLoginWarning() {
    Flushbar(
      message: "You need to login first to access this page!",
      duration: const Duration(seconds: 2),
      backgroundColor: Colors.red,
      flushbarPosition: FlushbarPosition.TOP,
    ).show(context);
  }

  @override
  Widget build(BuildContext context) {
    // ✅ Always 5 items for fixedCircle style
    List<TabItem> tabItems = [
      TabItem(
        icon: Tooltip(
          message: 'Home',
          child: const Icon(LucideIcons.home , color: Colors.white,),
        ),
      ),
      TabItem(
        icon: Tooltip(
          message: 'Workshops',
          child: const Icon(LucideIcons.plusCircle , color: Colors.white,),
        ),
      ),
      TabItem(
        icon: Tooltip(
          message: 'Sell Waste',
          child: const Icon(LucideIcons.plusSquare , color: Colors.white,),
        ),
      ),
      TabItem(
        icon: Tooltip(
          message: 'Social Scroll',
          child: const Icon(LucideIcons.bell , color: Colors.white,),
        ),
      ),
      TabItem(
        icon: Tooltip(
          message: 'EcoStore',
          child: const Icon(LucideIcons.user , color: Colors.white,),
        ),
      ),
      TabItem(
        icon: Tooltip(
          message: 'Eco Monitor',
          child: const Icon(LucideIcons.timer , color: Colors.white,),
        ),
      ),
      TabItem(
        icon: Tooltip(
          message: 'Join Us',
          child: const Icon(LucideIcons.group , color: Colors.white,),
        ),
      ),
    ];

    return ConvexAppBar(
      backgroundColor: Colors.green,
      style: TabStyle.fixedCircle, // ✅ Floating center (+) tab
      items: tabItems,
      initialActiveIndex: widget.currentIndex,
      onTap: (int index) async {
        if (index == widget.currentIndex) return;

        switch (index) {
          case 0:
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => MasterHome()),
            );
            break;
          case 1:
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => AddCompetition()),
            );
            break;
          case 2:
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => SellWaste()),
            );
            break;
          case 3:
            if (isLoggedIn) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => SocialScroll()),
              );
            } else {
              showLoginWarning(); // 🚫 Block navigation
            }
            break;
          case 4:
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => EcoStore()),
            );
            break;
          case 5:
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => EcoMonitorPage()),
            );
            break;
          case 6:
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => Joinus()),
            );
            break;
        }
      },
    );
  }
}
