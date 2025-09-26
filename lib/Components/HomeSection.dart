import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:timeago/timeago.dart' as timeago;

class TreePlantingList extends StatelessWidget {
  const TreePlantingList({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection("SellerProduct")
          .orderBy("created_at", descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: Padding(
            padding: EdgeInsets.all(20),
            child: CircularProgressIndicator(),
          ));
        }

        final docs = snapshot.data!.docs;

        if (docs.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Text("No Seller Products Found",
                  style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w500, color: Colors.grey)),
            ),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: docs.length,
          padding: const EdgeInsets.all(2),
          itemBuilder: (context, index) {
            final doc = docs[index].data() as Map<String, dynamic>;
            final title = doc["title"] ?? "";
            final description = doc["description"] ?? "";
            final imageUrl = doc["image_url"] ??
                "https://via.placeholder.com/100"; // fallback
            final createdAt = (doc["created_at"] as Timestamp?)?.toDate();

            String timeAgo = "";
            if (createdAt != null) {
              timeAgo = timeago.format(createdAt, locale: "en_short");
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      imageUrl,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    ),
                  ),
                  title: Text(
                    title,
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(description,
                          style: GoogleFonts.inter(
                              color: Colors.black87, fontSize: 12)),
                      if (timeAgo.isNotEmpty)
                        Text(timeAgo,
                            style: GoogleFonts.inter(
                                color: Colors.green.shade700, fontSize: 11)),
                    ],
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.green.shade300,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(LucideIcons.heart,
                        size: 18, color: Colors.white),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
