
// // lib/models/TeamModels/team_member.dart
// class TeamMember {
//   final String id;
//   final String name;
//   final String? role;
//   final String? position;
//   final String? photoUrl; // إضافة حقل الصورة
//   final bool isSelected;

//   TeamMember({
//     required this.id,
//     required this.name,
//     this.role,
//     this.position,
//     this.photoUrl, // إضافة في الكونستركتور
//     this.isSelected = false,
//   });

//   String get displayRole => position ?? role ?? 'Member';

//   factory TeamMember.fromJson(Map<String, dynamic> json) {
//     return TeamMember(
//       id: json['id'] ?? '',
//       name: json['name'] ?? '',
//       role: json['role'],
//       position: json['position'],
//       photoUrl: json['photoUrl'], // إضافة عند القراءة من JSON
//       isSelected: json['isSelected'] ?? false,
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'name': name,
//       'role': role,
//       'position': position,
//       'photoUrl': photoUrl, // إضافة عند التحويل لـ JSON
//       'isSelected': isSelected,
//     };
//   }

//   TeamMember copyWith({
//     String? id,
//     String? name,
//     String? role,
//     String? position,
//     String? photoUrl,
//     bool? isSelected,
//   }) {
//     return TeamMember(
//       id: id ?? this.id,
//       name: name ?? this.name,
//       role: role ?? this.role,
//       position: position ?? this.position,
//       photoUrl: photoUrl ?? this.photoUrl, // إضافة في copyWith
//       isSelected: isSelected ?? this.isSelected,
//     );
//   }
// }

// lib/models/TeamModels/team_member.dart
class TeamMember {
  final String id;
  final String name;
  final String? role;
  final String? position;
  final String? photoUrl;
  bool isSelected;
  bool isAlreadyInTeam;

  TeamMember({
    required this.id,
    required this.name,
    this.role,
    this.position,
    this.photoUrl,
    this.isSelected = false,
    this.isAlreadyInTeam = false,
  });

  String get displayRole {
    if (position != null && position!.isNotEmpty) return position!;
    if (role != null && role!.isNotEmpty) return role!;
    return 'Member';
  }

  TeamMember copyWith({
    String? id,
    String? name,
    String? role,
    String? position,
    String? photoUrl,
    bool? isSelected,
    bool? isAlreadyInTeam,
  }) {
    return TeamMember(
      id: id ?? this.id,
      name: name ?? this.name,
      role: role ?? this.role,
      position: position ?? this.position,
      photoUrl: photoUrl ?? this.photoUrl,
      isSelected: isSelected ?? this.isSelected,
      isAlreadyInTeam: isAlreadyInTeam ?? this.isAlreadyInTeam,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'role': role,
      'position': position,
      'photoUrl': photoUrl,
    };
  }

  factory TeamMember.fromJson(Map<String, dynamic> json) {
    return TeamMember(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      role: json['role'],
      position: json['position'],
      photoUrl: json['photoUrl'],
    );
  }

  @override
  String toString() => 'TeamMember(id: $id, name: $name, role: $role)';
}