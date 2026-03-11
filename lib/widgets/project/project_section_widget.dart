import 'package:flutter/material.dart';

class ProjectSectionWidget extends StatefulWidget {
  const ProjectSectionWidget({super.key, required this.projectCategory});

  final String projectCategory;

  @override
  State<ProjectSectionWidget> createState() => _ProjectSectionWidgetState();
}

class _ProjectSectionWidgetState extends State<ProjectSectionWidget> {
  bool _isTapped = false; // حالة الضغط

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isTapped = !_isTapped; // تغيير اللون عند الضغط
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(horizontal: 10),
        padding: const EdgeInsets.symmetric(horizontal: 30),
        decoration: BoxDecoration(
          color: _isTapped
              ? Colors.blue
              : Colors.white, // اللون الأزرق عند الضغط
          borderRadius: BorderRadius.circular(15),
        ),
        child: Center(
          child: Text(
            widget.projectCategory,
            maxLines: 1,
            overflow: TextOverflow.visible,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: _isTapped ? Colors.white : Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}
