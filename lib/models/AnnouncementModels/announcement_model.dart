// lib/models/AnnouncementModels/announcement_model.dart

class AnnouncementModel {
  final int id;
  final String message;
  final String? meetingLink;
  final int teamId;
  final String supervisorId;
  final String supervisorName;
  final DateTime createdAt;

  AnnouncementModel({
    required this.id,
    required this.message,
    this.meetingLink,
    required this.teamId,
    required this.supervisorId,
    required this.supervisorName,
    required this.createdAt,
  });

  /// Whether this announcement contains a meeting link
  bool get hasMeetingLink =>
      meetingLink != null && meetingLink!.trim().isNotEmpty;

  String get formattedDate {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[createdAt.month - 1]} ${createdAt.day}';
  }

  factory AnnouncementModel.fromJson(Map<String, dynamic> json) {
    // Parse date safely — backend may send ISO string or null
    DateTime parsedDate = DateTime.now();
    final rawDate = json['createdAt'] ??
        json['created_at'] ??
        json['date'] ??
        json['postedAt'];
    if (rawDate != null) {
      try {
        String s = rawDate.toString();
        if (!s.endsWith('Z') && !s.contains('+') && !s.contains('-', 10)) {
          s += 'Z';
        }
        parsedDate = DateTime.parse(s).toLocal();
      } catch (_) {}
    }

    return AnnouncementModel(
      id: (json['id'] ?? json['announcementId'] ?? 0) is int
          ? (json['id'] ?? json['announcementId'] ?? 0)
          : int.tryParse(
                  (json['id'] ?? json['announcementId'] ?? '0').toString()) ??
              0,
      message: (json['message'] ?? json['content'] ?? json['text'] ?? '')
          .toString(),
      meetingLink:
          (json['meetingLink'] ?? json['meeting_link'] ?? json['link'])
              ?.toString(),
      teamId: (json['teamId'] ?? json['team_id'] ?? 0) is int
          ? (json['teamId'] ?? json['team_id'] ?? 0)
          : int.tryParse(
                  (json['teamId'] ?? json['team_id'] ?? '0').toString()) ??
              0,
      supervisorId:
          (json['supervisorId'] ?? json['supervisor_id'] ?? '').toString(),
      supervisorName: (json['supervisorName'] ??
              json['supervisor_name'] ??
              json['authorName'] ??
              'Supervisor')
          .toString(),
      createdAt: parsedDate,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'message': message,
        'meetingLink': meetingLink,
        'teamId': teamId,
        'supervisorId': supervisorId,
        'supervisorName': supervisorName,
        'createdAt': createdAt.toIso8601String(),
      };
}