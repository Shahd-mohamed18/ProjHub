// // lib/services/notification2_service.dart
// import 'dart:async';

// import 'package:signalr_netcore/signalr_client.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import '../cubits/notification/notification_cubit.dart';

// class Notification2Service {
//   static Notification2Service? _instance;
//   late HubConnection _hubConnection;
  
//   // 👇 غيري الرابط هنا
//   final String baseUrl = "https://projecthubb.runasp.net";
  
//   String? _currentUserId;
  
//   // Stream لتلقي الإشعارات
//   final StreamController<NotificationModel> _notificationController = 
//       StreamController<NotificationModel>.broadcast();
//   Stream<NotificationModel> get onNotification => _notificationController.stream;

//   Notification2Service._internal();
  
//   static Notification2Service get instance {
//     _instance ??= Notification2Service._internal();
//     return _instance!;
//   }

//   Future<void> init(String userId) async {
//     if (userId.isEmpty) {
//       print('⚠️ Cannot init notification service: userId is empty');
//       return;
//     }
    
//     _currentUserId = userId;
    
//     try {
//       _hubConnection = HubConnectionBuilder()
//           .withUrl(
//             "$baseUrl/notificationHub",
//             options: HttpConnectionOptions(
//               transport: HttpTransportType.LongPolling,
//             ),
//           )
//           .withAutomaticReconnect()
//           .build();

//       _hubConnection.on("ReceiveNotification", (arguments) {
//         if (arguments != null && arguments.isNotEmpty) {
//           final notificationData = arguments[0] as Map<String, dynamic>;
//           final notification = NotificationModel.fromJson(notificationData);
//           _notificationController.add(notification);
//           print("🔔 New notification: ${notification.title}");
//         }
//       });

//       await _hubConnection.start();
//       await _hubConnection.invoke("JoinUserGroup", args: [userId]);
//       print('✅ Notification service initialized for user: $userId');
//     } catch (e) {
//       print('❌ Failed to initialize notification service: $e');
//     }
//   }

//   // ============== REST API Calls ==============
  
//   Future<List<NotificationModel>> getNotifications(String userId) async {
//     try {
//       final response = await http.get(
//         Uri.parse("$baseUrl/api/notifications/$userId"),
//         headers: _getHeaders(),
//       );
      
//       if (response.statusCode == 200) {
//         final List<dynamic> data = json.decode(response.body);
//         return data.map((json) => NotificationModel.fromJson(json)).toList();
//       }
//       return [];
//     } catch (e) {
//       print('Error fetching notifications: $e');
//       return [];
//     }
//   }

//   Future<int> getUnreadCount(String userId) async {
//     try {
//       final response = await http.get(
//         Uri.parse("$baseUrl/api/notifications/$userId/unread-count"),
//         headers: _getHeaders(),
//       );
      
//       if (response.statusCode == 200) {
//         // يمكن أن يكون الرد رقم مباشر أو JSON
//         final body = json.decode(response.body);
//         if (body is int) return body;
//         if (body is Map && body['count'] != null) return body['count'];
//         return body ?? 0;
//       }
//       return 0;
//     } catch (e) {
//       print('Error fetching unread count: $e');
//       return 0;
//     }
//   }

//   Future<void> markAsRead(int notificationId) async {
//     try {
//       await http.put(
//         Uri.parse("$baseUrl/api/notifications/$notificationId/mark-read"),
//         headers: _getHeaders(),
//       );
//     } catch (e) {
//       print('Error marking as read: $e');
//     }
//   }

//   Future<void> markAllAsRead(String userId) async {
//     try {
//       await http.put(
//         Uri.parse("$baseUrl/api/notifications/$userId/mark-all-read"),
//         headers: _getHeaders(),
//       );
//     } catch (e) {
//       print('Error marking all as read: $e');
//     }
//   }

//   Map<String, String> _getHeaders() {
//     return {
//       'Content-Type': 'application/json',
//     };
//   }

