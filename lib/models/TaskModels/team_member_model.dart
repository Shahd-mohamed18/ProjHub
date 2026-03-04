// lib/models/team_member_model.dart
import 'package:flutter/material.dart';

class TeamMemberModel {
  final String id;
  final String name;
  final String role;
  final String initial;
  final Color avatarColor;
  final Color cardColor;
  final bool isOnline;
  final Color? statusColor;

  TeamMemberModel({
    required this.id,
    required this.name,
    required this.role,
    required this.initial,
    required this.avatarColor,
    required this.cardColor,
    this.isOnline = true,
    this.statusColor,
  });

  static List<TeamMemberModel> mockMembers = [
    TeamMemberModel(
      id: '1',
      name: 'Dr Mohamed',
      role: 'Supervisor',
      initial: 'M',
      avatarColor: const Color(0xFFF3F4F6),
      cardColor: const Color(0x8E3B82F6),
      isOnline: true,
    ),
    TeamMemberModel(
      id: '2',
      name: 'Eng Alaa',
      role: 'Assistant Teacher',
      initial: '👩',
      avatarColor: const Color(0xFFF3F4F6),
      cardColor: const Color(0xFFFEF9C2),
      isOnline: true,
    ),
    TeamMemberModel(
      id: '3',
      name: 'Faten Hesham',
      role: 'Flutter Developer',
      initial: '👩',
      avatarColor: const Color(0xFFF3F4F6),
      cardColor: Colors.white,
      isOnline: true,
      statusColor: const Color(0xFFF0B100),
    ),
    TeamMemberModel(
      id: '4',
      name: 'Dalia Gamal',
      role: 'BackEnd Developer',
      initial: '👩',
      avatarColor: const Color(0xFFF3F4F6),
      cardColor: Colors.white,
      isOnline: true,
    ),
    TeamMemberModel(
      id: '5',
      name: 'Shahd Mohamed',
      role: 'Flutter Developer',
      initial: '👩',
      avatarColor: const Color(0xFFF3F4F6),
      cardColor: Colors.white,
      isOnline: true,
    ),
    TeamMemberModel(
      id: '6',
      name: 'Marwa Mohamed',
      role: 'Designer',
      initial: '👩',
      avatarColor: const Color(0xFFF3F4F6),
      cardColor: Colors.white,
      isOnline: true,
    ),
    TeamMemberModel(
      id: '7',
      name: 'Aya Mosa',
      role: 'AI Developer',
      initial: '👩',
      avatarColor: const Color(0xFFF3F4F6),
      cardColor: Colors.white,
      isOnline: true,
    ),
    TeamMemberModel(
      id: '8',
      name: 'Asmaa El-Said',
      role: 'BackEnd Developer',
      initial: '👩',
      avatarColor: const Color(0xFFF3F4F6),
      cardColor: Colors.white,
      isOnline: true,
    ),
  ];
}