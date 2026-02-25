// lib/widgets/tasks/tasks_tab_bar.dart
import 'package:flutter/material.dart';

class TasksTabBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTabChanged;

  const TasksTabBar({
    super.key,
    required this.currentIndex,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 51,
      color: Colors.white,
      child: Row(
        children: [
          _buildTab(label: 'Home', index: 0),
          _buildTab(label: 'My Work', index: 1),
        ],
      ),
    );
  }

  Widget _buildTab({required String label, required int index}) {
    final isActive = currentIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => onTabChanged(index),
        behavior: HitTestBehavior.opaque,
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                width: 1.27,
                color: isActive ? const Color(0xFF2196F3) : Colors.transparent,
              ),
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isActive
                    ? const Color(0xFF2196F3)
                    : const Color(0xFF495565),
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}