//   Future<void> dispose() async {
//     try {
//       if (_hubConnection.state == HubConnectionState.Connected) {
//         await _hubConnection.stop();
//       }
//       await _notificationController.close();
//     } catch (e) {
//       print('Error disposing notification service: $e');
//     }
//   }
// }





import 'dart:async';

import 'package:signalr_netcore/signalr_client.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../cubits/notification/notification_cubit.dart';

class Notification2Service {
  static Notification2Service? _instance;
  HubConnection? _hubConnection; // تغيير إلى nullable
  
  final String baseUrl = "https://projecthubb.runasp.net";
  
  String? _currentUserId;
  
  final StreamController<NotificationModel> _notificationController = 
      StreamController<NotificationModel>.broadcast();
  Stream<NotificationModel> get onNotification => _notificationController.stream;

  Notification2Service._internal();
  
  static Notification2Service get instance {
    _instance ??= Notification2Service._internal();
    return _instance!;
  }

  Future<void> init(String userId) async {
    if (userId.isEmpty) {
      print('⚠️ Cannot init notification service: userId is empty');
      return;
    }
    
    _currentUserId = userId;
    
    try {
      // بناء الاتصال
      _hubConnection = HubConnectionBuilder()
          .withUrl(
            "$baseUrl/notificationHub",
            options: HttpConnectionOptions(
              transport: HttpTransportType.LongPolling,
            ),
          )
          .withAutomaticReconnect()
          .build();

      // تسجيل مستمع الإشعارات
      _hubConnection!.on("ReceiveNotification", (arguments) {
        if (arguments != null && arguments.isNotEmpty) {
          try {
            final notificationData = arguments[0] as Map<String, dynamic>;
            final notification = NotificationModel.fromJson(notificationData);
            _notificationController.add(notification);
            print("🔔 New notification: ${notification.title}");
          } catch (e) {
            print('⚠️ Error parsing notification: $e');
          }
        }
      });

      // بدء الاتصال
      await _hubConnection!.start();
      print('✅ SignalR connection started');
      
      // الانضمام إلى مجموعة المستخدم
      await _hubConnection!.invoke("JoinUserGroup", args: [userId]);
      print('✅ Joined user group: $userId');
      
      print('✅ Notification service initialized for user: $userId');
    } catch (e, stack) {
      print('❌ Failed to initialize notification service: $e');
      print('Stack trace: $stack');
      // إذا فشل الاتصال، نعيد تعيين _hubConnection إلى null لتجنب الاستخدام اللاحق
      _hubConnection = null;
    }
  }

  // ============== REST API Calls ==============
  
  Future<List<NotificationModel>> getNotifications(String userId) async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/api/notifications/$userId"),
        headers: _getHeaders(),
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => NotificationModel.fromJson(json)).toList();
      } else {
        print('⚠️ Failed to fetch notifications: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error fetching notifications: $e');
      return [];
    }
  }

  Future<int> getUnreadCount(String userId) async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/api/notifications/$userId/unread-count"),
        headers: _getHeaders(),
      );
      
      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        if (body is int) return body;
        if (body is Map && body['count'] != null) return body['count'] as int;
        return 0;
      }
      return 0;
    } catch (e) {
      print('Error fetching unread count: $e');
      return 0;
    }
  }

  Future<void> markAsRead(int notificationId) async {
    try {
      await http.put(
        Uri.parse("$baseUrl/api/notifications/$notificationId/mark-read"),
        headers: _getHeaders(),
      );
    } catch (e) {
      print('Error marking as read: $e');
    }
  }

  Future<void> markAllAsRead(String userId) async {
    try {
      await http.put(
        Uri.parse("$baseUrl/api/notifications/$userId/mark-all-read"),
        headers: _getHeaders(),
      );
    } catch (e) {
      print('Error marking all as read: $e');
    }
  }

  Map<String, String> _getHeaders() {
    return {
      'Content-Type': 'application/json',
    };
  }

  Future<void> dispose() async {
    try {
      if (_hubConnection != null && _hubConnection!.state == HubConnectionState.Connected) {
        await _hubConnection!.stop();
      }
      await _notificationController.close();
    } catch (e) {
      print('Error disposing notification service: $e');
    }
  }
}