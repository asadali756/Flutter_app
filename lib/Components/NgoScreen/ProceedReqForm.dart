import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProceedReqForm extends StatefulWidget {
  final String docId;
  final dynamic reqData;
  const ProceedReqForm({Key? key, required this.docId, required this.reqData}) : super(key: key);

  @override
  State<ProceedReqForm> createState() => _ProceedReqFormState();
}

class _ProceedReqFormState extends State<ProceedReqForm> {
  final _formKey = GlobalKey<FormState>();
  String paymentMethod = "Cash";
  DateTime? paymentDate;
  DateTime? maxReceiveDate;

  Future<void> _saveRequest() async {
    if (!_formKey.currentState!.validate()) return;
    if (paymentDate == null || maxReceiveDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Select payment & receive dates")),
      );
      return;
    }

    if (maxReceiveDate!.isBefore(paymentDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Receive date must be after payment date")),
      );
      return;
    }

    // 🔹 Fetch NGO data from SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Map<String, dynamic> ngoData = {
      "ngoId": prefs.getString("ngoId") ?? "",
      "ngoname": prefs.getString("ngoname") ?? "",
      "email": prefs.getString("email") ?? "",
      "phone": prefs.getString("phone") ?? "",
      "address": prefs.getString("address") ?? "",
      "image_url": prefs.getString("image_url") ?? "",
      "status": prefs.getString("status") ?? "",
      "type": prefs.getString("type") ?? "",
      "created_at": prefs.getString("created_at") ?? "",
    };

    // 🔹 Save with NGO data
    await FirebaseFirestore.instance
        .collection("CompanyReq")
        .doc(widget.docId)
        .update({
      "status": "Accepted",
      "payment_method": paymentMethod,
      "payment_date": paymentDate,
      "max_receive_date": maxReceiveDate,
      "ngoData": ngoData, // ✅ full NGO info saved
      "updatedAt": DateTime.now(),
    });

    Navigator.pop(context);
  }

  Future<void> _confirmAndSave() async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black87,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text("Confirm Acceptance", style: TextStyle(color: Colors.white)),
        content: const Text(
          "Are you sure you want to accept this request and proceed?",
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel", style: TextStyle(color: Colors.redAccent)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Accept", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      _saveRequest();
    }
  }

  Future<void> _pickDate(bool isPayment) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2025),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(primary: Colors.green),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isPayment) {
          paymentDate = picked;
        } else {
          maxReceiveDate = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: const Text("Proceed Request"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Text("User: ${widget.reqData['user_name']}", style: const TextStyle(color: Colors.black)),
              Text("Email: ${widget.reqData['email']}", style: const TextStyle(color: Colors.black54)),
              const SizedBox(height: 20),

              // Payment Method
              DropdownButtonFormField<String>(
                value: paymentMethod,
                dropdownColor: Colors.white,
                decoration: const InputDecoration(
                  labelText: "Payment Method",
                  labelStyle: TextStyle(color: Colors.black),
                  border: OutlineInputBorder(),
                ),
                style: const TextStyle(color: Colors.black),
                items: ["Cash", "Bank Transfer", "Online"].map((e) {
                  return DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(color: Colors.black)));
                }).toList(),
                onChanged: (val) => setState(() => paymentMethod = val!),
              ),

              const SizedBox(height: 20),

              // Payment Date
              ListTile(
                title: Text(
                  paymentDate == null
                      ? "Select Payment Date"
                      : "Payment Date: ${paymentDate!.toLocal()}".split(" ")[0],
                  style: const TextStyle(color: Colors.black),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.calendar_month, color: Colors.green),
                  onPressed: () => _pickDate(true),
                ),
              ),

              // Max Receive Date
              ListTile(
                title: Text(
                  maxReceiveDate == null
                      ? "Select Max Receive Date"
                      : "Max Receive Date: ${maxReceiveDate!.toLocal()}".split(" ")[0],
                  style: const TextStyle(color: Colors.black),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.calendar_today, color: Colors.green),
                  onPressed: () => _pickDate(false),
                ),
              ),

              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                onPressed: _confirmAndSave,
                child: const Text("Save & Accept", style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
