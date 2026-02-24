// lib/widgets/team/member_card.dart
import 'package:flutter/material.dart';
import 'package:onboard/models/team_member_model.dart';

class MemberCard extends StatelessWidget {
  final TeamMemberModel member;
  final VoidCallback? onMessage;

  const MemberCard({
    super.key,
    required this.member,
    this.onMessage,
  });

  @override
  Widget build(BuildContext context) {
    final canMessage = member.role.contains('Supervisor') || 
                       member.role.contains('Assistant');

    return Container(
      width: double.infinity,
      height: 65,
      color: member.cardColor, // ✅ لازم يكون مش null
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Stack(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: member.avatarColor,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      member.initial,
                      style: const TextStyle(
                        fontSize: 20,
                        color: Color(0xFF0A0A0A),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: member.statusColor ?? const Color(0xFF00C950),
                      shape: BoxShape.circle,
                      border: Border.all(width: 1.27, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  member.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontFamily: 'Arimo',
                    color: Color(0xFF101727),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  member.role,
                  style: const TextStyle(
                    fontSize: 12,
                    fontFamily: 'Arimo',
                    color: Color(0xFF697282),
                  ),
                ),
              ],
            ),
          ),
          if (canMessage)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: GestureDetector(
                onTap: onMessage ?? () {
                  print('Message to ${member.name}');
                },
                child: const Text(
                  'Message',
                  style: TextStyle(
                    fontSize: 14,
                    fontFamily: 'Arimo',
                    color: Colors.black,
                  ),
                ),
              ),
            )
          else
            const SizedBox(width: 70),
        ],
      ),
    );
  }
}