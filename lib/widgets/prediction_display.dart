import 'package:flutter/material.dart';

class PredictionDisplay extends StatelessWidget {
  final String label;
  final double confidence;
  final Color color;

  const PredictionDisplay({
    super.key,
    required this.label,
    required this.confidence,
    this.color = Colors.blue,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: confidence,
              backgroundColor: Colors.grey[200],
              color: color,
            ),
            const SizedBox(height: 8),
            Text(
              '${(confidence * 100).toStringAsFixed(1)}% confident',
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
