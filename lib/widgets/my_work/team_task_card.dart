// lib/widgets/my_work/team_task_card.dart
import 'package:flutter/material.dart';
import 'package:onboard/models/team_task_model.dart';

class TeamTaskCard extends StatelessWidget {
  final TeamTaskModel task;

  const TeamTaskCard({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                task.title,
                style: const TextStyle(
                  fontSize: 14,
                  fontFamily: 'Arimo',
                  color: Color(0xFF101828),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${task.assignedTo} • Due ${task.formattedDueDate}',
                style: const TextStyle(
                  fontSize: 12,
                  fontFamily: 'Arimo',
                  color: Color(0xFF4A5565),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}