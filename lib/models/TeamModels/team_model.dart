
import 'package:onboard/models/TeamModels/team_member.dart';

class TeamModel {
  final String id;
  final String name;
  final String? projectName;
  final String? description;
  final String supervisorId;
  final String? supervisorName;
  final List<TeamMember> assistants;
  final List<TeamMember> members;
  final DateTime createdAt;
  final int activeProjects;

  TeamModel({
    required this.id,
    required this.name,
    this.projectName,
    this.description,
    required this.supervisorId,
    this.supervisorName,
    required this.assistants,
    required this.members,
    required this.createdAt,
    this.activeProjects = 1,
  });

  int get totalMembers => members.length ;

  factory TeamModel.fromJson(Map<String, dynamic> json) {
    return TeamModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      projectName: json['projectName'],
      description: json['description'],
      supervisorId: json['supervisorId'] ?? '',
      supervisorName: json['supervisorName'],
      assistants: (json['assistants'] as List? ?? [])
          .map((e) => TeamMember.fromJson(e))
          .toList(),
      members: (json['members'] as List? ?? [])
          .map((e) => TeamMember.fromJson(e))
          .toList(),
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : DateTime.now(),
      activeProjects: json['activeProjects'] ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'projectName': projectName,
      'description': description,
      'supervisorId': supervisorId,
      'supervisorName': supervisorName,
      'assistants': assistants.map((e) => e.toJson()).toList(),
      'members': members.map((e) => e.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'activeProjects': activeProjects,
    };
  }
}