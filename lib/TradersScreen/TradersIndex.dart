import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project/Components/AppColors.dart';

class TradersIndex extends StatefulWidget {
  const TradersIndex({Key? key}) : super(key: key);

  @override
  _TradersIndexState createState() => _TradersIndexState();
}

class _TradersIndexState extends State<TradersIndex> {
  final List<Map<String, dynamic>> boxes = [
    {"label": "Dashboard", "icon": LucideIcons.layoutDashboard, "route": "/dashboard"},
    {"label": "Orders", "icon": LucideIcons.shoppingCart, "route": "/orders"},
    {"label": "Products", "icon": LucideIcons.box, "route": "/products"},
    {"label": "Customers", "icon": LucideIcons.users, "route": "/customers"},
    {"label": "Reports", "icon": LucideIcons.barChartBig, "route": "/reports"},
    {"label": "Payments", "icon": LucideIcons.wallet, "route": "/payments"},
    {"label": "Settings", "icon": LucideIcons.settings, "route": "/settings"},
    {"label": "Support", "icon": LucideIcons.helpCircle, "route": "/support"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.iceBlue,
      floatingActionButton: Align(
        alignment: Alignment.bottomRight,
        child: Padding(
          padding: const EdgeInsets.only(top: 40.0, left: 20),
          child: FloatingActionButton(
            onPressed: () {
              // Chat button action
            },
            backgroundColor: AppColors.peach,
            child: const Icon(LucideIcons.messageCircle, color: Colors.white),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 4),
        child: Align(
          alignment: Alignment.centerLeft,
          child: FractionallySizedBox(
            widthFactor: 0.08, // Reduced width (8%)
            child: SingleChildScrollView(
              child: Column(
                children: boxes.map((item) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: Tooltip(
                      message: item['label'],
                      textStyle: GoogleFonts.spaceGrotesk(
                        fontSize: 13,
                        color: AppColors.softWhite,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.paleGreen,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: InkWell(
                        onTap: () {
                          Navigator.pushNamed(context, item['route']);
                        },
                        borderRadius: BorderRadius.circular(2),
                        mouseCursor: SystemMouseCursors.click,
                        child:  Container(
                          width: 50, // You can adjust this width as needed
                          height: 50, // Makes it square and centers icon vertically
                          decoration: BoxDecoration(
                            color: AppColors.paleGreen,
                            borderRadius: BorderRadius.circular(2), // 2 radius on all sides
                            boxShadow: [
                              BoxShadow(
                                color: Colors.white12,
                                blurRadius: 2,
                                offset: Offset(0, 1),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Icon(
                              item['icon'],
                              color: AppColors.softWhite,
                              size: 26,
                            ),
                          ),
                        ),
        
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
