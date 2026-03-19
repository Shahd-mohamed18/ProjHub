import 'package:flutter/material.dart';
import 'package:onboard/models/TeamModels/team_model.dart';
import 'package:onboard/models/user_model.dart';

class TeamCardWidget extends StatelessWidget {
  final TeamModel team;
  final UserRole userRole; // إضافة هذا السطر
  final VoidCallback onViewDetails;

  const TeamCardWidget({
    super.key,
    required this.team,
    required this.userRole, // إضافة هذا السطر
    required this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(
        top: 17.26,
        left: 17.26,
        right: 17.26,
        bottom: 20,
      ),
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          side: const BorderSide(width: 1.27, color: Color(0xFFF2F4F6)),
          borderRadius: BorderRadius.circular(14),
        ),
        shadows: const [
          BoxShadow(
            color: Color(0x19000000),
            blurRadius: 2,
            offset: Offset(0, 1),
            spreadRadius: -1,
          ),
          BoxShadow(
            color: Color(0x19000000),
            blurRadius: 3,
            offset: Offset(0, 1),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Team icon and name
          Row(
            children: [
              const Text(
                '👥',
                style: TextStyle(
                  color: Color(0xFF0A0A0A),
                  fontSize: 24,
                  fontFamily: 'Arimo',
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(width: 7.99),
              Text(
                team.name,
                style: const TextStyle(
                  color: Color(0xFF101727),
                  fontSize: 18,
                  fontFamily: 'Arimo',
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
          const SizedBox(height: 11.98),

          // Project name
          Text(
            team.projectName ?? 'No project',
            style: const TextStyle(
              color: Color(0xFF495565),
              fontSize: 16,
              fontFamily: 'Arimo',
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 11.98),

          // Members icons
          Row(
            children: [
              ...List.generate(
                team.members.length > 5 ? 5 : team.members.length,
                (index) => Padding(
                  padding: const EdgeInsets.only(right: 3.99),
                  child: Container(
                    width: 19.22,
                    height: 20,
                    child: const Text(
                      '👤',
                      style: TextStyle(
                        color: Color(0xFF495565),
                        fontSize: 14,
                        fontFamily: 'Arimo',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 3.99),
              Text(
                '${team.totalMembers} members',
                style: const TextStyle(
                  color: Color(0xFF495565),
                  fontSize: 14,
                  fontFamily: 'Arimo',
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
          const SizedBox(height: 11.98),

          // Projects icon
          Row(
            children: [
              Container(
                width: 19.22,
                height: 20,
                margin: const EdgeInsets.only(right: 7.99),
                child: const Text(
                  '📁',
                  style: TextStyle(
                    color: Color(0xFF495565),
                    fontSize: 14,
                    fontFamily: 'Arimo',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              Text(
                '${team.activeProjects} Active ${team.activeProjects == 1 ? 'Project' : 'Projects'}',
                style: const TextStyle(
                  color: Color(0xFF495565),
                  fontSize: 14,
                  fontFamily: 'Arimo',
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
          const SizedBox(height: 11.98),

          // View Details button
          Container(
            width: double.infinity,
            height: 39.99,
            decoration: const ShapeDecoration(
              color: Color(0xFFF9FAFB),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: onViewDetails,
                  child: const Text(
                    'View Details',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF155CFB),
                      fontSize: 16,
                      fontFamily: 'Arimo',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                const SizedBox(width: 7.99),
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 12,
                  color: Color(0xFF155CFB),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}