import 'package:flutter/material.dart';
import 'package:project/AdminScreen/AdminChat.dart';
import 'package:project/Charts/BarChart.dart';
import 'package:project/Charts/PieChart.dart';
import 'package:project/Charts/RecycleStatsRow.dart';
import 'package:project/Charts/TradeStatsBox.dart';
import 'package:project/Components/AdminbottomBar.dart';
import 'package:project/Components/AppColors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminIndex extends StatelessWidget {
  const AdminIndex({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.iceBlue,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 80),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 90,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _menuItem(context, LucideIcons.users, 'Registers', '/registerall'),
                    _menuItem(context, LucideIcons.truck, 'Pickups', '/pickups'),
                    _menuItem(context, LucideIcons.recycle, 'Volunteers', '/volunteers'),
                    _menuItem(context, LucideIcons.calendar, 'Schedule', '/schedule'),
                    _menuItem(context, LucideIcons.dollarSign, 'Donations', '/donations'),
                    _menuItem(context, LucideIcons.alarmCheck, 'Alarms', '/alarms'),
                    _menuItem(context, LucideIcons.warehouse, 'Sales', '/sales'),
                    _menuItem(context, Icons.category, 'Category', '/AddCatgeory'),
                    _menuItem(context, LucideIcons.award, 'Competition ', '/comp'),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(child: VerticalBarChart()),
                  const SizedBox(width: 8),
                  Expanded(child: PieChartWidget()),
                ],
              ),

              const SizedBox(height: 12),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 4,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 3.0),
                      child: const TradeStatsBox(),
                    ),
                  ),
                  Expanded(
                    flex: 6,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: AppColors.softWhite,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(left: 6),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Messages Header with notification badge
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Recent Messages',
                                    style: GoogleFonts.spaceGrotesk(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.deepTeal,
                                    ),
                                  ),
                                  StreamBuilder<QuerySnapshot>(
                                    stream: FirebaseFirestore.instance
                                        .collection('chats')
                                        .doc('worker_1_admin_1') // chatId
                                        .collection('messages')
                                        .where('status', isEqualTo: 'sent')
                                        .where('sender', isEqualTo: 'worker')
                                        .snapshots(),
                                    builder: (context, snapshot) {
                                      int unreadCount = snapshot.data?.docs.length ?? 0;

                                      return Stack(
                                        children: [
                                          IconButton(
                                            icon: const Icon(
                                              Icons.message_outlined,
                                              size: 18,
                                              color: AppColors.deepTeal,
                                            ),
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(builder: (context) => const AdminChat()),
                                              );
                                            },
                                          ),
                                          if (unreadCount > 0)
                                            Positioned(
                                              right: 4,
                                              top: 4,
                                              child: Container(
                                                padding: const EdgeInsets.all(2),
                                                decoration: const BoxDecoration(
                                                  color: Colors.red,
                                                  shape: BoxShape.circle,
                                                ),
                                                constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                                                child: Center(
                                                  child: Text(
                                                    '$unreadCount',
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 10,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                        ],
                                      );
                                    },
                                  ),
                                ],
                              ),

                              const SizedBox(height: 2),

                              _messageTile(
                                name: 'EcoWaste Org',
                                message: 'Pickup request approved.',
                              ),
                              _messageTile(
                                name: 'GreenCircle',
                                message: 'Need volunteers for.',
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              RecycleStatsRow(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: AdminBottomBar(),
    );
  }

  // Menu Item Helper
  Widget _menuItem(BuildContext context, IconData icon, String label, String route) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => Navigator.pushNamed(context, route),
        child: _iconBox(icon: icon, label: label),
      ),
    );
  }

  // Icon Box Widget
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

  // Message Tile Widget
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
