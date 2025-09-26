import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:project/Components/AppColors.dart';

class NgoBottomBar extends StatefulWidget {
  const NgoBottomBar({ Key? key }) : super(key: key);

  @override
  _NgoBottomBarState createState() => _NgoBottomBarState();
}

class _NgoBottomBarState extends State<NgoBottomBar> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 70, // Fixed height ensures padding works above
      child: Container(
        margin: const EdgeInsets.all(8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.paleGreen,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: AppColors.paleGreen.withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Text(
              'Dashboard',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.iceBlue,
              ),
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(LucideIcons.settings, color: AppColors.iceBlue),
              onPressed: () {},
              tooltip: 'Settings',
            ),
            IconButton(
              icon: const Icon(LucideIcons.bell, color: AppColors.iceBlue),
              onPressed: () {},
              tooltip: 'Notifications',
            ),
            IconButton(
              icon: const Icon(LucideIcons.user, color: AppColors.iceBlue),
              onPressed: () {},
              tooltip: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
