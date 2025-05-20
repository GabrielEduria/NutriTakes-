import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // <-- Added for Firestore
import '../services/auth_service.dart';
import '../widgets/classification_history_card.dart';
import '../utils/classification_storage.dart';

class ProfileScreen extends StatefulWidget {
  final String email;
  final List<Map<String, dynamic>> classificationHistory;
  final List<File> pickedImages;

  const ProfileScreen({
    Key? key,
    required this.email,
    required this.classificationHistory,
    required this.pickedImages,
  }) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final storage = ClassificationStorage();
  final AuthService _authService = AuthService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance; // Firestore instance

  File? _profileImage;

  Future<void> _changeProfileImage() async {
    // TODO: implement image picker logic here, for example using image_picker package
    // After picking, call setState to update _profileImage
  }

  void _showFeedbackDialog(BuildContext context, String predictedLabel) {
    final TextEditingController _feedbackController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Submit Feedback'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Predicted Label: $predictedLabel'),
              const SizedBox(height: 8),
              TextField(
                controller: _feedbackController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Your feedback',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              child: const Text('Submit'),
              onPressed: () async {
                String feedback = _feedbackController.text.trim();

                if (feedback.isNotEmpty) {
                  try {
                    await _firestore.collection('feedback').add({
                      'userEmail': widget.email,
                      'predictedLabel': predictedLabel,
                      'feedback': feedback,
                      'timestamp': FieldValue.serverTimestamp(),
                    });

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Feedback submitted successfully!')),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error submitting feedback: $e')),
                    );
                  }
                }

                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final classificationHistory = storage.classificationHistory;
    final pickedImages = storage.pickedImages;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Orange header with 'Profile' text
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 24),
            color: Colors.orange,
            child: const Center(
              child: Text(
                'Profile',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                ),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Profile info section with bottom border
                  Container(
                    padding: const EdgeInsets.only(bottom: 16),
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: Colors.black,
                          width: 1,
                        ),
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircleAvatar(
                          radius: 30, // smaller avatar
                          backgroundColor: Colors.grey,
                          child: Icon(Icons.person, size: 24, color: Colors.white),
                        ),
                        const SizedBox(height: 6),

                        // Email
                        Text(
                          widget.email,
                          style: const TextStyle(fontSize: 16),
                        ),

                        const SizedBox(height: 10),

                        // Sign out button
                        ElevatedButton.icon(
                          onPressed: () async {
                            await _authService.signOut();
                          },
                          icon: const Icon(Icons.logout),
                          label: const Text("Sign Out"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Classification History Header
                  const Text(
                    'Classification History',
                    style: TextStyle(
                      color: Colors.orange,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // History List
                  Expanded(
                    child: widget.classificationHistory.isEmpty
                        ? const Center(
                            child: Text(
                              'No history yet.',
                              style: TextStyle(color: Colors.grey),
                            ),
                          )
                        : ListView.builder(
                            itemCount: widget.classificationHistory.length,
                            itemBuilder: (context, index) {
                              final item = widget.classificationHistory[index];
                              final imageFile = index < widget.pickedImages.length
                                  ? widget.pickedImages[index]
                                  : null;

                              if (imageFile == null) return const SizedBox.shrink();

                              return ClassificationHistoryCard(
                                imageFile: imageFile,
                                result: item['label'] ?? 'Unknown',
                                index: index,
                                onDelete: () {
                                  setState(() {
                                    widget.classificationHistory.removeAt(index);
                                    widget.pickedImages.removeAt(index);
                                  });
                                },
                                onTap: () {},
                                onFeedback: () {
                                  _showFeedbackDialog(context, item['label'] ?? 'Unknown');
                                },
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
