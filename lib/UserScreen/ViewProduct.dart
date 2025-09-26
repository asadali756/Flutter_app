import 'dart:html' as html;
import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project/Components/MyAppBar.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ViewProduct extends StatefulWidget {
  final String productId;

  const ViewProduct({Key? key, required this.productId}) : super(key: key);

  @override
  _ViewProductState createState() => _ViewProductState();
}

class _ViewProductState extends State<ViewProduct> {
  /// Save item to Firestore AddToCart collection
  Future<void> _addToCart() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString("userEmail"); // stored at login

    if (email == null) {
      Flushbar(
        message: "User not logged in",
        icon: const Icon(Icons.error, color: Colors.red),
        duration: const Duration(seconds: 3),
        backgroundColor: Colors.black87,
        margin: const EdgeInsets.all(12),
        borderRadius: BorderRadius.circular(8),
      ).show(context);
      return;
    }

    // Check if product already exists in cart
    var existingCart = await FirebaseFirestore.instance
        .collection("AddToCart")
        .where("email", isEqualTo: email)
        .where("product_id", isEqualTo: widget.productId)
        .limit(1)
        .get();

    if (existingCart.docs.isNotEmpty) {
      // If product exists → increase quantity
      var docId = existingCart.docs.first.id;
      int currentQty = existingCart.docs.first["quantity"] ?? 1;

      await FirebaseFirestore.instance
          .collection("AddToCart")
          .doc(docId)
          .update({"quantity": currentQty + 1});

      Flushbar(
        message: "Quantity updated in Cart",
        icon: const Icon(Icons.update, color: Colors.blue),
        duration: const Duration(seconds: 3),
        backgroundColor: Colors.black87,
        margin: const EdgeInsets.all(12),
        borderRadius: BorderRadius.circular(8),
      ).show(context);
    } else {
      // Else create new record
      await FirebaseFirestore.instance.collection("AddToCart").add({
        "email": email,
        "product_id": widget.productId,
        "quantity": 1,
        "created_at": FieldValue.serverTimestamp(),
      });

      Flushbar(
        message: "Added to Cart",
        icon: const Icon(Icons.check, color: Colors.green),
        duration: const Duration(seconds: 3),
        backgroundColor: Colors.black87,
        margin: const EdgeInsets.all(12),
        borderRadius: BorderRadius.circular(8),
      ).show(context);
    }
  }

  /// Buy Now Modal & Order Flow
  Future<void> _buyNow() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString("userEmail");

    if (email == null) {
      Flushbar(
        message: "User not logged in",
        icon: const Icon(Icons.error, color: Colors.red),
        duration: const Duration(seconds: 3),
        backgroundColor: Colors.black87,
        margin: const EdgeInsets.all(12),
        borderRadius: BorderRadius.circular(8),
      ).show(context);
      return;
    }

    var productSnap = await FirebaseFirestore.instance
        .collection("SellerProduct")
        .doc(widget.productId)
        .get();

    if (!productSnap.exists) return;

    double price = double.tryParse(productSnap['price'].toString()) ?? 0.0;

    // Show payment modal
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 50,
                height: 5,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              Text("Choose Payment Method",
                  style: GoogleFonts.quicksand(
                      fontSize: 18, fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              Text("Total Bill: Rs. $price",
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),

              // Cash on Delivery
              ListTile(
                leading: const Icon(Icons.delivery_dining, color: Colors.green),
                title: const Text("Cash on Delivery"),
                onTap: () async {
                  Navigator.pop(context);
                  await FirebaseFirestore.instance.collection("Orders").add({
                    "email": email,
                    "product_id": widget.productId,
                    "quantity": 1,
                    "total_price": price,
                    "payment_method": "Cash on Delivery",
                    "timestamp": FieldValue.serverTimestamp(),
                    "status": "pending",
                  });
                  Flushbar(
                    message:
                        "Order placed successfully with Cash on Delivery!",
                    duration: const Duration(seconds: 3),
                    backgroundColor: Colors.green.shade700,
                    icon: const Icon(Icons.check_circle, color: Colors.white),
                    flushbarPosition: FlushbarPosition.TOP,
                    borderRadius: BorderRadius.circular(12),
                    margin: const EdgeInsets.all(8),
                  ).show(context);
                },
              ),
              const Divider(),

              // Online Payment
              ListTile(
                leading: const Icon(Icons.payment, color: Colors.deepPurple),
                title: const Text("Pay with Card"),
                onTap: () async {
                  Navigator.pop(context);
                  await FirebaseFirestore.instance.collection("Orders").add({
                    "email": email,
                    "product_id": widget.productId,
                    "quantity": 1,
                    "total_price": price,
                    "payment_method": "Online Payment",
                    "timestamp": FieldValue.serverTimestamp(),
                    "status": "pending",
                  });

                  // Open Stripe checkout
                  const stripeLink =
                      "https://buy.stripe.com/test_aFa8wQf4c5oLgJf0hQcQU00";
                  html.window.open(stripeLink, "_blank");

                  Flushbar(
                    message:
                        "Order placed successfully! Redirecting to payment...",
                    duration: const Duration(seconds: 3),
                    backgroundColor: Colors.green.shade700,
                    icon: const Icon(Icons.check_circle, color: Colors.white),
                    flushbarPosition: FlushbarPosition.TOP,
                    borderRadius: BorderRadius.circular(12),
                    margin: const EdgeInsets.all(8),
                  ).show(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection("SellerProduct")
            .doc(widget.productId)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text("Product not found"));
          }

          var data = snapshot.data!;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Product Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    data['image_url'],
                    height: 250,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),

                const SizedBox(height: 16),

                /// Title
                Text(
                  data['title'],
                  style: GoogleFonts.quicksand(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                /// Price
                Text(
                  "Rs. ${data['price']} PKR",
                  style: GoogleFonts.quicksand(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.green.shade800,
                  ),
                ),

                const SizedBox(height: 12),

                /// Description
                Text(
                  data['description'] ?? "No description available",
                  style: GoogleFonts.quicksand(
                    fontSize: 15,
                    color: Colors.grey[700],
                  ),
                ),

                const SizedBox(height: 24),

                /// Buttons: Add to Cart & Buy Now
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade700,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: _addToCart,
                        icon: const Icon(Icons.shopping_cart,
                            color: Colors.white),
                        label: Text(
                          "Add to Cart",
                          style: GoogleFonts.quicksand(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange.shade700,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: _buyNow,
                        icon: const Icon(Icons.flash_on, color: Colors.white),
                        label: Text(
                          "Buy Now",
                          style: GoogleFonts.quicksand(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
