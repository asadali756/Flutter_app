import 'dart:html' as html;
import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project/Components/MyAppBar.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Cart extends StatefulWidget {
  const Cart({Key? key}) : super(key: key);

  @override
  _CartState createState() => _CartState();
}

class _CartState extends State<Cart> {
  String? userEmail;
  Map<String, int> quantities = {}; // productId -> quantity

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userEmail = prefs.getString("userEmail");
    });
  }

  /// ✅ Stripe Checkout Function
  void _openStripeCheckout() {
    const stripeLink = "https://buy.stripe.com/test_aFa8wQf4c5oLgJf0hQcQU00";
    html.window.open(stripeLink, "_blank"); // Open in new tab
  }

  // ✅ Payment Modal
  Future<void> _showPaymentModal(List<QueryDocumentSnapshot> cartItems, double totalBill) async {
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
              // Drag handle
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
              Text("Total Bill: Rs. $totalBill",
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),

              // Cash on Delivery
              ListTile(
                leading: const Icon(Icons.delivery_dining, color: Colors.green),
                title: const Text("Cash on Delivery"),
                onTap: () {
                  Navigator.pop(context);
                  _buyNow(cartItems, "Cash on Delivery");
                },
              ),
              const Divider(),

              // Pay with Card
              ListTile(
                leading: const Icon(Icons.payment, color: Colors.deepPurple),
                title: const Text("Pay with Card"),
                onTap: () {
                  Navigator.pop(context);
                  _buyNow(cartItems, "Online Payment");
                  _openStripeCheckout(); // open stripe
                },
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  // ✅ Order Place Logic
  Future<void> _buyNow(List<QueryDocumentSnapshot> cartItems, String paymentMethod) async {
    if (userEmail == null) return;

    // Check profile
    var profileSnapshot = await FirebaseFirestore.instance
        .collection("user_profiles")
        .where("email", isEqualTo: userEmail)
        .get();

    if (profileSnapshot.docs.isEmpty) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text("Profile Required"),
          content: const Text("Please create your profile before buying."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pushReplacementNamed(context, '/profile');
              },
              child: const Text("Go to Profile"),
            ),
          ],
        ),
      );
      return;
    }

    // Save Orders
    for (var cart in cartItems) {
      var cartData = cart.data() as Map<String, dynamic>;
      String productId = cartData['product_id'];
      int qty = quantities[productId] ?? cartData['quantity'] ?? 1;

      var productSnap = await FirebaseFirestore.instance
          .collection("SellerProduct")
          .doc(productId)
          .get();

      double price = 0.0;
      if (productSnap.exists) {
        price = double.tryParse(productSnap['price'].toString()) ?? 0.0;
      }

      double totalPrice = price * qty;

      await FirebaseFirestore.instance.collection("Orders").add({
        "email": userEmail,
        "product_id": productId,
        "quantity": qty,
        "total_price": totalPrice,
        "payment_method": paymentMethod,
        "timestamp": FieldValue.serverTimestamp(),
        "status": "pending",
      });
    }

    // Clear Cart
    for (var cart in cartItems) {
      await FirebaseFirestore.instance
          .collection("AddToCart")
          .doc(cart.id)
          .delete();
    }

    // ✅ Flushbar success
    Flushbar(
      message: "Order placed successfully with $paymentMethod!",
      duration: const Duration(seconds: 3),
      backgroundColor: Colors.green.shade700,
      icon: const Icon(Icons.check_circle, color: Colors.white),
      flushbarPosition: FlushbarPosition.TOP,
      borderRadius: BorderRadius.circular(12),
      margin: const EdgeInsets.all(8),
    ).show(context);
  }

  @override
  Widget build(BuildContext context) {
    if (userEmail == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: MyAppBar(),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("AddToCart")
            .where("email", isEqualTo: userEmail)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text("No data found",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            );
          }

          var cartItems = snapshot.data!.docs;

          return FutureBuilder(
            future: _calculateTotal(cartItems),
            builder: (context, AsyncSnapshot<double> totalSnap) {
              double totalBill = totalSnap.data ?? 0;

              return Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: cartItems.length,
                      itemBuilder: (context, index) {
                        var cartData =
                            cartItems[index].data() as Map<String, dynamic>;
                        String productId = cartData['product_id'];

                        int qty = quantities[productId] ?? (cartData['quantity'] ?? 1);
                        quantities[productId] = qty;

                        return FutureBuilder<DocumentSnapshot>(
                          future: FirebaseFirestore.instance
                              .collection("SellerProduct")
                              .doc(productId)
                              .get(),
                          builder: (context, productSnapshot) {
                            if (!productSnapshot.hasData ||
                                !productSnapshot.data!.exists) {
                              return const SizedBox.shrink();
                            }
                            var product = productSnapshot.data!;
                            double price =
                                double.tryParse(product['price'].toString()) ?? 0.0;

                            return Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              child: ListTile(
                                leading: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    product['image_url'],
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                title: Text(
                                  product['title'],
                                  style: GoogleFonts.quicksand(
                                      fontWeight: FontWeight.w600),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Rs. $price PKR",
                                        style: GoogleFonts.quicksand(
                                          color: Colors.green.shade700,
                                          fontWeight: FontWeight.w500,
                                        )),
                                    Row(
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.remove),
                                          onPressed: () {
                                            if (qty > 1) {
                                              setState(() {
                                                quantities[productId] = qty - 1;
                                              });
                                            }
                                          },
                                        ),
                                        Text(qty.toString(),
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold)),
                                        IconButton(
                                          icon: const Icon(Icons.add),
                                          onPressed: () {
                                            setState(() {
                                              quantities[productId] = qty + 1;
                                            });
                                          },
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () async {
                                    await FirebaseFirestore.instance
                                        .collection("AddToCart")
                                        .doc(cartItems[index].id)
                                        .delete();
                                  },
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                  // ✅ Total Bill & Buy Now
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 6,
                          offset: const Offset(0, -2),
                        )
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Total: Rs. $totalBill",
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green.shade800,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 5,
                          ),
                          onPressed: () => _showPaymentModal(cartItems, totalBill),
                          icon: const Icon(Icons.shopping_bag, color: Colors.white),
                    label: const Text(
  "Buy Now",
  style: TextStyle(
    fontSize: 16,
    color: Colors.white, // text ko white karne ke liye
  ),
),

                        )
                      ],
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  // ✅ Calculate total bill dynamically
  Future<double> _calculateTotal(List<QueryDocumentSnapshot> cartItems) async {
    double total = 0;
    for (var cart in cartItems) {
      var cartData = cart.data() as Map<String, dynamic>;
      String productId = cartData['product_id'];
      int qty = quantities[productId] ?? (cartData['quantity'] ?? 1);

      var productSnap = await FirebaseFirestore.instance
          .collection("SellerProduct")
          .doc(productId)
          .get();

      if (productSnap.exists) {
        double price =
            double.tryParse(productSnap['price'].toString()) ?? 0.0;
        total += price * qty;
      }
    }
    return total;
  }
}
