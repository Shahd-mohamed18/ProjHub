// lib/widgets/my_work/completed_task_card.dart
import 'package:flutter/material.dart';
import 'package:onboard/models/completed_task_model.dart';
import 'package:onboard/models/feedback_model.dart'; 
import 'package:onboard/screens/TasksScreen/feedback_screen.dart'; 

class CompletedTaskCard extends StatelessWidget {
  final CompletedTaskModel task;
  final VoidCallback? onViewFeedback; 

  const CompletedTaskCard({
    super.key,
    required this.task,
    this.onViewFeedback, 
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
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: const BoxDecoration(
                  color: Color(0xFF4CAF50),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 14),
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
              onPressed: () {
              
                if (onViewFeedback != null) {
                  onViewFeedback!();
                } else {
                  // ✅ التنقل المباشر لصفحة الفيدباك
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => FeedbackScreen(
                        taskId: task.id,
                        taskTitle: task.title,
                        feedbacks: FeedbackModel.mockFeedbacks
                            .where((f) => f.taskId == task.id)
                            .toList(),
                      ),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF3F4F6),
                foregroundColor: const Color(0xFF364153),
                minimumSize: const Size(124, 36),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
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