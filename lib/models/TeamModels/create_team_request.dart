// CreateTeamRequest - للـ API
class CreateTeamRequest {
  final String name;
  final String? projectName;
  final String? description;
  final String supervisorId;
  final List<String> memberIds;

  CreateTeamRequest({
    required this.name,
    this.projectName,
    this.description,
    required this.supervisorId,
    required this.memberIds,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'projectName': projectName,
      'description': description,
      'supervisorId': supervisorId,
      'memberIds': memberIds,
    };
  }

  factory CreateTeamRequest.fromJson(Map<String, dynamic> json) {
    return CreateTeamRequest(
      name: json['name'] ?? '',
      projectName: json['projectName'],
      description: json['description'],
      supervisorId: json['supervisorId'] ?? '',
      memberIds: List<String>.from(json['memberIds'] ?? []),
    );
  }
}

// TeamResponse - الرد من الـ API بعد إنشاء الفريق
class TeamResponse {
  final int id;
  final String name;
  final String? projectName;
  final String? description;
  final String supervisorId;
  final String? supervisorName;
  final List<String> assistantIds;
  final List<String> memberIds;
  final DateTime createdAt;

  TeamResponse({
    required this.id,
    required this.name,
    this.projectName,
    this.description,
    required this.supervisorId,
    this.supervisorName,
    required this.assistantIds,
    required this.memberIds,
    required this.createdAt,
  });

  factory TeamResponse.fromJson(Map<String, dynamic> json) {
    return TeamResponse(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      projectName: json['projectName'],
      description: json['description'],
      supervisorId: json['supervisorId'] ?? '',
      supervisorName: json['supervisorName'],
      assistantIds: List<String>.from(json['assistantIds'] ?? []),
      memberIds: List<String>.from(json['memberIds'] ?? []),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }
}