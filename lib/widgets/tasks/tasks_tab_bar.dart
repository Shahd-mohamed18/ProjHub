// lib/widgets/tasks/tasks_tab_bar.dart
import 'package:flutter/material.dart';

class TasksTabBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTabChanged;

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
          Expanded(
            child: GestureDetector(
              onTap: () => onTabChanged(0),
              child: Container(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      width: 1.27,
                      color: currentIndex == 0
                          ? const Color(0xFF2196F3)
                          : Colors.transparent,
                    ),
                  ),
                ),
                child: Center(
                  child: Text(
                    'Home',
                    style: TextStyle(
                      color: currentIndex == 0
                          ? const Color(0xFF2196F3)
                          : const Color(0xFF495565),
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => onTabChanged(1),
              child: Container(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      width: 1.27,
                      color: currentIndex == 1
                          ? const Color(0xFF2196F3)
                          : Colors.transparent,
                    ),
                  ),
                ),
                child: Center(
                  child: Text(
                    'My Work',
                    style: TextStyle(
                      color: currentIndex == 1
                          ? const Color(0xFF2196F3)
                          : const Color(0xFF495565),
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}