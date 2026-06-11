// // lib/services/notification_service.dart
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// class NotificationService {
//   static final FirebaseMessaging _fcm = FirebaseMessaging.instance;
//   static final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

//   static Future<void> initialize(String currentUserId) async {
//     // 1. طلب الإذن من المستخدم
//     NotificationSettings settings = await _fcm.requestPermission(
//       alert: true,
//       badge: true,
//       sound: true,
//     );

//     if (settings.authorizationStatus != AuthorizationStatus.authorized) {
//       print('⚠️ User declined notification permission');
//       return;
//     }

//     // 2. تهيئة الإشعارات المحلية
//     const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
//     const DarwinInitializationSettings iosSettings = DarwinInitializationSettings();
//     const InitializationSettings initSettings = InitializationSettings(
//       android: androidSettings,
//       iOS: iosSettings,
//     );

//     await _localNotifications.initialize(
//       settings: initSettings,
//       onDidReceiveNotificationResponse: _onNotificationTap,
//     );

//     // 3. حفظ التوكن
//     await _saveTokenToFirestore(currentUserId);

//     // 4. استماع للإشعارات
//     FirebaseMessaging.onMessage.listen(_showLocalNotification);
//     FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);
    
//     // 5. معالجة الإشعار اللي فتح التطبيق
//     RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();
//     if (initialMessage != null) {
//       _handleMessage(initialMessage);
//     }
//   }

//   static Future<void> _saveTokenToFirestore(String userId) async {
//     try {
//       String? token = await _fcm.getToken();
//       if (token != null) {
//         await FirebaseFirestore.instance.collection('users').doc(userId).update({
//           'fcmToken': token,
//         });
//         print('✅ FCM Token saved for: $userId');
//       }
//     } catch (e) {
//       print('❌ Error saving token: $e');
//     }
//   }

//   static void _showLocalNotification(RemoteMessage message) {
//     final notification = message.notification;
//     if (notification == null) return;

//     _localNotifications.show(
//       id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
//       title: notification.title,
//       body: notification.body,
//       notificationDetails: NotificationDetails(
//         android: AndroidNotificationDetails(
//           'chat_channel',
//           'Chat Notifications',
//           channelDescription: 'Notifications for new messages',
//           importance: Importance.high,
//           priority: Priority.high,
//         ),
//         iOS: const DarwinNotificationDetails(),
//       ),
//       payload: message.data['senderId'],
//     );
//   }

//   static void _handleMessage(RemoteMessage message) {
//     final senderId = message.data['senderId'];
//     final senderName = message.data['senderName'];
//     print('📱 Open chat with: $senderName ($senderId)');
//     // هنا تضيفي التنقل لشاشة المحادثة
//   }

//   static void _onNotificationTap(NotificationResponse response) {
//     final payload = response.payload;
//     if (payload != null) {
//       print('📱 Tapped notification for user: $payload');
//       // التنقل هنا
//     }
//   }
// }

// lib/services/notification_service.dart
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  // تهيئة خدمة الإشعارات
  static Future<void> initialize() async {
    // إعدادات Android
    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    
    // إعدادات iOS
    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    
    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );
  }

  // عرض إشعار محلي
  static Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'chat_channel',
      'Chat Notifications',
      channelDescription: 'إشعارات الرسائل الجديدة',
      importance: Importance.high,
      priority: Priority.high,
      sound: RawResourceAndroidNotificationSound('default'),
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: notificationDetails,
      payload: payload,
    );
  }

  // معالجة الضغط على الإشعار
  static void _onNotificationTap(NotificationResponse response) {
    final String? payload = response.payload;
    if (payload != null) {
      print('📱 User tapped notification: $payload');
      // هنا ممكن تضيفي منطق للتنقل لشاشة المحادثة
    }
  }
}