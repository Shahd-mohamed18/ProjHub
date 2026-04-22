
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


TeamModel copyWith({
    String? id,
    String? name,
    String? projectName,
    String? description,
    String? supervisorId,
    String? supervisorName,
    List<TeamMember>? assistants,
    List<TeamMember>? members,
    DateTime? createdAt,
    int? activeProjects,
  }) {
    return TeamModel(
      id: id ?? this.id,
      name: name ?? this.name,
      projectName: projectName ?? this.projectName,
      description: description ?? this.description,
      supervisorId: supervisorId ?? this.supervisorId,
      supervisorName: supervisorName ?? this.supervisorName,
      assistants: assistants ?? this.assistants,
      members: members ?? this.members,
      createdAt: createdAt ?? this.createdAt,
      activeProjects: activeProjects ?? this.activeProjects,
    );
  }
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