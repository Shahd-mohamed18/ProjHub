// lib/widgets/feedback/feedback_card.dart
import 'package:flutter/material.dart';
import 'package:onboard/models/TaskModels/feedback_model.dart';

class FeedbackCard extends StatelessWidget {
  final FeedbackModel feedback;

  const FeedbackCard({super.key, required this.feedback});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          side: const BorderSide(width: 1.27, color: Color(0xFFE5E7EB)),
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${feedback.from} Feedback',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF101828),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            feedback.message,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF364153),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            feedback.formattedDate,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF6A7282),
            ),
          ),
        ],
      ),
    );
  }
}