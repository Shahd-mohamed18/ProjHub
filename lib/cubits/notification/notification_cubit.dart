// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:onboard/services/notification2_service.dart';

// // ==================== States ====================
// abstract class NotificationState {}

// class NotificationInitial extends NotificationState {}

// class NotificationLoading extends NotificationState {}

// class NotificationsLoaded extends NotificationState {
//   final List<NotificationModel> notifications;
//   final int unreadCount;

//   NotificationsLoaded({
//     required this.notifications,
//     required this.unreadCount,
//   });
// }

// class NotificationError extends NotificationState {
//   final String message;
//   NotificationError(this.message);
// }

// // ==================== Model ====================
// class NotificationModel {
//   final int id;
//   final String title;
//   final String message;
//   final String type; // task, feedback, team, etc.
//   final bool isRead;
//   final DateTime createdAt;
//   final Map<String, dynamic>? data; // بيانات إضافية (مثل postId, commentId)

//   NotificationModel({
//     required this.id,
//     required this.title,
//     required this.message,
//     required this.type,
//     required this.isRead,
//     required this.createdAt,
//     this.data,
//   });

//   factory NotificationModel.fromJson(Map<String, dynamic> json) {
//     // محاولة تحليل التاريخ بتنسيقات متعددة
//     DateTime parseDate(dynamic dateValue) {
//       if (dateValue == null) return DateTime.now();
//       try {
//         if (dateValue is String) {
//           // محاولة parse ISO 8601
//           return DateTime.parse(dateValue);
//         } else if (dateValue is int) {
//           // ربما timestamp Unix
//           return DateTime.fromMillisecondsSinceEpoch(dateValue);
//         }
//       } catch (e) {
//         print('⚠️ Failed to parse date: $dateValue, error: $e');
//       }
//       return DateTime.now(); // fallback
//     }

//     return NotificationModel(
//       id: json['id'] ?? 0,
//       title: json['title'] ?? '',
//       message: json['message'] ?? '',
//       type: json['type'] ?? 'general',
//       isRead: json['isRead'] ?? json['is_read'] ?? false,
//       createdAt: parseDate(json['createdAt'] ?? json['created_at']),
//       data: json['data'] is Map ? Map<String, dynamic>.from(json['data']) : null,
//     );
//   }
// }

// // ==================== Cubit ====================
// class NotificationCubit extends Cubit<NotificationState> {
//   NotificationCubit() : super(NotificationInitial());

//   List<NotificationModel> _allNotifications = [];
//   int _unreadCount = 0;

//   Future<void> loadNotifications(String userId) async {
//     if (userId.isEmpty) {
//       print('⚠️ Cannot load notifications: userId is empty');
//       return;
//     }

//     emit(NotificationLoading());
//     try {
//       _allNotifications = await Notification2Service.instance.getNotifications(userId);
//       _unreadCount = await Notification2Service.instance.getUnreadCount(userId);
//       // فرز حسب الأحدث أولاً (بناءً على createdAt)
//       _allNotifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));
//       emit(NotificationsLoaded(
//         notifications: _allNotifications,
//         unreadCount: _unreadCount,
//       ));
//     } catch (e) {
//       emit(NotificationError(e.toString()));
//     }
//   }

//   Future<void> markAsRead(int notificationId, String userId) async {
//     try {
//       await Notification2Service.instance.markAsRead(notificationId);
//       await loadNotifications(userId);
//     } catch (e) {
//       print('Error marking notification as read: $e');
//     }
//   }

//   Future<void> markAllAsRead(String userId) async {
//     try {
//       await Notification2Service.instance.markAllAsRead(userId);
//       await loadNotifications(userId);
//     } catch (e) {
//       print('Error marking all as read: $e');
//     }
//   }

//   void addNewNotification(NotificationModel notification) {
//     // إدراج في البداية
//     _allNotifications.insert(0, notification);
//     _unreadCount++;
//     emit(NotificationsLoaded(
//       notifications: _allNotifications,
//       unreadCount: _unreadCount,
//     ));
//   }

//   int get unreadCount => _unreadCount;
// }

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:onboard/services/notification2_service.dart';

abstract class NotificationState {}

class NotificationInitial extends NotificationState {}

class NotificationLoading extends NotificationState {}

class NotificationsLoaded extends NotificationState {
  final List<NotificationModel> notifications;
  final int unreadCount;

  NotificationsLoaded({required this.notifications, required this.unreadCount});
}

class NotificationError extends NotificationState {
  final String message;
  NotificationError(this.message);
}

class NotificationModel {
  final int id;
  final String title;
  final String message;
  final String type;
  final bool isRead;
  final DateTime createdAt;
  final Map<String, dynamic>? data;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.isRead,
    required this.createdAt,
    this.data,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    DateTime parseDate(dynamic dateValue) {
      if (dateValue == null) return DateTime.now();
      try {
        if (dateValue is String) {
          return DateTime.parse(dateValue);
        } else if (dateValue is int) {
          return DateTime.fromMillisecondsSinceEpoch(dateValue);
        }
      } catch (e) {
        print('Failed to parse date: $dateValue, error: $e');
      }
      return DateTime.now();
    }

    return NotificationModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      type: json['type'] ?? 'general',
      isRead: json['isRead'] ?? json['is_read'] ?? false,
      createdAt: parseDate(json['createdAt'] ?? json['created_at']),
      data: json['data'] is Map
          ? Map<String, dynamic>.from(json['data'])
          : null,
    );
  }
}

class NotificationCubit extends Cubit<NotificationState> {
  NotificationCubit() : super(NotificationInitial());

  List<NotificationModel> _allNotifications = [];
  int _unreadCount = 0;

  Future<void> loadNotifications(String userId) async {
    if (userId.isEmpty) {
      print('Cannot load notifications: userId is empty');
      return;
    }

    emit(NotificationLoading());
    try {
      _allNotifications = await Notification2Service.instance.getNotifications(
        userId,
      );
      _unreadCount = await Notification2Service.instance.getUnreadCount(userId);
      _allNotifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      emit(
        NotificationsLoaded(
          notifications: _allNotifications,
          unreadCount: _unreadCount,
        ),
      );
    } catch (e) {
      emit(NotificationError(e.toString()));
    }
  }

  Future<void> markAsRead(int notificationId, String userId) async {
    try {
      await Notification2Service.instance.markAsRead(notificationId);
      await loadNotifications(userId);
    } catch (e) {
      print('Error marking notification as read: $e');
    }
  }

  Future<void> markAllAsRead(String userId) async {
    try {
      await Notification2Service.instance.markAllAsRead(userId);
      await loadNotifications(userId);
    } catch (e) {
      print('Error marking all as read: $e');
    }
  }

  void addNewNotification(NotificationModel notification) {
    _allNotifications.insert(0, notification);
    _unreadCount++;
    emit(
      NotificationsLoaded(
        notifications: _allNotifications,
        unreadCount: _unreadCount,
      ),
    );
  }

  int get unreadCount => _unreadCount;
}
