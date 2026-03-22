// lib/widgets/supervisor/task_type_selector.dart
import 'package:flutter/material.dart';

class TaskTypeSelector extends StatelessWidget {
  final bool isTask;
  final ValueChanged<bool> onChanged;

  const TaskTypeSelector({
    super.key,
    required this.isTask,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildTypeChip('Task', true),
        const SizedBox(width: 16),
        _buildTypeChip('Post', false),
      ],
    );
  }

  Widget _buildTypeChip(String label, bool isTaskType) {
    final isSelected = isTask == isTaskType;
    return GestureDetector(
      onTap: () => onChanged(isTaskType),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 33, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          border: isSelected ? Border.all(color: const Color(0xFF1E3A8A)) : null,
          boxShadow: isSelected
              ? const [BoxShadow(color: Color(0x3F000000), blurRadius: 4, offset: Offset(0, 4))]
              : null,
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 14),
        ),
      ),
    );
  }
}