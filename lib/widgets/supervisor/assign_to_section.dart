// lib/widgets/supervisor/assign_to_section.dart
import 'package:flutter/material.dart';
import 'package:onboard/models/TeamModels/team_member.dart'; // ✅ الجديد
import 'package:onboard/widgets/supervisor/member_checkbox.dart';

class AssignToSection extends StatefulWidget {
  final bool assignToAll;
  final ValueChanged<bool> onAssignToAllChanged;
  final List<TeamMember> teamMembers; // ✅ الجديد
  final Map<String, bool> selectedMembers;
  final Function(String, bool) onMemberChanged;

  const AssignToSection({
    super.key,
    required this.assignToAll,
    required this.onAssignToAllChanged,
    required this.teamMembers,
    required this.selectedMembers,
    required this.onMemberChanged,
  });

  @override
  State<AssignToSection> createState() => _AssignToSectionState();
}

class _AssignToSectionState extends State<AssignToSection> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Assign To',
            style: TextStyle(
                fontSize: 14,
                fontFamily: 'Arimo',
                fontWeight: FontWeight.w700,
                color: Color(0xFF101828))),
        const SizedBox(height: 12),
        Row(
          children: [
            Checkbox(
              value: widget.assignToAll,
              onChanged: (v) => widget.onAssignToAllChanged(v ?? true),
              activeColor: const Color(0xFF155DFC),
            ),
            const Text('All Team Members',
                style: TextStyle(
                    fontSize: 14,
                    fontFamily: 'Arimo',
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF101828))),
          ],
        ),
        Row(
          children: [
            Checkbox(
              value: !widget.assignToAll,
              onChanged: (v) => widget.onAssignToAllChanged(!(v ?? false)),
              activeColor: const Color(0xFF155DFC),
            ),
            const Text('Specific Members:',
                style: TextStyle(
                    fontSize: 14,
                    fontFamily: 'Arimo',
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF101828))),
          ],
        ),
        if (!widget.assignToAll) ...[
          const SizedBox(height: 8),
          if (widget.teamMembers.isEmpty)
            const Padding(
              padding: EdgeInsets.only(left: 40),
              child: Text('No members in this team',
                  style: TextStyle(color: Colors.grey, fontSize: 14)),
            )
          else
            Container(
              margin: const EdgeInsets.only(left: 24),
              child: Column(
                children: widget.teamMembers.map((member) {
                  return MemberCheckbox(
                    member: member,
                    isSelected: widget.selectedMembers[member.id] ?? false,
                    onChanged: (v) =>
                        widget.onMemberChanged(member.id, v ?? false),
                  );
                }).toList(),
              ),
            ),
        ],
      ],
    );
  }
}