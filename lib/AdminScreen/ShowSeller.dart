import 'dart:convert';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project/Components/AppColors.dart';

class ShowSeller extends StatefulWidget {
  const ShowSeller({Key? key}) : super(key: key);

  @override
  State<ShowSeller> createState() => _ShowSellerState();
}

class _ShowSellerState extends State<ShowSeller> {
  Future<void> deleteSeller(String docId) async {
    bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.iceBlue,
        title: Text("Delete Seller", style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.bold)),
        content: Text("Are you sure you want to delete this seller?", style: GoogleFonts.spaceGrotesk()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text("Cancel", style: GoogleFonts.spaceGrotesk()),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.peach),
            onPressed: () => Navigator.pop(context, true),
            child: Text("Delete", style: GoogleFonts.spaceGrotesk(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm) {
      await FirebaseFirestore.instance.collection('sellers').doc(docId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Seller deleted!', style: GoogleFonts.spaceGrotesk()),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void showEditDialog(DocumentSnapshot seller) {
    final fullName = TextEditingController(text: seller['fullName']);
    final lastName = TextEditingController(text: seller['lastName']);
    final email = TextEditingController(text: seller['email']);
    final phone = TextEditingController(text: seller['phone']);
    final password = TextEditingController(text: seller['password']);
    final brandName = TextEditingController(text: seller['brandName']);
    final address = TextEditingController(text: seller['address']);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.iceBlue,
        title: Text("Edit Seller", style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildInput("Full Name", fullName),
              _buildInput("Last Name", lastName),
              _buildInput("Email", email),
              _buildInput("Phone", phone),
              _buildInput("Password", password),
              _buildInput("Brand Name", brandName),
              _buildInput("Address", address),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel", style: GoogleFonts.spaceGrotesk()),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.peach),
            onPressed: () async {
              await FirebaseFirestore.instance.collection('sellers').doc(seller.id).update({
                'fullName': fullName.text.trim(),
                'lastName': lastName.text.trim(),
                'email': email.text.trim(),
                'phone': phone.text.trim(),
                'password': password.text.trim(),
                'brandName': brandName.text.trim(),
                'address': address.text.trim(),
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Seller updated!', style: GoogleFonts.spaceGrotesk()),
                  backgroundColor: AppColors.peach,
                ),
              );
            },
            child: Text("Save", style: GoogleFonts.spaceGrotesk(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildInput(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.spaceGrotesk(),
          filled: true,
          fillColor: const Color.fromARGB(217, 233, 239, 242),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.mint),
          ),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: AppColors.peach, width: 1.5),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.iceBlue,
      appBar: AppBar(
        title: Text("All Sellers", style: GoogleFonts.spaceGrotesk(color: Colors.white)),
        backgroundColor: AppColors.peach,
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('sellers').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text("Error loading sellers", style: GoogleFonts.spaceGrotesk()));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final sellers = snapshot.data!.docs;

          if (sellers.isEmpty) {
            return Center(child: Text("No sellers found.", style: GoogleFonts.spaceGrotesk()));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: sellers.length,
            itemBuilder: (context, index) {
              final seller = sellers[index];
              Uint8List? imageBytes;
              try {
                if (seller['image'] != null && seller['image'].toString().isNotEmpty) {
                  imageBytes = base64Decode(seller['image']);
                }
              } catch (_) {
                imageBytes = null;
              }

              return Card(
                elevation: 4,
                color: Colors.white,
                margin: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 35,
                            backgroundColor: AppColors.peach,
                            backgroundImage: imageBytes != null ? MemoryImage(imageBytes) : null,
                            child: imageBytes == null
                                ? const Icon(Icons.person, color: Colors.white, size: 30)
                                : null,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("${seller['fullName']} ${seller['lastName']}",
                                    style: GoogleFonts.spaceGrotesk(
                                        fontSize: 18, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 6),
                                _iconText(Icons.email, seller['email']),
                                _iconText(Icons.phone, seller['phone']),
                                _iconText(Icons.business, seller['brandName']),
                                _iconText(Icons.category, seller['category']),
                                _iconText(Icons.location_on, seller['address']),
                                _iconText(Icons.work, seller['businessType']),
                              ],
                            ),
                          ),
                          Column(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.green),
                                onPressed: () => showEditDialog(seller),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => deleteSeller(seller.id),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _iconText(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.black87),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: GoogleFonts.spaceGrotesk())),
        ],
      ),
    );
  }
}
