import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project/Components/MyAppBar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';

class Tracking extends StatefulWidget {
  const Tracking({Key? key}) : super(key: key);

  @override
  _TrackingState createState() => _TrackingState();
}

class _TrackingState extends State<Tracking> {
  String? userEmail;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    String? email = prefs.getString("userEmail");

    setState(() {
      userEmail = email;
    });

    debugPrint("📌 Loaded email from SharedPreferences: $userEmail");
  }

  Color _statusColor(String status) {
    switch (status) {
      case "pending":
        return Colors.orange;
      case "shipped":
        return Colors.blue;
      case "delivered":
        return Colors.green;
      case "cancelled":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case "pending":
        return Icons.pending_actions;
      case "shipped":
        return Icons.local_shipping;
      case "delivered":
        return Icons.check_circle_outline;
      case "cancelled":
        return Icons.cancel_outlined;
      default:
        return Icons.info_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (userEmail == null) {
      return const Scaffold(
        body: Center(
          child: Text(
            "No user found. Please login again.",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: MyAppBar(
     
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("Orders")
            .where("email", isEqualTo: userEmail)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                "No orders found!",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            );
          }

          var orders = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              var order = orders[index].data() as Map<String, dynamic>;

              String productId = order['product_id'] ?? "";
              String status = order['status'] ?? "pending";
              int quantity = order['quantity'] ?? 1;
              double total = (order['total_price'] ?? 0).toDouble();
              Timestamp ts = order['timestamp'] ?? Timestamp.now();
              DateTime date = ts.toDate();

              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection("SellerProduct")
                    .doc(productId)
                    .get(),
                builder: (context, productSnap) {
                  if (productSnap.connectionState ==
                      ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: LinearProgressIndicator(),
                    );
                  }

                  if (!productSnap.hasData || !productSnap.data!.exists) {
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        leading: const Icon(Icons.error, color: Colors.red),
                        title: const Text("Product not found"),
                        subtitle: Text("Order ID: ${orders[index].id}"),
                      ),
                    );
                  }

                  var product =
                      productSnap.data!.data() as Map<String, dynamic>;

                  return Card(
                    elevation: 4,
                    shadowColor: Colors.grey.withOpacity(0.3),
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  product['image_url'] ?? "",
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Icon(Icons.broken_image, size: 50),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  product['title'] ?? "Unknown Product",
                                  style: GoogleFonts.quicksand(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.shopping_cart, size: 18),
                                  const SizedBox(width: 4),
                                  Text("Qty: $quantity"),
                                ],
                              ),
                              Row(
                                children: [
                                  const Icon(Icons.attach_money, size: 18),
                                  const SizedBox(width: 4),
                                  Text("Rs. $total"),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.calendar_today, size: 18),
                                  const SizedBox(width: 4),
                                  Text("${date.day}/${date.month}/${date.year}"),
                                ],
                              ),
                              Row(
                                children: [
                                  Icon(_statusIcon(status),
                                      color: _statusColor(status), size: 18),
                                  const SizedBox(width: 4),
                                  Text(
                                    status.toUpperCase(),
                                    style: GoogleFonts.quicksand(
                                      fontWeight: FontWeight.w600,
                                      color: _statusColor(status),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "Payment Method: ${order['payment_method'] ?? "Unknown"}",
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
