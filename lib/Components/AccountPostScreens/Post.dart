import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Post extends StatefulWidget {
  const Post({Key? key}) : super(key: key);

  @override
  _PostState createState() => _PostState();
}

class _PostState extends State<Post> {
  String? userEmail;
  List<QueryDocumentSnapshot> posts = [];

  @override
  void initState() {
    super.initState();
    _loadUserEmail();
  }

  Future<void> _loadUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userEmail = prefs.getString('email');
    });

    if (userEmail != null) {
      _loadPosts();
    }
  }

  Future<void> _loadPosts() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('SocialPost')
        .where('email', isEqualTo: userEmail)
        .get();

    setState(() {
      posts = snapshot.docs;
    });
  }

  Future<void> _deletePost(String docId) async {
    await FirebaseFirestore.instance
        .collection('SocialPost')
        .doc(docId)
        .delete();
    _loadPosts(); // Refresh posts
  }

  Future<void> _editPost(String docId, String currentCaption) async {
    TextEditingController controller = TextEditingController(text: currentCaption);

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Edit Post"),
          content: TextField(
            controller: controller,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: "Caption",
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text("Cancel")),
            ElevatedButton(
                onPressed: () async {
                  await FirebaseFirestore.instance
                      .collection('SocialPost')
                      .doc(docId)
                      .update({'caption': controller.text});
                  Navigator.pop(context);
                  _loadPosts(); // Refresh posts
                },
                child: const Text("Save")),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Posts"),
        backgroundColor: Colors.green,
      ),
      body: posts.isEmpty
          ? const Center(child: Text("No posts found"))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: posts.length,
              itemBuilder: (context, index) {
                final post = posts[index];
                final caption = post['caption'] ?? '';
                final createdAt = post['createdAt'] != null
                    ? (post['createdAt'] as Timestamp).toDate().toString()
                    : '';
                final mediaUrls = List<String>.from(post['mediaUrls'] ?? []);

                return Card(
                  elevation: 3,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          caption,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          createdAt,
                          style: const TextStyle(
                              fontSize: 12, color: Colors.grey),
                        ),
                        const SizedBox(height: 8),
                        if (mediaUrls.isNotEmpty)
                          SizedBox(
                            height: 200,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: mediaUrls.length,
                              itemBuilder: (context, i) {
                                return Padding(
                                  padding: const EdgeInsets.only(right: 8.0),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.network(
                                      mediaUrls[i],
                                      fit: BoxFit.cover,
                                      width: 200,
                                      height: 200,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        const SizedBox(height: 8),

                        // Edit & Delete Buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton.icon(
                              onPressed: () => _editPost(post.id, caption),
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              label: const Text("Edit",
                                  style: TextStyle(color: Colors.blue)),
                            ),
                            const SizedBox(width: 8),
                            TextButton.icon(
                              onPressed: () => _deletePost(post.id),
                              icon: const Icon(Icons.delete, color: Colors.red),
                              label: const Text("Delete",
                                  style: TextStyle(color: Colors.red)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
