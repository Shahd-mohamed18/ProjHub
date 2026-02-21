// lib/widgets/tasks/task_card.dart
import 'package:flutter/material.dart';
import 'package:onboard/models/task_model.dart';
import 'package:onboard/screens/task_details_screen.dart';

class TaskCard extends StatelessWidget {
  final TaskModel task;
  final VoidCallback? onTap;
  final VoidCallback? onIconTap;

  const TaskCard({
    super.key,
    required this.task,
    this.onTap,
    this.onIconTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 329,
        height: 92,
        margin: const EdgeInsets.symmetric(horizontal: 30),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            // الأيقونة (هتحطي الصورة هنا بعدين)
            GestureDetector(
              onTap: onIconTap,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                 child: Image.asset(
                  'assets/images/Frame (4).png', // ضعي المسار الصحيح لصورتك
                  fit: BoxFit.contain,
                ),
              
              ),
            ),
            const SizedBox(width: 12),
            
            
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF101828),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'From: ${task.from} • Due: ${task.formattedDueDate}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}