import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:project/Components/MyAppBar.dart';
import 'package:project/Components/bottomNav.dart';
import 'package:printing/printing.dart';
import 'package:project/UserScreen/NgoRegistrationForm.dart';
import 'package:project/UserScreen/SellerRegisterForm.dart';
import 'package:project/UserScreen/WorkerRegistration.dart';

class Joinus extends StatefulWidget {
  const Joinus({Key? key}) : super(key: key);

  @override
  _JoinusState createState() => _JoinusState();
}

class _JoinusState extends State<Joinus> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: MyAppBar(),
      bottomNavigationBar: AppBottomNav(currentIndex: 6),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child:Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    joinOptionCard(
      context,
      title: "Company",
      description:
          "Have waste material and want to manage it on a budget? Join as a Company.",
      note:
          "First month is trial. After 1 month, you have to pay 1,000 PKR; if not, account will be deactivated.",
      pdfButtonText: "View Company PDF",
      onPdfTap: () => generateAndOpenPdf("Company"),
      onRegisterTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => NGORegisterForm()),
        );
      },
      color: Colors.green.shade100,
      icon: Icons.business,
    ),
    SizedBox(height: 16),

    joinOptionCard(
      context,
      title: "Seller",
      description:
          "Have your own handmade products? Sell them on our platform.",
      note:
          "After selling 5 products/month, platform charges 10 PKR/product at the end of month; unpaid bills will deactivate account.",
      pdfButtonText: "View Seller PDF",
      onPdfTap: () => generateAndOpenPdf("Seller"),
      onRegisterTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => SellerRegisterForm()),
        );
      },
      color: Colors.green.shade100,
      icon: Icons.shopping_bag,
    ),
    SizedBox(height: 16),

    joinOptionCard(
      context,
      title: "Worker",
      description:
          "Have your own transport? Join as our pick & drop partner.",
      note: "Salary: 5,000 PKR + 200 PKR per pick & drop",
      pdfButtonText: "View Worker PDF",
      onPdfTap: () => generateAndOpenPdf("Worker"),
      onRegisterTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => WorkerRegisterForm()),
        );
      },
      color: Colors.green.shade100,
      icon: Icons.directions_car,
    ),
  ],
)
 ),
    );
  }

Widget joinOptionCard(
  BuildContext context, {
  required String title,
  required String description,
  required String note,
  required String pdfButtonText,
  required VoidCallback onPdfTap,
  required VoidCallback onRegisterTap,
  required Color color,
  required IconData icon,
}) {
  return Card(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    color: color,
    elevation: 4,
    child: Padding(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 40, color: Colors.green),
              SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.green),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Text(
            description,
            style: TextStyle(fontSize: 16, color: Colors.grey[800]),
          ),
          SizedBox(height: 8),
          Text(
            note,
            style: TextStyle(fontSize: 14, color: Colors.grey[700]),
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: onPdfTap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(
                  pdfButtonText,
                  style: TextStyle(fontSize: 14, color: Colors.white),
                ),
              ),
              ElevatedButton(
                onPressed: onRegisterTap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(
                  "Register Now",
                  style: TextStyle(fontSize: 14, color: Colors.white),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

Future<void> generateAndOpenPdf(String role) async {
  final pdf = pw.Document();

  // Load logo image
  final ByteData bytes = await rootBundle.load('assets/images/Eco.png');
  final Uint8List logoImage = bytes.buffer.asUint8List();

  String title = "";
  String brief = "";
  String chargesInfo = "";
  String requirements = "Requirements:\n- Age: 18+\n- NIC\n- Active Gmail";

  if (role == "Company") {
    title = "Company";
    brief =
        "If you are a company that has waste materials, you can join our platform to manage it efficiently and cost-effectively.";
    chargesInfo =
        "First month is trial. After 1 month, you have to pay 1,000 PKR. If not paid, your account will be deactivated.";
    requirements += "\n- Registration documents";
  } else if (role == "Seller") {
    title = "Seller";
    brief = "If you have handmade products, you can sell them on our platform.";
    chargesInfo =
        "After selling 5 products in a month, you have to pay 10 PKR per additional product at the end of the month. If not paid, your account will be deactivated.";
    requirements += "\n- Proof of handmade products";
  } else if (role == "Worker") {
    title = "Worker";
    brief = "If you have your own transport, you can join as our pick & drop partner.";
    chargesInfo = "Salary package: 5,000 PKR/month + 200 PKR per pick & drop.";
    requirements += "\n- Personal transport";
  }

  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Row(
              children: [
                pw.Image(pw.MemoryImage(logoImage), width: 60, height: 60),
                pw.SizedBox(width: 12),
                pw.Text(
                  "Eco Cycle Platform",
                  style: pw.TextStyle(
                      fontSize: 24,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.green900),
                ),
              ],
            ),
            pw.SizedBox(height: 24),
            pw.Text(title,
                style: pw.TextStyle(
                    fontSize: 28,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.green)),
            pw.SizedBox(height: 16),
            pw.Text(brief, style: pw.TextStyle(fontSize: 14)),
            pw.SizedBox(height: 12),
            pw.Text(chargesInfo,
                style: pw.TextStyle(
                    fontSize: 14, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 12),
            pw.Text(requirements,
                style: pw.TextStyle(
                    fontSize: 14, fontWeight: pw.FontWeight.bold)),
          ],
        );
      },
    ),
  );

  // Open PDF directly without saving
  await Printing.layoutPdf(
    onLayout: (PdfPageFormat format) async => pdf.save(),
  );
}
}