import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/image_classifier.dart';

class ImageClassificationScreen extends StatefulWidget {
  final void Function(String result) onClassification;

  const ImageClassificationScreen({Key? key, required this.onClassification}) : super(key: key);

  @override
  State<ImageClassificationScreen> createState() => _ImageClassificationScreenState();
}

class _ImageClassificationScreenState extends State<ImageClassificationScreen> {
  final ImageClassifier _classifier = ImageClassifier();
  File? _imageFile;

  @override
  void initState() {
    super.initState();
    _classifier.loadModel();
  }

  Future<void> _pickImage(bool fromCamera) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: fromCamera ? ImageSource.camera : ImageSource.gallery,
    );

    if (pickedFile != null) {
      final file = File(pickedFile.path);
      final result = await _classifier.classifyImage(file);
      setState(() {
        _imageFile = file;
      });
      widget.onClassification(result);
    }
  }

  @override
  void dispose() {
    _classifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Image Classification')),
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _imageFile != null
                ? Image.file(_imageFile!, height: 200)
                : const Icon(Icons.image, size: 100, color: Colors.white24),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => _pickImage(true),
              icon: const Icon(Icons.camera_alt),
              label: const Text("Take Picture"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.black,
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: () => _pickImage(false),
              icon: const Icon(Icons.photo_library),
              label: const Text("Pick from Gallery"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
