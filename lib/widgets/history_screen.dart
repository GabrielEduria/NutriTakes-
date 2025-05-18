import 'package:flutter/material.dart';
import '../widgets/classification_history_card.dart';
import 'dart:io';

class HistoryScreen extends StatelessWidget {
  final List<Map<String, dynamic>> history;

  const HistoryScreen({super.key, required this.history});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Classification History'),
        backgroundColor: Colors.blue[900],
      ),
      body: history.isEmpty
          ? const Center(
              child: Text('No classification history found.'),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: history.length,
              itemBuilder: (context, index) {
                final item = history[index];
                final File imageFile = item['image'] as File;
                final String result = item['result'] as String;

                return ClassificationHistoryCard(
                  imageFile: imageFile,
                  result: result,
                  index: index,
                  onTap: () {
                    // You can add more detailed view or actions here
                  },
                );
              },
            ),
    );
  }
}
