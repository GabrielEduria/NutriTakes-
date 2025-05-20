import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;

class ImageClassifier {
  late Interpreter _interpreter;
  late List<String> _labels;
  bool _isInitialized = false;

  Future<void> loadModel() async {
    try {
      // Load model with basic options
      _interpreter = await Interpreter.fromAsset(
        'assets/models/model_unquant.tflite',
        options: InterpreterOptions()..threads = 4, // Removed GPU delegate
      );

      // Load labels
      _labels =
          (await rootBundle.loadString(
            'assets/models/labels.txt',
          )).split('\n').where((label) => label.trim().isNotEmpty).toList();

      _isInitialized = true;
    } catch (e) {
      _isInitialized = false;
      throw Exception('Failed to load model: $e');
    }
  }

  Future<String> classifyImage(File image) async {
    if (!_isInitialized) {
      throw Exception('Classifier not initialized. Call loadModel() first.');
    }

    try {
      // 1. Preprocess image
      final imageBytes = await image.readAsBytes();
      final decodedImage = img.decodeImage(imageBytes);
      if (decodedImage == null) throw Exception('Failed to decode image');

      final resizedImage = img.copyResize(
        decodedImage,
        width: 224,
        height: 224,
      );

      // 2. Prepare input tensor
      final input = _prepareInput(resizedImage);

      // 3. Run inference
      final output = _runInference(input);

      // 4. Process results
      return _processOutput(output);
    } catch (e) {
      throw Exception('Classification failed: $e');
    }
  }

  Float32List _prepareInput(img.Image image) {
    const inputSize = 224;
    const mean = 127.5;
    const std = 127.5;

    final inputBuffer = Float32List(inputSize * inputSize * 3);
    var bufferIndex = 0;

    for (var y = 0; y < inputSize; y++) {
      for (var x = 0; x < inputSize; x++) {
        final pixel = image.getPixel(x, y);
        inputBuffer[bufferIndex++] = (pixel.r - mean) / std;
        inputBuffer[bufferIndex++] = (pixel.g - mean) / std;
        inputBuffer[bufferIndex++] = (pixel.b - mean) / std;
      }
    }
    return inputBuffer;
  }

  List<dynamic> _runInference(Float32List input) {
    final outputShape = _interpreter.getOutputTensor(0).shape;
    final output = List.filled(
      outputShape.reduce((a, b) => a * b),
      0.0,
    ).reshape(outputShape);

    _interpreter.run(input.reshape([1, 224, 224, 3]), output);
    return output;
  }

  String _processOutput(List<dynamic> output) {
    final probabilities = output[0].cast<double>();
    double maxScore = 0;
    int maxIndex = 0;
    for (int i = 0; i < probabilities.length; i++) {
      if (probabilities[i] > maxScore) {
        maxScore = probabilities[i];
        maxIndex = i;
      }
    }

    final confidence = (maxScore * 100).toStringAsFixed(1);
    return '${_labels[maxIndex]} ($confidence%)';
  }

  void dispose() {
    _interpreter.close();
    _isInitialized = false;
  }
}
