import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project/Components/AppColors.dart';

class AdminChat extends StatefulWidget {
  const AdminChat({Key? key}) : super(key: key);

  @override
  State<AdminChat> createState() => _AdminChatState();
}

class _AdminChatState extends State<AdminChat> {
  final TextEditingController _messageController = TextEditingController();
  final String adminId = "admin_1";
  final String workerId = "worker_1";
  String chatId = "";

  @override
  void initState() {
    super.initState();
    chatId = "${workerId}_$adminId";
    FirebaseFirestore.instance.collection('status').doc(adminId).set({"online": true});
  }

  @override
  void dispose() {
    FirebaseFirestore.instance.collection('status').doc(adminId).set({"online": false});
    super.dispose();
  }

  void sendMessage() async {
    final messageText = _messageController.text.trim();
    if (messageText.isEmpty) return;

    await FirebaseFirestore.instance
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .add({
      "sender": "admin",
      "message": messageText,
      "timestamp": FieldValue.serverTimestamp(),
      "status": "sent",
      "isDeleted": false,
    });

    _messageController.clear();
  }

  void _showDeleteDialog(String docId) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Message"),
        content: const Text("Do you want to unsend this message for everyone?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await FirebaseFirestore.instance
                  .collection('chats')
                  .doc(chatId)
                  .collection('messages')
                  .doc(docId)
                  .update({'isDeleted': true, 'message': ''});
            },
            child: const Text("Unsend", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showClearChatDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Clear Chat"),
        content: const Text("Are you sure you want to clear all your messages?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final messagesRef = FirebaseFirestore.instance
                  .collection('chats')
                  .doc(chatId)
                  .collection('messages');

              final snapshot = await messagesRef.get();
              for (var doc in snapshot.docs) {
                final data = doc.data();
                if (data['sender'] == 'admin') {
                  await doc.reference.delete();
                }
              }
            },
            child: const Text("Clear", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget messageTile(Map<String, dynamic> message, bool isMe, String docId) {
    final bool isDeleted = message['isDeleted'] ?? false;

    Icon statusIcon = const Icon(Icons.check, size: 14, color: Colors.grey);
    if (message['status'] == 'delivered') {
      statusIcon = const Icon(Icons.done_all, size: 16, color: Colors.grey);
    } else if (message['status'] == 'seen') {
      statusIcon = const Icon(Icons.done_all, size: 16, color: Colors.blue);
    }

    String time = '';
    final timestamp = message['timestamp'];
    if (timestamp != null && timestamp is Timestamp) {
      final dt = timestamp.toDate();
      time = "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')} • ${dt.day}/${dt.month}/${dt.year}";
    } else {
      time = "Sending...";
    }

    return GestureDetector(
      onLongPress: () {
        if (isMe && !isDeleted) _showDeleteDialog(docId);
      },
      onSecondaryTap: () {
        if (isMe && !isDeleted) _showDeleteDialog(docId);
      },
      child: Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isMe
                ? AppColors.deepTeal.withOpacity(0.85)
                : AppColors.softWhite.withOpacity(0.95),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      isDeleted
                          ? (isMe ? "You deleted this message" : "This message was deleted")
                          : message['message'],
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontStyle: isDeleted ? FontStyle.italic : FontStyle.normal,
                        color: isDeleted
                            ? Colors.grey
                            : (isMe ? Colors.white : Colors.black),
                      ),
                    ),
                  ),
                  if (isMe && !isDeleted) const SizedBox(width: 5),
                  if (isMe && !isDeleted) statusIcon,
                ],
              ),
              const SizedBox(height: 4),
              Text(
                time,
                style: GoogleFonts.inter(
                  fontSize: 10,
                  color: isMe ? Colors.white70 : Colors.grey[700],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final messagesRef = FirebaseFirestore.instance
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: false);

    final workerStatusRef = FirebaseFirestore.instance.collection('status').doc(workerId);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.deepTeal,
        title: StreamBuilder<DocumentSnapshot>(
          stream: workerStatusRef.snapshots(),
          builder: (context, snapshot) {
            final online = snapshot.data?.get("online") ?? false;
            return Row(
              children: [
                const Icon(Icons.person_outline, color: Colors.white, size: 20),
                const SizedBox(width: 6),
                Text(
                  "Worker Chat 💬",
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 8),
                if (online)
                  Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            );
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_forever),
            tooltip: 'Clear My Chat',
            onPressed: _showClearChatDialog,
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: messagesRef.snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

                final messages = snapshot.data!.docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return !(data['sender'] == 'worker' && data['isDeleted'] == true);
                }).toList();

                for (var doc in messages) {
                  final data = doc.data() as Map<String, dynamic>;
                  if (data['status'] != 'seen' && data['sender'] == 'worker') {
                    doc.reference.update({'status': 'seen'});
                  }
                }

                return ListView(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  children: messages.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final isMe = data['sender'] == 'admin';
                    return messageTile(data, isMe, doc.id);
                  }).toList(),
                );
              },
            ),
          ),
          const Divider(height: 1),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            color: AppColors.iceBlue,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    style: GoogleFonts.inter(fontSize: 14),
                    decoration: InputDecoration.collapsed(
                      hintText: "Type a message",
                      hintStyle: GoogleFonts.inter(fontSize: 13, color: Colors.grey),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send, color: AppColors.deepTeal),
                  onPressed: sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
