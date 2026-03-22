// lib/widgets/supervisor/member_checkbox.dart
import 'package:flutter/material.dart';
import 'package:onboard/models/TeamModels/team_member.dart'; // ✅ الجديد

class MemberCheckbox extends StatelessWidget {
  final TeamMember member; // ✅ الجديد
  final bool isSelected;
  final ValueChanged<bool?> onChanged;

  const MemberCheckbox({
    super.key,
    required this.member,
    required this.isSelected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Checkbox(
          value: isSelected,
          onChanged: onChanged,
          activeColor: const Color(0xFF155DFC),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                member.name,
                style: const TextStyle(color: Color(0xFF1E3A8A), fontSize: 14),
              ),
              if (member.role != null)
                Text(
                  member.role!,
                  style: const TextStyle(color: Color(0xFF697282), fontSize: 12),
                ),
            ],
          ),
        ),
      ],
    );
  }
}