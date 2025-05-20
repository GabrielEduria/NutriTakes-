import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/image_classifier.dart'; // Your classifier import

class MainNavScreen extends StatefulWidget {
  final String email;
  final List<Map<String, dynamic>> classificationHistory;
  final List<File> pickedImages;

  final Function({
    required List<Map<String, dynamic>> updatedHistory,
    required List<File> updatedImages,
  }) onClassificationDataUpdate;

  const MainNavScreen({
    Key? key,
    required this.email,
    required this.classificationHistory,
    required this.pickedImages,
    required this.onClassificationDataUpdate,
  }) : super(key: key);

  @override
  _MainNavScreenState createState() => _MainNavScreenState();
}

class _MainNavScreenState extends State<MainNavScreen> {
  late List<Map<String, dynamic>> _classificationHistory;
  late List<File> _pickedImages;

  final ImagePicker _picker = ImagePicker();
  final ImageClassifier _classifier = ImageClassifier();
  bool _isModelLoaded = false;

  @override
  void initState() {
    super.initState();
    _classificationHistory = List.from(widget.classificationHistory);
    _pickedImages = List.from(widget.pickedImages);
    _loadModel();
  }

  Future<void> _loadModel() async {
    if (!_isModelLoaded) {
      await _classifier.loadModel();
      _isModelLoaded = true;
    }
  }

  Future<void> _showImageSourceSelector() async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take a picture'),
                onTap: () {
                  Navigator.pop(context);
                  _captureAndClassify(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Select from gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _captureAndClassify(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _captureAndClassify(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);

    if (pickedFile != null) {
      final File imageFile = File(pickedFile.path);

      try {
        final result = await _classifier.classifyImage(imageFile);

        final label = result.split(' (')[0];
        final confidenceStr = result
            .split(' (')[1]
            .replaceAll('%', '')
            .replaceAll(')', '');
        final confidence = double.tryParse(confidenceStr) ?? 0.0;

        _addClassification({'label': label, 'confidence': confidence}, imageFile);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error during classification: $e')),
        );
      }
    }
  }

  void _addClassification(Map<String, dynamic> newClassification, File newImage) {
    setState(() {
      _classificationHistory.add(newClassification);
      _pickedImages.add(newImage);
    });

    widget.onClassificationDataUpdate(
      updatedHistory: _classificationHistory,
      updatedImages: _pickedImages,
    );
  }

  @override
  void dispose() {
    _classifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Latest image + classification
    File? latestImage = _pickedImages.isNotEmpty ? _pickedImages.last : null;
    String? latestLabel = _classificationHistory.isNotEmpty
        ? _classificationHistory.last['label']
        : null;
    double? latestConfidence = _classificationHistory.isNotEmpty
        ? _classificationHistory.last['confidence']
        : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('NutriTakes'),
        centerTitle: true,
        backgroundColor: Colors.orange[600],
        foregroundColor: Colors.white,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (latestImage != null && latestLabel != null)
            Center(
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                margin: const EdgeInsets.symmetric(horizontal: 40),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.file(
                          latestImage,
                          width: 250,
                          height: 250,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        latestLabel,
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Confidence: ${latestConfidence?.toStringAsFixed(2) ?? 'N/A'}%',
                        style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
           Center(
  child: Padding(
    padding: const EdgeInsets.symmetric(horizontal: 50),
    child: Text(
      'No image classified yet.\nCapture or select an image to start.',
      textAlign: TextAlign.center,
      style: TextStyle(fontSize: 18, color: Colors.grey[600]),
    ),
  ),
),

          const SizedBox(height: 80), // spacer to push button down
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton.icon(
          onPressed: _showImageSourceSelector,
          icon: const Icon(Icons.camera_alt),
          label: const Text('Capture & Classify'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange[600],
            foregroundColor: Colors.white,
            minimumSize: const Size.fromHeight(50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }
}
