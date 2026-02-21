import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart'; // <-- Added this import
import '../../../core/utils/receipt_parser.dart';
import '../../expenses/presentation/expense_form_screen.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  CameraController? _controller;
  bool _isProcessing = false;
  final ImagePicker _picker = ImagePicker(); // <-- Initialize the Image Picker

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    final cameras = await availableCameras();
    if (cameras.isEmpty) return;

    _controller = CameraController(
      cameras.first,
      ResolutionPreset.high,
      enableAudio: false,
    );
    await _controller!.initialize();
    if (mounted) setState(() {});
  }

  // Method 1: Capture from Live Camera
  Future<void> _captureAndProcess() async {
    if (_controller == null ||
        !_controller!.value.isInitialized ||
        _isProcessing)
      return;
    setState(() => _isProcessing = true);

    try {
      final XFile file = await _controller!.takePicture();
      await _processImage(file.path);
    } catch (e) {
      _showError(e.toString());
    }
  }

  // Method 2: Pick from Device Gallery
  Future<void> _pickFromGallery() async {
    if (_isProcessing) return;

    try {
      // Opens the native Android/iOS photo gallery
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

      if (image == null) return; // User canceled the picker

      setState(() => _isProcessing = true);
      await _processImage(image.path);
    } catch (e) {
      _showError(e.toString());
    }
  }

  // Shared logic to pass the image to Google ML Kit
  Future<void> _processImage(String path) async {
    try {
      final parsedData = await ReceiptParser.parseReceipt(path);
      parsedData['imagePath'] = path;

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ExpenseFormScreen(initialData: parsedData),
          ),
        );
      }
    } catch (e) {
      _showError(e.toString());
    }
  }

  void _showError(String error) {
    if (mounted) {
      setState(() => _isProcessing = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $error')));
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF10b77f)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // The Live Camera Feed
          SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: CameraPreview(_controller!),
          ),

          // Dark Overlay with transparent cutout for the receipt
          ColorFiltered(
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.7),
              BlendMode.srcOut,
            ),
            child: Stack(
              children: [
                Container(
                  decoration: const BoxDecoration(
                    color: Colors.transparent,
                    backgroundBlendMode: BlendMode.dstOut,
                  ),
                ),
                Center(
                  child: Container(
                    height: 500,
                    width: 320,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Scanner Frame UI
          Center(
            child: Container(
              height: 500,
              width: 320,
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFF10b77f), width: 2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: EdgeInsets.only(bottom: 16.0),
                  child: Text(
                    'Align receipt within frame',
                    style: TextStyle(
                      color: Color(0xFF10b77f),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Top Back Button
          SafeArea(
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 30),
              onPressed: () => Navigator.pop(context),
            ),
          ),

          // Bottom Controls (Gallery, Shutter, Flash)
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Column(
              children: [
                if (_isProcessing)
                  const Column(
                    children: [
                      CircularProgressIndicator(color: Color(0xFF10b77f)),
                      SizedBox(height: 16),
                      Text(
                        'AI is reading receipt...',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  )
                else
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // 1. Gallery Button
                      Column(
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.photo_library,
                              color: Colors.white,
                              size: 32,
                            ),
                            onPressed: _pickFromGallery,
                          ),
                          const Text(
                            'Gallery',
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ],
                      ),

                      // 2. Main Shutter Button
                      GestureDetector(
                        onTap: _captureAndProcess,
                        child: Container(
                          height: 80,
                          width: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFF10b77f),
                              width: 4,
                            ),
                          ),
                          child: Center(
                            child: Container(
                              height: 65,
                              width: 65,
                              decoration: const BoxDecoration(
                                color: Color(0xFF10b77f),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 30,
                              ),
                            ),
                          ),
                        ),
                      ),

                      // 3. Flash Toggle (Visual placeholder for symmetry)
                      Column(
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.flash_off,
                              color: Colors.white,
                              size: 32,
                            ),
                            onPressed: () {
                              // TODO: Implement flash toggle
                            },
                          ),
                          const Text(
                            'Flash',
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ],
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
