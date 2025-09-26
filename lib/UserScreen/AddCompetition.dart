import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project/Components/MyAppBar.dart';
import 'package:project/Components/bottomNav.dart';

class AddCompetition extends StatefulWidget {
  const AddCompetition({Key? key}) : super(key: key);

  @override
  State<AddCompetition> createState() => _AddCompetitionState();
}

class _AddCompetitionState extends State<AddCompetition> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(),
      backgroundColor: Colors.grey.shade100,
      body: SafeArea(
        child: Column(
          children: [
            // Top Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.green, Colors.green],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Competitions & Workshops",
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Register now and showcase your talent!",
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Competition List
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('Competition').snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final competitions = snapshot.data!.docs;

                  if (competitions.isEmpty) {
                    return Center(
                      child: Text(
                        "No Competitions Available",
                        style: GoogleFonts.inter(fontSize: 16, color: Colors.grey[600]),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    itemCount: competitions.length,
                    itemBuilder: (context, index) {
                      final data = competitions[index].data() as Map<String, dynamic>;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: ModernCompetitionCard(data: data),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: AppBottomNav(currentIndex: 1),
    );
  }
}

class ModernCompetitionCard extends StatelessWidget {
  final Map<String, dynamic> data;
  const ModernCompetitionCard({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String title = data['title'] ?? 'No Title';
    final String description = data['description'] ?? 'No Description';
    final String startDate = data['startDate'] ?? '';
    final String endDate = data['endDate'] ?? '';
    final String imageUrl = data['image'] ?? '';
    final String competitionType = data['competitionType'] ?? '';
    final String audience = data['audience'] ?? '';
    final int registeredCount = data['registeredCount'] ?? 0;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 12,
            offset: const Offset(4, 6),
          ),
        ],
        border: Border.all(color: Colors.white.withOpacity(0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.green,
                  child: const Icon(Icons.admin_panel_settings, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    "Posted by Admin",
                    style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                ),
                Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  startDate.isNotEmpty
                      ? DateFormat('dd MMM yyyy').format(DateTime.tryParse(startDate) ?? DateTime.now())
                      : 'N/A',
                  style: GoogleFonts.inter(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),

          // Image & Badge
          Stack(
            children: [
              ClipRRect(
                child: imageUrl.isNotEmpty
                    ? Image.network(
                        imageUrl,
                        width: double.infinity,
                        height: 180,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: double.infinity,
                          height: 180,
                          color: Colors.grey[300],
                          child: const Center(child: Text("Image not found")),
                        ),
                      )
                    : Container(
                        width: double.infinity,
                        height: 180,
                        color: Colors.grey[300],
                        child: const Center(child: Text("No Image")),
                      ),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.85),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    competitionType,
                    style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(fontSize: 14, color: Colors.grey[800]),
                ),
                const SizedBox(height: 12),

                Row(
                  children: [
                    Icon(Icons.group, size: 18, color: Colors.green.shade800),
                    const SizedBox(width: 6),
                    Text(
                      "$registeredCount Registered",
                      style: GoogleFonts.inter(fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(width: 12),
                    Icon(Icons.people_alt, size: 18, color: Colors.orange.shade700),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        audience,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                Row(
                  children: [
                    Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      "Start: ${startDate.isNotEmpty ? DateFormat('dd MMM yyyy').format(DateTime.tryParse(startDate) ?? DateTime.now()) : 'N/A'}",
                      style: GoogleFonts.inter(fontSize: 13, color: Colors.grey),
                    ),
                    const SizedBox(width: 12),
                    Icon(Icons.calendar_month, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      "End: ${endDate.isNotEmpty ? DateFormat('dd MMM yyyy').format(DateTime.tryParse(endDate) ?? DateTime.now()) : 'N/A'}",
                      style: GoogleFonts.inter(fontSize: 13, color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return RegisterCompetitionModal(data: data);
                            },
                        );
                        },
                        icon: const Icon(Icons.app_registration, size: 18),
                        label: const Text('Register'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          textStyle: GoogleFonts.inter(
                              fontSize: 15, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class RegisterCompetitionModal extends StatefulWidget {
  final Map<String, dynamic> data;
  const RegisterCompetitionModal({Key? key, required this.data}) : super(key: key);

  @override
  State<RegisterCompetitionModal> createState() => _RegisterCompetitionModalState();
}

class _RegisterCompetitionModalState extends State<RegisterCompetitionModal> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController headNameController = TextEditingController();
  final TextEditingController instituteController = TextEditingController();
  final TextEditingController designationController = TextEditingController();
  final TextEditingController contactNumberController = TextEditingController();
  final TextEditingController contactEmailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Register for ${widget.data['title'] ?? 'Competition'}",
                  style: GoogleFonts.spaceGrotesk(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: headNameController,
                        decoration: const InputDecoration(
                          labelText: "Head Name",
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) => value!.isEmpty ? 'Required' : null,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        controller: instituteController,
                        decoration: const InputDecoration(
                          labelText: "Institute Name",
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) => value!.isEmpty ? 'Required' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: designationController,
                        decoration: const InputDecoration(
                          labelText: "Designation",
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) => value!.isEmpty ? 'Required' : null,
                      ),
                    ),
                    const SizedBox(width: 10),
          
                  ],
                ),
                const SizedBox(height: 10),

                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: contactNumberController,
                        decoration: const InputDecoration(
                          labelText: "Contact Number",
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) => value!.isEmpty ? 'Required' : null,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        controller: contactEmailController,
                        decoration: const InputDecoration(
                          labelText: "Contact Email",
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) => value!.isEmpty ? 'Required' : null,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      final requestData = {
                        'headName': headNameController.text,
                        'instituteName': instituteController.text,
                        'designation': designationController.text,
                        'contactNumber': contactNumberController.text,
                        'contactEmail': contactEmailController.text,
                        'competitionInfo': widget.data,
                        'timestamp': FieldValue.serverTimestamp(),
                      };

                      await FirebaseFirestore.instance
                          .collection('RequestCompetition')
                          .add(requestData);

                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Registered Successfully!')),
                      );
                    }
                  },
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                    child: Text('Submit', style: TextStyle(fontSize: 16)),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
