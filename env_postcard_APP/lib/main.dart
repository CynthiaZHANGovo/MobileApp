import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:intl/intl.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  CameraDescription? firstCamera;
  try {
    final cameras = await availableCameras();
    if (cameras.isNotEmpty) {
      firstCamera = cameras.first;
    }
  } catch (e) {
    debugPrint("Camera initialization error: $e");
  }

  runApp(MaterialApp(
    title: 'AI Postcard',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      useMaterial3: true,
      colorSchemeSeed: Colors.indigo,
      brightness: Brightness.light,
      fontFamily: 'Roboto',
    ),
    home: SplashScreen(camera: firstCamera),
  ));
}

// 1. Splash Screen with Animations (Simulated)
class SplashScreen extends StatefulWidget {
  final CameraDescription? camera;
  const SplashScreen({super.key, this.camera});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToHome();
  }

  _navigateToHome() async {
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => MainPage(camera: widget.camera),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.indigo, Colors.blueAccent],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.auto_awesome, size: 80, color: Colors.white),
            const SizedBox(height: 24),
            const Text(
              "AI POSTCARD",
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: 4,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "Transform moments into messages",
              style: TextStyle(fontSize: 16, color: Colors.white.withOpacity(0.8)),
            ),
          ],
        ),
      ),
    );
  }
}

// 2. Main Page with Permission Handling & Enhanced UI
class MainPage extends StatefulWidget {
  final CameraDescription? camera;
  const MainPage({super.key, this.camera});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  CameraController? _controller;
  Future<void>? _initializeControllerFuture;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.camera,
      Permission.storage,
      Permission.photos,
    ].request();
    
    if (statuses[Permission.camera]!.isGranted && widget.camera != null) {
      _controller = CameraController(widget.camera!, ResolutionPreset.high);
      _initializeControllerFuture = _controller!.initialize();
      if (mounted) setState(() {});
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  // 3. Simulated API Logic
  Future<String> _simulateAnalyzeImage(String path) async {
    debugPrint("Analyzing image at: $path");
    await Future.delayed(const Duration(seconds: 2));
    final scenes = ["a quiet mountain lake", "a bustling city street", "a golden sunset", "a cozy cafe"];
    return scenes[path.length % scenes.length]; // Deterministic mock
  }

  // 4. Simulated LLM Logic
  Future<String> _simulateGenerateMessage(String scene) async {
    debugPrint("Generating message for scene: $scene");
    await Future.delayed(const Duration(seconds: 2));
    return "Greetings from this beautiful place! I'm currently looking at $scene. The atmosphere here is absolutely magical. It reminded me of you, so I thought I'd send this little note. Hope you're doing wonderful!";
  }

  Future<void> _processImage(String path) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 20),
            const Text("AI is crafting your postcard..."),
          ],
        ),
      ),
    );

    try {
      final scene = await _simulateAnalyzeImage(path);
      final message = await _simulateGenerateMessage(scene);

      if (!mounted) return;
      Navigator.pop(context); // Remove dialog

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PostcardPage(imagePath: path, initialText: message),
        ),
      );
    } catch (e) {
      if (mounted) Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera Preview
          if (_controller != null)
            FutureBuilder<void>(
              future: _initializeControllerFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return Center(child: CameraPreview(_controller!));
                } else {
                  return const Center(child: CircularProgressIndicator(color: Colors.white));
                }
              },
            )
          else
            const Center(
              child: Text(
                "Camera not available\nPlease use the gallery",
                style: TextStyle(color: Colors.white),
                textAlign: TextAlign.center,
              ),
            ),

          // Top Bar
          Positioned(
            top: 50,
            left: 20,
            child: const Text(
              "CAPTURE",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20, letterSpacing: 2),
            ),
          ),

          // Bottom Controls
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Gallery Button
                IconButton(
                  icon: const Icon(Icons.photo_library, color: Colors.white, size: 30),
                  onPressed: () async {
                    final image = await _picker.pickImage(source: ImageSource.gallery);
                    if (image != null) _processImage(image.path);
                  },
                ),
                // Shutter Button
                GestureDetector(
                  onTap: () async {
                    if (_controller != null && _controller!.value.isInitialized) {
                      final image = await _controller!.takePicture();
                      _processImage(image.path);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 4),
                    ),
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
                // Dummy switch button
                const Icon(Icons.flip_camera_ios, color: Colors.white, size: 30),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// 5. Enhanced Postcard Page with Editing & Sharing
class PostcardPage extends StatefulWidget {
  final String imagePath;
  final String initialText;

  const PostcardPage({super.key, required this.imagePath, required this.initialText});

  @override
  State<PostcardPage> createState() => _PostcardPageState();
}

class _PostcardPageState extends State<PostcardPage> {
  late TextEditingController _textController;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.initialText);
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5DC), // Vintage paper color
      appBar: AppBar(
        title: const Text("Postcard Preview"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              Share.shareXFiles([XFile(widget.imagePath)], text: _textController.text);
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              // The Postcard Content
              Card(
                elevation: 10,
                shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Top Photo Section
                    Stack(
                      children: [
                        Image.file(File(widget.imagePath), fit: BoxFit.cover),
                        Positioned(
                          top: 10,
                          right: 10,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.8),
                              border: Border.all(color: Colors.grey),
                            ),
                            child: const Icon(Icons.location_on, size: 16),
                          ),
                        ),
                      ],
                    ),
                    
                    // Bottom Writing Section
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("MESSAGE", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                              IconButton(
                                icon: Icon(_isEditing ? Icons.check : Icons.edit, size: 18),
                                onPressed: () => setState(() => _isEditing = !_isEditing),
                              ),
                            ],
                          ),
                          const Divider(),
                          _isEditing
                              ? TextField(
                                  controller: _textController,
                                  maxLines: null,
                                  decoration: const InputDecoration(border: OutlineInputBorder()),
                                  style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
                                )
                              : Text(
                                  _textController.text,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontStyle: FontStyle.italic,
                                    fontFamily: 'Serif',
                                    height: 1.6,
                                  ),
                                  textAlign: TextAlign.start,
                                ),
                          const SizedBox(height: 30),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    DateFormat('MMMM dd, yyyy').format(DateTime.now()),
                                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text("Sent via AI Postcard", style: TextStyle(color: Colors.indigo, fontSize: 10, fontWeight: FontWeight.bold)),
                                ],
                              ),
                              const SizedBox(width: 10),
                              // Mock Stamp
                              Container(
                                width: 50,
                                height: 60,
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.brown, width: 2),
                                  color: Colors.orange.withOpacity(0.1),
                                ),
                                child: const Center(child: Icon(Icons.public, color: Colors.brown)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.camera),
                label: const Text("Create New Memory"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
