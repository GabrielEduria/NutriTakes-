import 'dart:io';
import 'package:flutter/material.dart';
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

  @override
  Widget build(BuildContext context) {
    final classificationHistory = storage.classificationHistory;
    final pickedImages = storage.pickedImages;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        title: Text('Profile', style: const TextStyle(color: Colors.black)),
        actions: [
          TextButton.icon(
            onPressed: () async {
              await _authService.signOut();
            },
            icon: const Icon(Icons.logout, color: Colors.black),
            label: const Text('Sign Out', style: TextStyle(color: Colors.black)),
            style: TextButton.styleFrom(
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 12),
            ),
          ),
        ],
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.only(bottom: 8),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.grey, width: 1),
                ),
              ),
              child: Text(
                'Welcome, ${widget.email}',
                style: const TextStyle(color: Colors.black, fontSize: 18),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Classification History',
              style: TextStyle(
                color: Colors.orange,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: classificationHistory.isEmpty
                  ? const Center(
                      child: Text(
                        'No history yet.',
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      itemCount: classificationHistory.length,
                      itemBuilder: (context, index) {
                        final item = classificationHistory[index];
                        final imageFile = (index < pickedImages.length) ? pickedImages[index] : null;

                        if (imageFile == null) {
                          return const SizedBox.shrink();
                        }

                        return ClassificationHistoryCard(
                          imageFile: imageFile,
                          result: item['label'] ?? 'Unknown',
                          index: index,
                          onDelete: () {
                            // Example: Remove item from storage and refresh UI
                            setState(() {
                              storage.classificationHistory.removeAt(index);
                              storage.pickedImages.removeAt(index);
                            });
                          },
                          onTap: () {
                            // Optional: show details or enlarge image
                          },
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
