import 'dart:io';

class ClassificationStorage {
  static final ClassificationStorage _instance = ClassificationStorage._internal();

  factory ClassificationStorage() => _instance;

  ClassificationStorage._internal();

  List<Map<String, dynamic>> classificationHistory = [];
  List<File> pickedImages = [];

  void clear() {
    classificationHistory.clear();
    pickedImages.clear();
  }
}
