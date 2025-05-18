import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/image_classifier.dart'; // Import your classifier

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
        final confidenceStr = result.split(' (')[1].replaceAll('%', '').replaceAll(')', '');
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('NutriTakes'),
        centerTitle: true,
        backgroundColor: Colors.orange[600],
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton.icon(
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
            const SizedBox(height: 20),
            Expanded(
              child: _classificationHistory.isEmpty
                  ? Center(
                      child: Text(
                        'No classifications yet.\nStart by capturing an image.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey[600], fontSize: 16),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _classificationHistory.length,
                      itemBuilder: (context, index) {
                        final classification = _classificationHistory[index];
                        final imageFile = (index < _pickedImages.length) ? _pickedImages[index] : null;

                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 4,
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(12),
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: imageFile != null && imageFile.existsSync()
                                  ? Image.file(imageFile, width: 60, height: 60, fit: BoxFit.cover)
                                  : Container(
                                      width: 60,
                                      height: 60,
                                      color: Colors.grey[300],
                                      child: const Icon(Icons.image_not_supported),
                                    ),
                            ),
                            title: Text(
                              classification['label'] ?? 'Unknown',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              'Confidence: ${(classification['confidence'] ?? 'N/A').toString()}%',
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
