import 'dart:io';
import 'package:flutter/material.dart';

class ClassificationHistoryCard extends StatelessWidget {
  final File imageFile;
  final String result;
  final int index;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final VoidCallback? onFeedback; // Add this at the top with the other fields
  const ClassificationHistoryCard({
    Key? key,
    required this.imageFile,
    required this.result,
    required this.index,
    this.onTap,
    this.onDelete,
    this.onFeedback,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(
                  imageFile,
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                result,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                'Captured image #${index + 1}',
                style: TextStyle(fontSize: 13, color: Colors.grey[600]),
              ),
              const SizedBox(height: 10),
             Row(
  mainAxisAlignment: MainAxisAlignment.center,
  children: [
    IconButton(
      icon: const Icon(Icons.delete_outline, color: Colors.red),
      onPressed: onDelete,
      tooltip: 'Delete',
    ),
    const SizedBox(width: 16),
    if (onFeedback != null) 
      IconButton(
        icon: const Icon(Icons.feedback_outlined, color: Colors.orange),
        onPressed: onFeedback,
        tooltip: 'Submit Feedback',
      ),
  ],
),


            ],
          ),
        ),
      ),
    );
  }
}
