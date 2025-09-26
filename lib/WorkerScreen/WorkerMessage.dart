import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class WorkerMessage extends StatefulWidget {
  const WorkerMessage({Key? key}) : super(key: key);

  @override
  _WorkerMessageState createState() => _WorkerMessageState();
}

class _WorkerMessageState extends State<WorkerMessage> {
  final TextEditingController _messageController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  final String workerId = "worker_1";
  final String adminId = "admin_1";
  late String chatId;

  @override
  void initState() {
    super.initState();
    chatId = "${workerId}_$adminId";

    // Set worker online
    FirebaseFirestore.instance.collection('status').doc(workerId).set({"online": true});
  }

  @override
  void dispose() {
    // Set worker offline
    FirebaseFirestore.instance.collection('status').doc(workerId).set({"online": false});
    _messageController.dispose();
    _focusNode.dispose();
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
      "sender": "worker",
      "message": messageText,
      "timestamp": FieldValue.serverTimestamp(),
      "status": "sent",
      "isDeleted": false,
    });

    _messageController.clear();
    _focusNode.requestFocus();
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
                final data = doc.data() as Map<String, dynamic>;
                if (data['sender'] == 'worker') {
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
      statusIcon = const Icon(Icons.done_all, size: 16, color: Colors.green);
    }

    String time = '';
    final timestamp = message['timestamp'];
    if (timestamp != null && timestamp is Timestamp) {
      final dt = timestamp.toDate();
      time =
          "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')} • ${dt.day}/${dt.month}/${dt.year}";
    } else {
      time = "Sending...";
    }

    return GestureDetector(
      onLongPress: () {
        if (isMe && !isDeleted) _showDeleteDialog(docId);
      },
      child: Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isMe ? Colors.green.shade600 : Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade300,
                blurRadius: 4,
                offset: const Offset(2, 2),
              )
            ],
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
                          : message['message'] ?? '',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontStyle: isDeleted ? FontStyle.italic : FontStyle.normal,
                        color: isDeleted
                            ? Colors.grey[500]
                            : (isMe ? Colors.white : Colors.black87),
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
                  fontSize: 11,
                  color: isMe ? Colors.white70 : Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
                  .update({
                'isDeleted': true,
                'message': '',
              });
            },
            child: const Text("Unsend", style: TextStyle(color: Colors.red)),
          ),
        ],
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

    final adminStatusRef = FirebaseFirestore.instance.collection('status').doc(adminId);

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.green.shade700,
        elevation: 2,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: StreamBuilder<DocumentSnapshot>(
          stream: adminStatusRef.snapshots(),
          builder: (context, snapshot) {
            final online = snapshot.data?.get("online") ?? false;
            return Row(
              children: [
                const Icon(Icons.admin_panel_settings_outlined, color: Colors.white, size: 20),
                const SizedBox(width: 6),
                Text(
                  "Chat With Admin",
                  style: GoogleFonts.spaceGrotesk(fontSize: 18, color: Colors.white),
                ),
                const SizedBox(width: 8),
                if (online) const Icon(Icons.circle, size: 10, color: Colors.lightGreenAccent),
              ],
            );
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_forever, color: Colors.white),
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

                final messages = snapshot.data!.docs;

                // Update 'sent' messages from admin to 'delivered'
                for (var doc in messages) {
                  final data = doc.data() as Map<String, dynamic>;
                  if (data['status'] == 'sent' && data['sender'] == 'admin') {
                    doc.reference.update({'status': 'delivered'});
                  }
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final data = messages[index].data() as Map<String, dynamic>;
                    final isMe = data['sender'] == 'worker';
                    return messageTile(data, isMe, messages[index].id);
                  },
                );
              },
            ),
          ),
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    focusNode: _focusNode,
                    style: GoogleFonts.inter(fontSize: 14),
                    decoration: InputDecoration(
                      hintText: "Type a message...",
                      hintStyle: GoogleFonts.inter(fontSize: 13, color: Colors.grey),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                CircleAvatar(
                  backgroundColor: Colors.green.shade600,
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
