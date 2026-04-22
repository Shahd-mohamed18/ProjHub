import 'package:flutter/material.dart';

class DueDateField extends StatelessWidget {
  final DateTime? selectedDate;
  final VoidCallback onTap;

  const DueDateField({
    super.key,
    required this.selectedDate,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Due Date', style: TextStyle(fontSize: 20)),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onTap,
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: const [BoxShadow(color: Color(0x3F000000), blurRadius: 4, offset: Offset(0, 4))],
            ),
            child: Row(
              children: [
                const SizedBox(width: 16),
                Text(
                  selectedDate == null
                      ? '📅 Select'
                      : '📅 ${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}',
                  style: const TextStyle(color: Colors.black54, fontSize: 16),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}