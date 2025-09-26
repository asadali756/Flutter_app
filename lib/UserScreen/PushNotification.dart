import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

class PushNotification extends StatefulWidget {
  const PushNotification({Key? key}) : super(key: key);

  @override
  State<PushNotification> createState() => _PushNotificationState();
}

class _PushNotificationState extends State<PushNotification> {
  final col = FirebaseFirestore.instance.collection('Notifications');

  @override
  void initState() {
    super.initState();
    markRead();
  }

  // Mark all unread notifications as read
  Future<void> markRead() async {
    var snaps = await col.where('isRead', isEqualTo: false).get();
    for (var doc in snaps.docs) {
      doc.reference.update({'isRead': true});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100, // Background color
      appBar: AppBar(
        title: Text(
          '🔔 Notifications',
          style: GoogleFonts.spaceGrotesk(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.teal.shade800,
        elevation: 2,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: col.orderBy('timestamp', descending: true).snapshots(),
        builder: (ctx, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snap.data!.docs;

          if (docs.isEmpty) {
            return Center(
              child: Text(
                'No notifications yet.',
                style: GoogleFonts.inter(fontSize: 14, color: Colors.teal.shade800),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: docs.length,
            itemBuilder: (ctx, i) {
              final d = docs[i];
              final isRead = d['isRead'] == true;
              final timestamp = (d['timestamp'] as Timestamp).toDate();
              final formattedTime =
                  "${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')} | ${timestamp.day}/${timestamp.month}/${timestamp.year}";

              return Card(
                color: isRead ? Colors.green.shade100 : Colors.orange.shade50, // Green for read
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  leading: Icon(
                    isRead ? Icons.mark_email_read_rounded : Icons.markunread,
                    color: isRead ? Colors.green : Colors.orange,
                  ),
                  title: Text(
                    "📩 ${d['title']}",
                    style: GoogleFonts.spaceGrotesk(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: Colors.teal.shade800,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        d['body'],
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.access_time_rounded,
                            size: 12,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            formattedTime,
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  onTap: () {
                    Navigator.pushNamed(context, d['route']);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
