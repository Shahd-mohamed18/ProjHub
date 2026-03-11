import 'package:flutter/material.dart';
import 'package:onboard/models/user_model.dart';

class RoleSelectorWidget extends StatelessWidget {
  final UserRole selectedRole;
  final Function(UserRole) onRoleSelected;

  const RoleSelectorWidget({
    super.key,
    required this.selectedRole,
    required this.onRoleSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Select Your Role',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildRoleOption(
            role: UserRole.student,
            icon: Icons.school,
            title: 'Student',
            description: 'Share projects and collaborate',
          ),
          _buildRoleOption(
            role: UserRole.assistant,
            icon: Icons.assistant,
            title: 'Assistant',
            description: 'Support, help, and manage',
          ),
          _buildRoleOption(
            role: UserRole.doctor,
            icon: Icons.medical_services,
            title: 'Doctor',
            description: 'Supervise projects and manage teams',
          ),
        ],
      ),
    );
  }

  Widget _buildRoleOption({
    required UserRole role,
    required IconData icon,
    required String title,
    required String description,
  }) {
    final isSelected = selectedRole == role;
    return GestureDetector(
      onTap: () => onRoleSelected(role),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1E3A8A).withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF1E3A8A) : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _getRoleColor(role).withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: _getRoleColor(role)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    description,
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: Color(0xFF1E3A8A)),
          ],
        ),
      ),
    );
  }

  Color _getRoleColor(UserRole role) {
    switch (role) {
      case UserRole.student:
        return const Color(0xff7E9FCA);
      case UserRole.assistant:
        return const Color(0xffE9EC4D);
      case UserRole.doctor:
        return const Color(0Xff9747FF);
    }
  }
}