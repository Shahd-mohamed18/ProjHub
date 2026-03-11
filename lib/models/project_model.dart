// class Project {
//   final String id;
//   final String title;
//   final String description;
//   final String authorId;
//   final String authorName;
//   final List<String> images;
//   final List<String> tags;
//   final String category;
//   final String documentUrl;
//   final String githubUrl; // إضافة هذا السطر
//   final DateTime createdAt;

//   Project({
//     required this.id,
//     required this.title,
//     required this.description,
//     required this.authorId,
//     required this.authorName,
//     required this.images,
//     required this.tags,
//     required this.category,
//     required this.documentUrl,
//     required this.githubUrl, // إضافة هذا السطر
//     required this.createdAt,
//   });

//   String get coverImage => images.isNotEmpty ? images.first : '';
//   List<String> get projectImages => images.length > 1 ? images.sublist(1) : [];

//   factory Project.fromJson(Map<String, dynamic> json) {
//     return Project(
//       id: json['id'],
//       title: json['title'],
//       description: json['description'],
//       authorId: json['authorId'],
//       authorName: json['authorName'],
//       images: List<String>.from(json['images'] ?? []),
//       tags: List<String>.from(json['tags'] ?? []),
//       category: json['category'],
//       documentUrl: json['documentUrl'] ?? '',
//       githubUrl: json['githubUrl'] ?? '', // إضافة هذا السطر
//       createdAt: DateTime.parse(json['createdAt']),
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'title': title,
//       'description': description,
//       'authorId': authorId,
//       'authorName': authorName,
//       'images': images,
//       'tags': tags,
//       'category': category,
//       'documentUrl': documentUrl,
//       'githubUrl': githubUrl, // إضافة هذا السطر
//       'createdAt': createdAt.toIso8601String(),
//     };
//   }
// }


class Project {
  final String id;
  final String title;
  final String description;
  final String authorId;
  final String authorName;
  final List<String> images;
  final List<String> tags;
  final String category;
  final String documentUrl;
  final String? githubUrl;
  final DateTime createdAt;

  Project({
    required this.id,
    required this.title,
    required this.description,
    required this.authorId,
    required this.authorName,
    required this.images,
    required this.tags,
    required this.category,
    required this.documentUrl,
    this.githubUrl,
    required this.createdAt,
  });

  String get coverImage => images.isNotEmpty ? images.first : '';
  List<String> get projectImages => images.length > 1 ? images.sublist(1) : [];

  // كوبي المشروع مع تحديث بعض الحقول
  Project copyWith({
    String? title,
    String? description,
    List<String>? images,
    List<String>? tags,
    String? category,
    String? documentUrl,
    String? githubUrl,
  }) {
    return Project(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      authorId: authorId,
      authorName: authorName,
      images: images ?? this.images,
      tags: tags ?? this.tags,
      category: category ?? this.category,
      documentUrl: documentUrl ?? this.documentUrl,
      githubUrl: githubUrl ?? this.githubUrl,
      createdAt: createdAt,
    );
  }

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      authorId: json['authorId'],
      authorName: json['authorName'],
      images: List<String>.from(json['images'] ?? []),
      tags: List<String>.from(json['tags'] ?? []),
      category: json['category'],
      documentUrl: json['documentUrl'] ?? '',
      githubUrl: json['githubUrl'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  factory Project.fromFirestore(String id, Map<String, dynamic> data) {
    return Project(
      id: id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      authorId: data['authorId'] ?? '',
      authorName: data['authorName'] ?? '',
      images: List<String>.from(data['images'] ?? []),
      tags: List<String>.from(data['tags'] ?? []),
      category: data['category'] ?? '',
      documentUrl: data['documentUrl'] ?? '',
      githubUrl: data['githubUrl'],
      createdAt: DateTime.parse(data['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'authorId': authorId,
      'authorName': authorName,
      'images': images,
      'tags': tags,
      'category': category,
      'documentUrl': documentUrl,
      'githubUrl': githubUrl,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}