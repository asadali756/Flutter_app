import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AcceptedReq extends StatefulWidget {
  const AcceptedReq({Key? key}) : super(key: key);

  @override
  _AcceptedReqState createState() => _AcceptedReqState();
}

class _AcceptedReqState extends State<AcceptedReq> {
  String? ngoId;

  @override
  void initState() {
    super.initState();
    _loadNgoId();
  }

  Future<void> _loadNgoId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      ngoId = prefs.getString("ngoId");
    });
  }

  @override
  Widget build(BuildContext context) {
    if (ngoId == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: const Text("Accepted Requests"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("CompanyReq")
            .where("ngoData.ngoId", isEqualTo: ngoId)
            .where("status", whereIn: ["Accepted", "AdminApproved"])
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text("No Accepted Requests Found",
                  style: TextStyle(color: Colors.black54)),
            );
          }

          final requests = snapshot.data!.docs;

          return ListView.builder(
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final req = requests[index];
              final data = req.data() as Map<String, dynamic>;

              String status = data["status"] ?? "";
              String message = "";

              if (status == "Accepted") {
                message = "✅ Soon responded by admin";
              } else if (status == "AdminApproved") {
                message =
                    "📦 Soon you will receive waste.\nFor further updates contact:\n✉ ecocycle.pk@gmail.com";
              }

              return Card(
                margin: const EdgeInsets.all(12),
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  title: Text(
                    data["user_name"] ?? "Unknown User",
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Email: ${data["email"] ?? "N/A"}",
                          style: const TextStyle(color: Colors.black54)),
                      const SizedBox(height: 8),
                      Text("Status: $status",
                          style: const TextStyle(color: Colors.green)),
                      const SizedBox(height: 8),
                      Text(message,
                          style: const TextStyle(color: Colors.blueGrey)),
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
}
