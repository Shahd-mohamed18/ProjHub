// lib/widgets/my_work/pending_task_card.dart
import 'package:flutter/material.dart';
import 'package:onboard/models/TaskModels/task_model.dart';

class PendingTaskCard extends StatelessWidget {
  final TaskModel task;
  final VoidCallback onSubmit;

  const PendingTaskCard({
    super.key,
    required this.task,
    required this.onSubmit,
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
          BoxShadow(color: Color(0x19000000), blurRadius: 2, offset: Offset(0, 1), spreadRadius: -1),
          BoxShadow(color: Color(0x19000000), blurRadius: 3, offset: Offset(0, 1)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                task.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontFamily: 'Arimo',
                  color: Color(0xFF101828),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'From: ${task.from} • Due: ${task.formattedDueDate}',
            style: const TextStyle(
              fontSize: 14,
              fontFamily: 'Arimo',
              color: Color(0xFF4A5565),
            ),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              onPressed: onSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2196F3),
                foregroundColor: Colors.white,
                minimumSize: const Size(112, 36),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Submit Work',
                style: TextStyle(fontSize: 14, fontFamily: 'Arimo'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}