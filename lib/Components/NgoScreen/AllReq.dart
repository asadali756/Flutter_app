import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project/Components/NgoScreen/ProceedReqForm.dart';

class AllReq extends StatefulWidget {
  const AllReq({Key? key}) : super(key: key);

  @override
  _AllReqState createState() => _AllReqState();
}

class _AllReqState extends State<AllReq> {
  final CollectionReference companyReq =
      FirebaseFirestore.instance.collection("CompanyReq");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: const Text("Available Requests"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: companyReq.where("status", isEqualTo: "Pending").snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text("❌ Error loading data"));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.green));
          }

          final data = snapshot.data!.docs;

          if (data.isEmpty) {
            return const Center(
              child: Text("No Pending Requests", style: TextStyle(color: Colors.white)),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(10),
            itemCount: data.length,
            itemBuilder: (context, index) {
              final req = data[index];
              return Card(
                color: Colors.grey.shade100,
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  title: Text(
                    "${req['user_name']} - ${req['category']}",
                    style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    "Offer: ₹${req['offer_amount']} | Qty: ${req['quantity']}",
                    style: const TextStyle(color: Colors.black),
                  ),
                  trailing: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    child: const Text("Accept" , style: TextStyle(color: Colors.white),),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ProceedReqForm(docId: req.id, reqData: req),
                        ),
                      );
                    },
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
