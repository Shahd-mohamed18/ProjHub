// screens/projectScreens/access_denied_screen.dart
import 'package:flutter/material.dart';

class AccessDeniedScreen extends StatelessWidget {
  final String userRole;

  const AccessDeniedScreen({super.key, required this.userRole});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 222, 233, 247),
              Colors.white,
              Color(0xff7E9FCA),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // رمز القفل أو المنع
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.block_rounded,
                      size: 80,
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // عنوان الصفحة
                  const Text(
                    'Access Denied',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // رسالة المنع حسب الدور
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 2,
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Icon(_getRoleIcon(), size: 50, color: _getRoleColor()),
                        const SizedBox(height: 12),
                        Text(
                          _getRoleMessage(),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _getRoleSubMessage(),
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // زر العودة
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff155DFC),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 15,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.arrow_back, color: Colors.white),
                        SizedBox(width: 8),
                        Text(
                          'Back to Projects',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // نص إضافي توضيحي
                  Text(
                    'Only students are allowed to upload projects',
                    style: TextStyle(fontSize: 12, color: Colors.black),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _getRoleMessage() {
    if (userRole == 'supervisor') {
      return 'Supervisors cannot upload projects';
    } else if (userRole == 'assistant') {
      return 'Teaching Assistants cannot upload projects';
    }
    return 'Access restricted';
  }

  String _getRoleSubMessage() {
    if (userRole == 'supervisor') {
      return 'You can supervise and review projects, but only students can submit new projects.';
    } else if (userRole == 'assistant') {
      return 'You can assist students and review their work, but project submission is limited to students only.';
    }
    return 'This feature is only available for students.';
  }

  IconData _getRoleIcon() {
    if (userRole == 'supervisor') {
      return Icons.verified_user_rounded;
    } else if (userRole == 'assistant') {
      return Icons.school_rounded;
    }
    return Icons.warning_rounded;
  }

  Color _getRoleColor() {
    if (userRole == 'supervisor') {
      return Colors.orange;
    } else if (userRole == 'assistant') {
      return Colors.purple;
    }
    return Colors.red;
  }
}
