
// lib/models/TeamModels/team_member.dart
class TeamMember {
  final String id;
  final String name;
  final String? role;
  final String? position;
  final String? photoUrl; // إضافة حقل الصورة
  final bool isSelected;

  TeamMember({
    required this.id,
    required this.name,
    this.role,
    this.position,
    this.photoUrl, // إضافة في الكونستركتور
    this.isSelected = false,
  });

  String get displayRole => position ?? role ?? 'Member';

  factory TeamMember.fromJson(Map<String, dynamic> json) {
    return TeamMember(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      role: json['role'],
      position: json['position'],
      photoUrl: json['photoUrl'], // إضافة عند القراءة من JSON
      isSelected: json['isSelected'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'role': role,
      'position': position,
      'photoUrl': photoUrl, // إضافة عند التحويل لـ JSON
      'isSelected': isSelected,
    };
  }

  TeamMember copyWith({
    String? id,
    String? name,
    String? role,
    String? position,
    String? photoUrl,
    bool? isSelected,
  }) {
    return TeamMember(
      id: id ?? this.id,
      name: name ?? this.name,
      role: role ?? this.role,
      position: position ?? this.position,
      photoUrl: photoUrl ?? this.photoUrl, // إضافة في copyWith
      isSelected: isSelected ?? this.isSelected,
    );
  }
}