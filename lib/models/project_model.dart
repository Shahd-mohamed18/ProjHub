
import 'package:cloud_firestore/cloud_firestore.dart';

class Project {
  final String id;
  final String title;
  final String description;
  final String authorId;
  final String authorName;
  final String? userImage; 
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
    this.userImage,
    required this.images,
    required this.tags,
    required this.category,
    required this.documentUrl,
    this.githubUrl,
    required this.createdAt,
  });

  String get coverImage => images.isNotEmpty ? images.first : '';
  List<String> get projectImages => images.length > 1 ? images.sublist(1) : [];

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
      userImage: userImage,
      images: images ?? this.images,
      tags: tags ?? this.tags,
      category: category ?? this.category,
      documentUrl: documentUrl ?? this.documentUrl,
      githubUrl: githubUrl ?? this.githubUrl,
      createdAt: createdAt,
    );
  }

  factory Project.fromFirestore(String id, Map<String, dynamic> data) {
    DateTime createdAtDate;
    final createdAtField = data['createdAt'];

    if (createdAtField == null) {
      createdAtDate = DateTime.now();
    } else if (createdAtField is Timestamp) {
      createdAtDate = createdAtField.toDate();
    } else if (createdAtField is String) {
      createdAtDate = DateTime.parse(createdAtField);
    } else {
      createdAtDate = DateTime.now();
    }

    return Project(
      id: id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      authorId: data['authorId'] ?? '',
      authorName: data['authorName'] ?? '',
      userImage: data['userImage'],
      images: List<String>.from(data['images'] ?? []),
      tags: List<String>.from(data['tags'] ?? []),
      category: data['category'] ?? '',
      documentUrl: data['documentUrl'] ?? '',
      githubUrl: data['githubUrl'],
      createdAt: createdAtDate,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'authorId': authorId,
      'authorName': authorName,
      'userImage': userImage,
      'images': images,
      'tags': tags,
      'category': category,
      'documentUrl': documentUrl,
      'githubUrl': githubUrl,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}