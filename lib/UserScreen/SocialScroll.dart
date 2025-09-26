import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:project/Components/MyAppBar.dart';
import 'package:project/Components/bottomNav.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SocialScroll extends StatefulWidget {
  const SocialScroll({Key? key}) : super(key: key);

  @override
  _SocialScrollState createState() => _SocialScrollState();
}

class _SocialScrollState extends State<SocialScroll> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? selectedEmail;
  Map<String, String> emailToProfilePic = {}; // Map to store email -> profilePic

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: const MyAppBar(),
      bottomNavigationBar: const AppBottomNav(currentIndex: 3),
      body: Column(
        children: [
          // Stories Section
          SizedBox(
            height: 130,
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('SocialAccount')
                  .where('status', isEqualTo: 'Public')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator(strokeWidth: 2));
                final accounts = snapshot.data!.docs;
                if (accounts.isEmpty) return const Center(child: Text("No accounts found."));
                
                // Store email -> profilePic mapping
                emailToProfilePic = {
                  for (var acc in accounts)
                    acc['email'] ?? "": acc['profilePic'] ?? 'https://via.placeholder.com/150'
                };

                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  itemCount: accounts.length,
                  itemBuilder: (context, index) {
                    var account = accounts[index];
                    String email = account['email'] ?? "";
                    bool isSelected = selectedEmail == email;
                    return GestureDetector(
                      onTap: () => setState(() => selectedEmail = email),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        child: Column(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isSelected ? Colors.deepPurple : Colors.grey.shade300,
                                  width: 3,
                                ),
                              ),
                              child: CircleAvatar(
                                radius: 32,
                                backgroundColor: Colors.grey.shade200,
                                backgroundImage: NetworkImage(account['profilePic'] ?? 'https://via.placeholder.com/150'),
                              ),
                            ),
                            const SizedBox(height: 6),
                            SizedBox(
                              width: 70,
                              child: Text(
                                account['username'] ?? "Unknown",
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                  color: isSelected ? Colors.deepPurple : Colors.black87,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 10),

          // Posts Section
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('SocialPost')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator(strokeWidth: 2));
                var posts = snapshot.data!.docs;

                if (selectedEmail != null) {
                  posts = posts.where((post) => post['email'] == selectedEmail).toList();
                }
                if (posts.isEmpty) return const Center(child: Text("No posts available.", style: TextStyle(fontSize: 16)));

                return ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  itemCount: posts.length,
                  itemBuilder: (context, index) {
                    var post = posts[index];
                    final postData = post.data() as Map<String, dynamic>;

                    String formattedDate = "";
                    try {
                      formattedDate = DateFormat.yMMMd().add_jm().format(postData['createdAt'].toDate());
                    } catch (e) {
                      formattedDate = "Unknown Date";
                    }

                    // Safe handling of reactions and comments
                    List reactions = postData.containsKey('reactions') && postData['reactions'] != null
                        ? List.from(postData['reactions'])
                        : [];

                    List comments = postData.containsKey('comments') && postData['comments'] != null
                        ? List.from(postData['comments'])
                        : [];

                    // Get profilePic from stored map
                    String postProfilePic = emailToProfilePic[postData['email']] ?? 'https://via.placeholder.com/150';

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: Card(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        elevation: 5,
                        shadowColor: Colors.grey.shade300,
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Post Header
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 22,
                                    backgroundImage: NetworkImage(postProfilePic),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(postData['email'] ?? "Unknown",
                                            style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14)),
                                        Text(formattedDate,
                                            style: GoogleFonts.inter(fontSize: 11, color: Colors.grey.shade600)),
                                      ],
                                    ),
                                  ),
                                  IconButton(icon: const Icon(LucideIcons.moreHorizontal), onPressed: () {}),
                                ],
                              ),
                              const SizedBox(height: 10),

                              // Caption
                              Text(postData['caption'] ?? "", style: GoogleFonts.inter(fontSize: 15)),
                              const SizedBox(height: 10),

                              // Media
if (postData['mediaUrls'] != null && postData['mediaUrls'].isNotEmpty)
  SizedBox(
    height: 220,
    child: ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: postData['mediaUrls'].length,
      itemBuilder: (context, mediaIndex) {
        return Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              postData['mediaUrls'][mediaIndex],
              width: MediaQuery.of(context).size.width, // full width
              fit: BoxFit.cover,
            ),
          ),
        );
      },
    ),
  ),
const SizedBox(height: 10),


                              // Reactions & Comments Display
                              Wrap(
                                children: [
                                  ...reactions.map((r) => Padding(
                                        padding: const EdgeInsets.only(right: 4),
                                        child: Text(r['emoji'], style: const TextStyle(fontSize: 18)),
                                      )),
                                  const SizedBox(width: 10),
                                  Text("${comments.length} comments",
                                      style: const TextStyle(fontSize: 13, color: Colors.grey)),
                                ],
                              ),
                              const SizedBox(height: 5),

                              // Actions
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      GestureDetector(
                                        onTap: () => showReactionSheet(post.id, reactions),
                                        child: const Icon(Icons.emoji_emotions_outlined, color: Colors.redAccent),
                                      ),
                                      const SizedBox(width: 8),
                                      IconButton(
                                        icon: const Icon(Icons.comment_outlined, color: Colors.blueAccent),
                                        onPressed: () => showCommentDialog(post.id),
                                      ),
                                      const SizedBox(width: 4),
                                      IconButton(icon: const Icon(Icons.share_outlined, color: Colors.green), onPressed: () {}),
                                    ],
                                  ),
                                  IconButton(icon: const Icon(LucideIcons.bookmark), onPressed: () {}),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Reaction Sheet with update feature
  void showReactionSheet(String postId, List currentReactions) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: ["👍", "❤️", "😆", "😢", "😡"].map((emoji) {
            return GestureDetector(
              onTap: () async {
                Navigator.pop(context);
                final currentUser = FirebaseAuth.instance.currentUser;
                if (currentUser == null) return;

                int existingIndex = currentReactions.indexWhere((r) => r['userId'] == currentUser.uid);

                if (existingIndex >= 0) {
                  currentReactions[existingIndex]['emoji'] = emoji;
                  await _firestore.collection('SocialPost').doc(postId).update({
                    "reactions": currentReactions
                  });
                } else {
                  await _firestore.collection('SocialPost').doc(postId).update({
                    "reactions": FieldValue.arrayUnion([{
                      "userId": currentUser.uid,
                      "emoji": emoji,
                      "timestamp": Timestamp.now(),
                    }])
                  });
                }
              },
              child: Text(emoji, style: const TextStyle(fontSize: 30)),
            );
          }).toList(),
        ),
      ),
    );
  }

  // Comment Dialog
  void showCommentDialog(String postId) {
    TextEditingController commentController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Add Comment"),
        content: TextField(
          controller: commentController,
          decoration: const InputDecoration(hintText: "Type your comment"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              final currentUser = FirebaseAuth.instance.currentUser;
              if (currentUser == null) return;

              String comment = commentController.text.trim();
              if (comment.isNotEmpty) {
                await _firestore.collection('SocialPost').doc(postId).update({
                  "comments": FieldValue.arrayUnion([{
                    "userId": currentUser.uid,
                    "comment": comment,
                    "timestamp": Timestamp.now(),
                  }])
                });
                Navigator.pop(context);
              }
            },
            child: const Text("Post"),
          ),
        ],
      ),
    );
  }
}
