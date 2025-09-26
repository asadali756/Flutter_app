import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:project/Components/MyAppBar.dart';
import 'package:project/Components/bottomNav.dart';
import 'package:project/Components/HomeSection.dart';
import 'package:project/UserScreen/chat.dart'; // your tree planting list

class MasterHome extends StatelessWidget {
  const MasterHome({super.key});

  // 🔹 Fetch Stats from Firestore
  Future<Map<String, dynamic>> _fetchStats() async {
    final wasteSnapshot =
        await FirebaseFirestore.instance.collection("WasteReq").get();
    final sellerSnapshot =
        await FirebaseFirestore.instance.collection("SellerProduct").get();
    final ngoSnapshot =
        await FirebaseFirestore.instance.collection("ngos").get();

    double totalWaste = 0;
    double totalAmount = 0;

    for (var doc in wasteSnapshot.docs) {
      totalWaste += (doc["quantity"] ?? 0).toDouble();
      totalAmount += (doc["total_amount"] ?? 0).toDouble();
    }

    return {
      "waste": totalWaste,
      "amount": totalAmount,
      "products": sellerSnapshot.size,
      "ngos": ngoSnapshot.size,
    };
  }

  @override
  Widget build(BuildContext context) {

return Scaffold(
  backgroundColor: Colors.grey.shade100,
  appBar: MyAppBar(),
  body: Stack(
    children: [
      
      // Main content
      Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _heroSection(),
                  _sectionTitle("Help Us | Save The World"),
                  _statsSection(),
                  _categorySlider(context),
                  _communitySection(),
                  TreePlantingList(),
                ],
              ),
            ),
          ),
        ],
      ),

      // 🔹 Floating Circle Button for ChatPage
Positioned(
  bottom: 70, // slightly above bottom navigation
  right: 16,
  child: Container(
    width: 70, // bada size
    height: 70,
    decoration: BoxDecoration(
      color: Colors.green, // background color
      shape: BoxShape.circle,
    ),
    child: FloatingActionButton(
      onPressed: () {
        Navigator.pushNamed(context, ChatPage.routeName);
      },
      backgroundColor: Colors.transparent, // transparent so container bg shows
      elevation: 5,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(50),
        child: Image.asset(
          "assets/images/geminiicon.png",
          width: 40, // adjust image size
          height: 40,
          fit: BoxFit.cover,
        ),
      ),
    ),
  ),
),

    ],
  ),

  // Bottom Navigation
  bottomNavigationBar: AppBottomNav(currentIndex: 0),
);


  }

  // 🔹 Hero Section
  Widget _heroSection() {
    return CarouselSlider(
      options: CarouselOptions(
        height: 200,
        autoPlay: true,
        enlargeCenterPage: true,
        viewportFraction: 0.6,
        enableInfiniteScroll: true,
      ),
      items: [
        _heroCard("Join Contest", "Win amazing rewards", "assets/images/2.jpg"),
        _heroCard("EcoStore Sale", "Up to 50% OFF", "assets/images/3.jpg"),
        _heroCard("Trending Post", "Eco ideas & tips", "assets/images/4.jpg"),
      ],
    );
  }

  Widget _heroCard(String title, String subtitle, String image) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        image: DecorationImage(
          image: AssetImage(image),
          fit: BoxFit.cover,
          colorFilter:
              const ColorFilter.mode(Colors.black26, BlendMode.darken),
        ),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 4))
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Align(
        alignment: Alignment.bottomLeft,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
            const SizedBox(height: 4),
            Text(subtitle,
                style: GoogleFonts.inter(fontSize: 14, color: Colors.white70)),
          ],
        ),
      ),
    );
  }

  // 🔹 Section Title
  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Text(title,
          style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Colors.black87)),
    );
  }

  // 🔹 Stats Section (Dynamic)
  Widget _statsSection() {
    return FutureBuilder<Map<String, dynamic>>(
      future: _fetchStats(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
              child: Padding(
            padding: EdgeInsets.all(20),
            child: CircularProgressIndicator(),
          ));
        }

        final stats = snapshot.data!;
        return SizedBox(
          height: 120,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              // Static Image
              Container(
                width: 100,
                child: Image.asset("assets/images/recycle.png",
                    fit: BoxFit.cover),
              ),
              const SizedBox(width: 12),

              _statCard("${stats['waste'].toStringAsFixed(0)} KG",
                  "Waste Recycled", LucideIcons.recycle),
              const SizedBox(width: 12),

              _statCard("${stats['amount'].toStringAsFixed(0)} PKR",
                  "Money Earned", LucideIcons.dollarSign),
              const SizedBox(width: 12),

              _statCard("${stats['products']}", "Seller Products",
                  LucideIcons.box),
              const SizedBox(width: 12),

              _statCard("${stats['ngos']}", "NGOs", LucideIcons.users),
            ],
          ),
        );
      },
    );
  }

  Widget _statCard(String value, String label, IconData icon) {
    return Container(
      width: 140,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 6,
            spreadRadius: 1,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.green, size: 28),
          const SizedBox(height: 10),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w700,
              fontSize: 18,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w500,
              fontSize: 13,
              color: Colors.grey.shade700,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // 🔹 Community Section
  Widget _communitySection() {
    return SizedBox(
      height: 50,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(left: 16),
        children: [
          ...List.generate(4, (index) {
            return Transform.translate(
              offset: Offset(-index * 12.0, 0),
              child: CircleAvatar(
                radius: 16,
                backgroundImage:
                    AssetImage("assets/images/user${index + 1}.jpg"),
              ),
            );
          }),
          Transform.translate(
            offset: const Offset(-48, 0),
            child: const CircleAvatar(
              radius: 16,
              backgroundColor: Colors.deepPurple,
              child: Icon(Icons.add, size: 18, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  // 🔹 Category Slider with Routes
  Widget _categorySlider(BuildContext context) {
    return SizedBox(
      height: 160,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.all(16),
        children: [
          _categoryCard(context, "Eco Tips", "assets/images/poster1.jpeg",
              "/EcoStore"),
          _categoryCard(context, "Trending", "assets/images/poster2.jpeg",
              "/Social"),
          _categoryCard(
              context, "Workshops", "assets/images/poster3.jpeg", "/AddCompetition"),
        ],
      ),
    );
  }

  Widget _categoryCard(
      BuildContext context, String title, String image, String route) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, route);
      },
      child: Container(
        width: 140,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(2),
          image: DecorationImage(image: AssetImage(image), fit: BoxFit.cover),
          boxShadow: const [
            BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3))
          ],
        ),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Colors.black26,
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16)),
            ),
            child: Text(title,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ),
      ),
    );
  }
}
