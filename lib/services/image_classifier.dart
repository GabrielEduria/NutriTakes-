import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;
import 'package:camera/camera.dart'; // changes
//changes
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
  // below is the changes
  Future<String> classifyCameraImage(CameraImage cameraImage) async {
  if (!_isInitialized) throw Exception("Model not loaded");

  final img.Image image = _convertYUV420toImage(cameraImage);
  final resizedImage = img.copyResize(image, width: 224, height: 224);
  final input = _prepareInput(resizedImage);
  final output = _runInference(input);
  return _processOutput(output);
}

img.Image _convertYUV420toImage(CameraImage image) {
  final width = image.width;
  final height = image.height;
  final img.Image imgBuffer = img.Image(width: width, height: height);

  final uvRowStride = image.planes[1].bytesPerRow;
  final uvPixelStride = image.planes[1].bytesPerPixel!;

  for (int y = 0; y < height; y++) {
    for (int x = 0; x < width; x++) {
      final uvIndex = uvPixelStride * (x ~/ 2) + uvRowStride * (y ~/ 2);
      final u = image.planes[1].bytes[uvIndex];
      final v = image.planes[2].bytes[uvIndex];
      final yVal = image.planes[0].bytes[y * width + x];

      final r = (yVal + (1.370705 * (v - 128))).clamp(0, 255).toInt();
      final g = (yVal - (0.337633 * (u - 128)) - (0.698001 * (v - 128))).clamp(0, 255).toInt();
      final b = (yVal + (1.732446 * (u - 128))).clamp(0, 255).toInt();

      imgBuffer.setPixel(x, y, img.ColorRgb8(r, g, b));



    }
  }

  return imgBuffer;
}
// up is te changes ------------------------------------------------------------------------------------------------
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
