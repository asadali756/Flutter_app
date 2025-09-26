import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

class CameraUser extends StatefulWidget {
  const CameraUser({super.key});

  @override
  State<CameraUser> createState() => _CameraUserState();
}

class _CameraUserState extends State<CameraUser> {
  CameraController? _controller;
  Future<void>? _initializeControllerFuture;
  XFile? _capturedFile;
  Uint8List? _capturedBytes;
  List<CameraDescription> cameras = [];
  int selectedCameraIndex = 0;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      cameras = await availableCameras();
      if (cameras.isEmpty) {
        debugPrint("No cameras available.");
        return;
      }

      // Default to back camera if exists, else first camera
      selectedCameraIndex = cameras.indexWhere(
          (cam) => cam.lensDirection == CameraLensDirection.back);
      if (selectedCameraIndex == -1) selectedCameraIndex = 0;

      _controller = CameraController(
        cameras[selectedCameraIndex],
        ResolutionPreset.max,
        enableAudio: false,
      );

      _initializeControllerFuture = _controller!.initialize();
      if (mounted) setState(() {});
    } catch (e) {
      debugPrint('Error initializing camera: $e');
    }
  }

  void _switchCamera() async {
    if (cameras.length < 2) return; // Disable if only one camera

    selectedCameraIndex = (selectedCameraIndex + 1) % cameras.length;
    await _controller?.dispose();

    _controller = CameraController(
      cameras[selectedCameraIndex],
      ResolutionPreset.max,
      enableAudio: false,
    );
    _initializeControllerFuture = _controller!.initialize();
    setState(() {});
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _takePicture() async {
    if (_controller == null || !_controller!.value.isInitialized) return;
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
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: _controller == null
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                // Fullscreen camera preview
                Positioned.fill(
                  child: FutureBuilder(
                    future: _initializeControllerFuture,
                    builder: (_, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        return CameraPreview(_controller!);
                      }
                      return const Center(child: CircularProgressIndicator());
                    },
                  ),
                ),

                // Top bar with back and switch camera
                Positioned(
                  top: 40,
                  left: 16,
                  right: 16,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Back button
                      CircleAvatar(
                        backgroundColor: Colors.black45,
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),

                      // Switch camera button (always visible)
                      CircleAvatar(
                        backgroundColor: Colors.black45,
                        child: IconButton(
                          icon: const Icon(
                            Icons.flip_camera_ios,
                            color: Colors.white,
                            size: 28,
                          ),
                          onPressed: cameras.length > 1 ? _switchCamera : null, // disabled if only one camera
                        ),
                      ),
                    ],
                  ),
                ),

                // Bottom controls
                Positioned(
                  bottom: 40,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Capture button
                      InkWell(
                        onTap: _takePicture,
                        child: Container(
                          height: 70,
                          width: 70,
                          decoration: BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 4),
                          ),
                          child: const Icon(Icons.camera_alt,
                              color: Colors.white, size: 36),
                        ),
                      ),

                      const SizedBox(width: 20),

                      // Use photo button
                      if (_capturedFile != null)
                        InkWell(
                          onTap: _usePhoto,
                          child: Container(
                            height: 70,
                            width: 70,
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 4),
                            ),
                            child: const Icon(Icons.check,
                                color: Colors.white, size: 36),
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
