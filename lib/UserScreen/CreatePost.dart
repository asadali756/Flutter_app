import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:project/UserScreen/Camera.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

Future<String?> uploadToCloudinary(Uint8List bytes, String fileName,
    {bool isVideo = false}) async {
  String cloudName = "dlntmuhv5";
  String uploadPreset = "SocialPosts";
  String url =
      "https://api.cloudinary.com/v1_1/$cloudName/${isVideo ? 'video' : 'image'}/upload";

  var request = http.MultipartRequest("POST", Uri.parse(url));
  request.fields['upload_preset'] = uploadPreset;
  request.files.add(
      http.MultipartFile.fromBytes('file', bytes, filename: fileName));

  var response = await request.send();
  if (response.statusCode == 200) {
    var res = json.decode(await response.stream.bytesToString());
    return res['secure_url'];
  } else {
    return null;
  }
}

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({Key? key}) : super(key: key);

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final ImagePicker _picker = ImagePicker();
  List<XFile> _mediaFiles = [];
  List<Uint8List?> _mediaBytes = [];
  final TextEditingController captionCtrl = TextEditingController();
  String? userEmail;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _loadUserEmail();
  }

  Future<void> _loadUserEmail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() => userEmail = prefs.getString("email"));
  }

  Future<void> _pickMedia(ImageSource source, {bool video = false}) async {
    List<XFile> picked = [];
    if (video) {
      XFile? v = await _picker.pickVideo(source: source);
      if (v != null) picked.add(v);
    } else {
      List<XFile>? imgs = await _picker.pickMultiImage();
      if (imgs != null) picked.addAll(imgs);
    }

    if (picked.isEmpty) return;

    if (kIsWeb) {
      List<Uint8List?> bytesList = [];
      for (var f in picked) bytesList.add(await f.readAsBytes());
      setState(() {
        _mediaFiles.addAll(picked);
        _mediaBytes.addAll(bytesList);
      });
    } else {
      setState(() {
        _mediaFiles.addAll(picked);
        _mediaBytes.addAll(List.filled(picked.length, null));
      });
    }
  }

  Future<void> _savePost({bool asDraft = false}) async {
    if (_mediaFiles.isEmpty && captionCtrl.text.isEmpty) return;

    setState(() => _isUploading = true);

    List<Future<String?>> uploads = [];
    for (int i = 0; i < _mediaFiles.length; i++) {
      Uint8List bytes =
          kIsWeb ? _mediaBytes[i]! : await _mediaFiles[i].readAsBytes();
      bool isVideo = _mediaFiles[i].path.endsWith(".mp4");
      uploads.add(uploadToCloudinary(
          bytes, "post_${DateTime.now().millisecondsSinceEpoch}_$i",
          isVideo: isVideo));
    }

    List<String?> urls = await Future.wait(uploads);

    await FirebaseFirestore.instance
        .collection(asDraft ? "DraftPosts" : "SocialPost")
        .add({
      "email": userEmail,
      "caption": captionCtrl.text,
      "mediaUrls": urls.whereType<String>().toList(),
      "createdAt": FieldValue.serverTimestamp(),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content:
              Text(asDraft ? "Saved to Drafts" : "Post uploaded successfully")),
    );

    setState(() {
      _mediaFiles.clear();
      _mediaBytes.clear();
      captionCtrl.clear();
      _isUploading = false;
    });
  }

  Widget _mediaPreview() {
    if (_mediaFiles.isEmpty) {
      return Container(
        height: 150,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade400),
        ),
        child: const Center(
            child: Text("No media selected",
                style: TextStyle(color: Colors.grey))),
      );
    }

    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _mediaFiles.length,
        itemBuilder: (context, index) {
          bool isVideo = _mediaFiles[index].path.endsWith(".mp4");
          return Stack(
            children: [
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 6),
                width: 100,
                height: 120,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: kIsWeb
                      ? Image.memory(_mediaBytes[index]!, fit: BoxFit.cover)
                      : Image.file(File(_mediaFiles[index].path),
                          fit: BoxFit.cover),
                ),
              ),
              if (isVideo)
                const Positioned(
                    top: 4,
                    right: 4,
                    child: Icon(Icons.videocam, color: Colors.white)),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green.shade800,
        title: const Text("Create Post", style: TextStyle(color: Colors.white)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _mediaPreview(),
            const SizedBox(height: 16),
            TextField(
              controller: captionCtrl,
              maxLines: 3,
              decoration: InputDecoration(
                  hintText: "Share your thoughts...",
                  prefixIcon: const Icon(Icons.edit),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12))),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
              IconButton(
  onPressed: () async {
    // Pass current context safely
    final result = await Navigator.of(context).push<Map<String, dynamic>>(
      MaterialPageRoute(builder: (_) => const CameraCaptureScreen()),
    );

    if (result != null && mounted) {
      XFile file = result["file"];
      String caption = result["caption"] ?? "";
      Uint8List? bytes;
      if (kIsWeb) bytes = await file.readAsBytes();

      setState(() {
        _mediaFiles.add(file);
        _mediaBytes.add(bytes);
        if (caption.isNotEmpty) captionCtrl.text = caption;
      });
    }
  },
  icon: const Icon(Icons.camera_alt),
  color: Colors.green.shade800,
),


                IconButton(
                  onPressed: () => _pickMedia(ImageSource.gallery),
                  icon: const Icon(Icons.photo),
                  color: Colors.blue.shade700,
                ),
                IconButton(
                  onPressed: () => _pickMedia(ImageSource.camera, video: true),
                  icon: const Icon(Icons.videocam),
                  color: Colors.orange.shade700,
                ),
                IconButton(
                  onPressed: () => _pickMedia(ImageSource.gallery, video: true),
                  icon: const Icon(Icons.video_library),
                  color: Colors.purple.shade700,
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isUploading ? null : () => _savePost(),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade800,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12))),
                    child: _isUploading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text("Post" , style: TextStyle(color: Colors.white),),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isUploading ? null : () => _savePost(asDraft: true),
                    style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.green.shade800),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12))),
                    child: _isUploading
                        ? const CircularProgressIndicator()
                        : const Text("Draft" , style: TextStyle(color: Colors.black)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
