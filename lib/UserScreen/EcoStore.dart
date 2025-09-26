import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project/Components/MyAppBar.dart';
import 'package:project/Components/bottomNav.dart';
import 'package:project/UserScreen/EditProfile.dart';
import 'package:project/UserScreen/Tracking.dart';
import 'package:project/UserScreen/UserProfile.dart';
import 'package:project/UserScreen/ViewProduct.dart';

class EcoStore extends StatefulWidget {
  const EcoStore({Key? key}) : super(key: key);

  @override
  _EcoStoreState createState() => _EcoStoreState();
}

Widget _buildNavItem(IconData icon, String label, VoidCallback onTap) {
  return InkWell(
    onTap: onTap,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.green.shade800, size: 26),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.quicksand(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: const Color(0xff3D3D3D),
          ),
        ),
      ],
    ),
  );
}



class _EcoStoreState extends State<EcoStore> {
@override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: Colors.grey.shade100,
    appBar: MyAppBar(),
    body: SafeArea(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// ✅ Secondary AppBar Section
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  )
                ],
              ),
              child: Row(
  mainAxisAlignment: MainAxisAlignment.spaceAround,
  children: [
    _buildNavItem(Icons.local_shipping_outlined, "Tracking", () {
      Navigator.push(context,
        MaterialPageRoute(builder: (_) => const Tracking())); 
    }),
    // _buildNavItem(Icons.history, "Previous Record", () {
    //   Navigator.push(context,
    //     MaterialPageRoute(builder: (_) => const SellerRecords()));
    // }),
    _buildNavItem(Icons.person_outline, "Profile", () {
      Navigator.push(context,
        MaterialPageRoute(builder: (_) => const UserProfile()));
    }),
  ],
),

            ),

            const SizedBox(height: 5),

            /// 🔹 Hero Section

              /// 🔹 Hero Section
              _buildHeroSection(),

               const SizedBox(height: 5),

              /// 🔹 Products Grid from Firestore
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  "Popular Finds",
                  style: GoogleFonts.quicksand(
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                    color: const Color(0xff3D3D3D),
                  ),
                ),
              ),
               const SizedBox(height: 5),
   Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection("SellerProduct")
                      .orderBy("created_at", descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final products = snapshot.data!.docs;
                   return MasonryGridView.count(
  physics: const NeverScrollableScrollPhysics(),
  shrinkWrap: true,
  crossAxisCount: 2,
  mainAxisSpacing: 16,
  crossAxisSpacing: 16,
  itemCount: products.length,
  itemBuilder: (context, index) {
    final data = products[index]; // 👈 full Firestore document
    return _buildMasonryProduct(data, index.isEven ? 220 : 160);
  },
);
  },
                ),
              ),

              const SizedBox(height: 24),
              /// 🔹 Categories from Firestore
              SizedBox(
                height: 120,
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection("sellercategory")
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final categories = snapshot.data!.docs;
                    return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: categories.length,
                      itemBuilder: (context, index) {
                        final data = categories[index];
                        return _buildCircularCategory(
                          data['image_url'],
                          data['categoryname'],
                        );
                      },
                    );
                  },
                ),
              ),

            
              
              
              const SizedBox(height: 12),

           

              /// 🔹 Story Section
              _buildStory(),

              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
      bottomNavigationBar: AppBottomNav(currentIndex: 4),
    );
  }

  /// ✅ Hero
Widget _buildHeroSection() {
  return Container(
    width: double.infinity,
    height: 260,
    decoration: BoxDecoration(
      image: const DecorationImage(
        image: NetworkImage(
          "https://skipper.org/cdn/shop/articles/eco_friendly_120cd6de-0473-47d2-bbf4-45f526c82391.png?v=1659684410&width=1100",
        ),
        fit: BoxFit.cover,
      ),
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(40),
        bottomRight: Radius.circular(40),
      ),
    ),
    child: Container(
      // 🔹 Add a semi-transparent overlay so text is visible
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.4),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Shop Handmade, Save Earth",
              style: GoogleFonts.quicksand(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "Discover recycled treasures crafted with love.",
              style: GoogleFonts.quicksand(
                fontSize: 15,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xff3D3D3D),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: () {},
              child: const Text("Start Shopping"),
            )
          ],
        ),
      ),
    ),
  );
}

  /// ✅ Category (with image from Firestore)
  Widget _buildCircularCategory(String imageUrl, String label) {
    return Container(
      margin: const EdgeInsets.only(right: 18),
      width: 80,
      child: Column(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundImage: NetworkImage(imageUrl),
            backgroundColor: const Color(0xffE9E5D6),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.quicksand(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: const Color(0xff3D3D3D),
            ),
          )
        ],
      ),
    );
  }

/// ✅ Product Card (staggered, full image visible)
Widget _buildMasonryProduct(DocumentSnapshot data, double imageHeight) {
  return Container(
    decoration: BoxDecoration(
      color: Colors.green.shade50,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Product Image
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: SizedBox(
                  height: imageHeight,
                  width: double.infinity,
                  child: Image.network(
                    data['image_url'],
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: Colors.white70,
                      child: Icon(Icons.favorite_border,
                          size: 18, color: Colors.red),
                    ),
                    const SizedBox(width: 6),
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: Colors.white70,
                      child: Icon(Icons.shopping_cart_outlined,
                          size: 18, color: Colors.green),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          /// Name
          Text(
            data['title'],
            style: GoogleFonts.quicksand(
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),

          /// Price
          Text(
            "Rs. ${data['price']} PKR",
            style: GoogleFonts.quicksand(
              fontWeight: FontWeight.w600,
              color: const Color(0xff6A994E),
            ),
          ),

          const SizedBox(height: 6),

          /// ⭐ Static review stars
          Row(
            children: List.generate(
              5,
              (index) => const Icon(Icons.star,
                  size: 16, color: Colors.amber),
            ),
          ),

          const SizedBox(height: 10),

          /// Discover Button → now you can use data.id
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ViewProduct(productId: data.id),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade800,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.search, size: 18, color: Colors.white),
              label: Text(
                "Discover",
                style: GoogleFonts.quicksand(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

  /// ✅ Story Section
  Widget _buildStory() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.brown.withOpacity(0.08),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(LucideIcons.leaf, size: 40, color: const Color(0xff6A994E)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Our Story",
                    style: GoogleFonts.quicksand(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "We turn waste into wonders – promoting sustainable living through handmade recycled creations.",
                    style: GoogleFonts.quicksand(
                        fontSize: 13, color: Colors.grey[700]),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
