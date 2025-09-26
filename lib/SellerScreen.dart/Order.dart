import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class Order extends StatefulWidget {
  const Order({Key? key}) : super(key: key);

  @override
  _OrderState createState() => _OrderState();
}

class _OrderState extends State<Order> {
  Future<Map<String, dynamic>?> _getProductDetails(String productId) async {
    final doc = await FirebaseFirestore.instance
        .collection("SellerProduct")
        .doc(productId)
        .get();
    return doc.data();
  }

  Future<void> _showConfirmationDialog({
    required String title,
    required String content,
    required VoidCallback onConfirm,
  }) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: Text(title),
          content: Text(content),
          actions: [
            TextButton(
              child: const Text("Cancel"),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child:
                  const Text("Confirm", style: TextStyle(color: Colors.white)),
              onPressed: () {
                Navigator.of(context).pop();
                onConfirm();
              },
            ),
          ],
        );
      },
    );
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case "delivered":
        return Colors.green;
      case "received":
        return Colors.blue;
      case "pending":
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  IconData _statusIcon(String status) {
    switch (status.toLowerCase()) {
      case "delivered":
        return Icons.check_circle_outline;
      case "received":
        return Icons.done_all;
      case "pending":
        return Icons.pending_actions;
      default:
        return Icons.info_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        centerTitle: true,
        title: const Text(
          "Manage Orders",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("Orders")
            .orderBy("timestamp", descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No orders yet"));
          }

          final orders = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final orderData = orders[index].data() as Map<String, dynamic>;
              final productId = orderData["product_id"];
              final timestamp = orderData["timestamp"] != null
                  ? (orderData["timestamp"] as Timestamp).toDate()
                  : DateTime.now();
              final status = orderData["status"] ?? "Pending";

              return FutureBuilder<Map<String, dynamic>?>(
                future: _getProductDetails(productId),
                builder: (context, productSnap) {
                  if (!productSnap.hasData) {
                    return const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: LinearProgressIndicator(),
                    );
                  }

                  final product = productSnap.data!;
                  final imageUrl = product["image_url"] ?? "";
                  final title = product["title"] ?? "Unknown Product";
                  final category = product["category"] ?? "N/A";

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Product Row
                          Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  imageUrl,
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                  errorBuilder:
                                      (context, error, stackTrace) =>
                                          const Icon(Icons.broken_image,
                                              size: 50),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      title,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16),
                                    ),
                                    const SizedBox(height: 4),
                                    Text("Category: $category"),
                                    Text("Buyer: ${orderData["email"] ?? "N/A"}"),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          // Quantity & Total
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.shopping_cart, size: 18),
                                  const SizedBox(width: 4),
                                  Text("Qty: ${orderData["quantity"] ?? 0}"),
                                ],
                              ),
                              Row(
                                children: [
                                  const Icon(Icons.attach_money, size: 18),
                                  const SizedBox(width: 4),
                                  Text(
                                      "Rs. ${orderData["total_price"] ?? 0}"),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          // Date & Status
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.calendar_today, size: 18),
                                  const SizedBox(width: 4),
                                  Text(DateFormat('dd MMM yyyy, hh:mm a')
                                      .format(timestamp)),
                                ],
                              ),
                              Row(
                                children: [
                                  Icon(_statusIcon(status),
                                      color: _statusColor(status), size: 18),
                                  const SizedBox(width: 4),
                                  Text(
                                    status.toUpperCase(),
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: _statusColor(status)),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          // Payment Method
                          Row(
                            children: [
                              const Icon(Icons.payment, size: 18),
                              const SizedBox(width: 4),
                              Text(
                                  "Payment: ${orderData["payment_method"] ?? "N/A"}"),
                            ],
                          ),
                          const SizedBox(height: 8),
                          // Action Buttons
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green),
                                onPressed:
                                    (status.toLowerCase() == "pending")
                                        ? () {
                                            _showConfirmationDialog(
                                              title: "Confirm Delivery",
                                              content:
                                                  "Mark this order as Delivered?",
                                              onConfirm: () async {
                                                await FirebaseFirestore.instance
                                                    .collection("Orders")
                                                    .doc(orders[index].id)
                                                    .update(
                                                        {"status": "Delivered"});
                                              },
                                            );
                                          }
                                        : null,
                                child: const Text("Mark Delivered",
                                    style: TextStyle(color: Colors.white)),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue),
                                onPressed:
                                    (status.toLowerCase() == "delivered")
                                        ? () {
                                            _showConfirmationDialog(
                                              title: "Confirm Received",
                                              content:
                                                  "Mark this order as Received?",
                                              onConfirm: () async {
                                                await FirebaseFirestore.instance
                                                    .collection("Orders")
                                                    .doc(orders[index].id)
                                                    .update(
                                                        {"status": "Received"});
                                              },
                                            );
                                          }
                                        : null,
                                child: const Text("Mark Received",
                                    style: TextStyle(color: Colors.white)),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red),
                                onPressed: () {
                                  _showConfirmationDialog(
                                    title: "Confirm Delete",
                                    content: "Delete this order?",
                                    onConfirm: () async {
                                      await FirebaseFirestore.instance
                                          .collection("Orders")
                                          .doc(orders[index].id)
                                          .delete();
                                    },
                                  );
                                },
                                child: const Text("Delete",
                                    style: TextStyle(color: Colors.white)),
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
          );
        },
      ),
    );
  }
}
