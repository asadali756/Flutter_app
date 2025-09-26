import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MasterLogin extends StatelessWidget {
  const MasterLogin({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double sectionHeight = 140;

    Widget buildLoginSection(
        {required String title,
        required String description,
        required IconData icon,
        required VoidCallback onTap}) {
      return GestureDetector(
        onTap: onTap,
        child: Container(
          height: sectionHeight,
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 8,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: Row(
            children: [
              Container(
                width: sectionHeight,
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    bottomLeft: Radius.circular(20),
                  ),
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 50,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade800,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        description,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 18),
              const SizedBox(width: 16),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 40),
            Center(
              child: Image.asset(
                'assets/images/Eco.png',
                height: 60,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "Choose Your Platform",
              style: GoogleFonts.poppins(
                  fontSize: 22, fontWeight: FontWeight.bold, color: Colors.green),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: [
                  buildLoginSection(
                    title: "User Platform",
                    description: "Login as a user to explore services",
                    icon: Icons.person,
                    onTap: () {
                      Navigator.pushNamed(context, '/Login');
                    },
                  ),
                  buildLoginSection(
                    title: "NGO Login",
                    description: "Login as NGO to manage your projects",
                    icon: Icons.volunteer_activism,
                    onTap: () {
                      Navigator.pushNamed(context, '/NgoLogin');
                    },
                  ),
                  buildLoginSection(
                    title: "Seller Login",
                    description: "Login as a seller to manage products",
                    icon: Icons.store,
                    onTap: () {
                      Navigator.pushNamed(context, '/SellerLogin');
                    },
                  ),
                  buildLoginSection(
                    title: "Account Admin Login",
                    description: "Login as admin to manage accounts",
                    icon: Icons.admin_panel_settings,
                    onTap: () {
                      Navigator.pushNamed(context, '/AdminAcountLogin');
                    },
                  ),
                  buildLoginSection(
                    title: "Worker Login",
                    description: "Login as worker to manage assigned tasks",
                    icon: Icons.work_outline,
                    onTap: () {
                      Navigator.pushNamed(context, '/WorkerLogin');
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
