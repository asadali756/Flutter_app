import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

class CameraCaptureScreen extends StatefulWidget {
  const CameraCaptureScreen({super.key});

  @override
  State<CameraCaptureScreen> createState() => _CameraCaptureScreenState();
}

class _CameraCaptureScreenState extends State<CameraCaptureScreen> {
  CameraController? _controller;
  Future<void>? _initializeControllerFuture;
  XFile? _capturedFile;
  Uint8List? _capturedBytes; // For web
  final TextEditingController _captionCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    final cameras = await availableCameras();
    final firstCamera = cameras.first;

    _controller = CameraController(firstCamera, ResolutionPreset.medium);
    _initializeControllerFuture = _controller!.initialize();
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller?.dispose();
    _captionCtrl.dispose();
    super.dispose();
  }

  Future<void> _takePicture() async {
    if (_controller == null) return;
    await _initializeControllerFuture;

    final image = await _controller!.takePicture();

    if (kIsWeb) {
      final bytes = await image.readAsBytes();
      setState(() {
        _capturedFile = image;
        _capturedBytes = bytes;
      });
    } else {
      setState(() => _capturedFile = image);
    }
  }

  void _usePhoto() {
    if (_capturedFile != null) {
      Navigator.of(context).pop({
        "file": _capturedFile,
        "bytes": _capturedBytes,
        "caption": _captionCtrl.text,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor:Colors.white,
        elevation: 0,
        title: const Text("Capture Post"),
      ),
      body: Column(
        children: [
          Expanded(
            child: _controller == null
                ? const Center(child: CircularProgressIndicator())
                : FutureBuilder(
                    future: _initializeControllerFuture,
                    builder: (_, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        return Stack(
                          children: [
                            CameraPreview(_controller!),
                            if (_capturedFile != null)
                              Container(
                                color: Colors.black54,
                                child: Center(
                                  child: kIsWeb && _capturedBytes != null
                                      ? Image.memory(_capturedBytes!,
                                          fit: BoxFit.contain)
                                      : Image.file(File(_capturedFile!.path),
                                          fit: BoxFit.contain),
                                ),
                              ),
                          ],
                        );
                      }
                      return const Center(child: CircularProgressIndicator());
                    },
                  ),
          ),
          if (_capturedFile != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _captionCtrl,
                decoration: InputDecoration(
                  hintText: "Add a caption...",
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton.icon(
                  onPressed: _takePicture,
                  icon: const Icon(Icons.camera_alt ,color: Colors.white),
                  label: const Text("Capture"  , style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade700,
                  ),
                ),
                if (_capturedFile != null)
                  ElevatedButton.icon(
                    onPressed: _usePhoto,
                    icon: const Icon(Icons.check ,color: Colors.white),
                    label: const Text("Use Photo"  , style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade700,
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
