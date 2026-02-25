// lib/widgets/tasks/my_work/completed_task_card.dart
import 'package:flutter/material.dart';
import 'package:onboard/models/TaskModels/completed_task_model.dart';

// ✅ الـ Widget مش بيعمل Navigator.push لوحده
// الـ Screen هي اللي بتقرر تروح فين
class CompletedTaskCard extends StatelessWidget {
  final CompletedTaskModel task;
  final VoidCallback onViewFeedback;

  const CompletedTaskCard({
    super.key,
    required this.task,
    required this.onViewFeedback,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          side: const BorderSide(width: 1.27, color: Color(0xFFE5E7EB)),
          borderRadius: BorderRadius.circular(10),
        ),
        shadows: const [
          BoxShadow(
            color: Color(0x19000000),
            blurRadius: 2,
            offset: Offset(0, 1),
            spreadRadius: -1,
          ),
          BoxShadow(
            color: Color(0x19000000),
            blurRadius: 3,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 10,
                backgroundColor: Color(0xFF4CAF50),
                child: Icon(Icons.check, color: Colors.white, size: 12),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  task.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontFamily: 'Arimo',
                    color: Color(0xFF101828),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 28),
            child: Text(
              'Completed: ${task.formattedCompletedDate} • ${task.status}',
              style: const TextStyle(
                fontSize: 14,
                fontFamily: 'Arimo',
                color: Color(0xFF4A5565),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              onPressed: onViewFeedback, // ✅ الـ Screen هي اللي بتحدد إيه اللي يحصل
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF3F4F6),
                foregroundColor: const Color(0xFF364153),
                minimumSize: const Size(124, 36),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'View Feedback',
                style: TextStyle(fontSize: 14, fontFamily: 'Arimo'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}