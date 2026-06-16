import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  
  // متغير لتخزين callback للتنقل عند الضغط على الإشعار
  static Function(String)? onNotificationTap;

  // طلب إذن الإشعارات
  static Future<void> requestPermission() async {
    if (Platform.isAndroid) {
      final androidPlugin = _localNotifications.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
      >();
      
      final bool? granted = await androidPlugin?.requestNotificationsPermission();
      print('📱 Notification permission granted: $granted');
    }
  }

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
    
    // ✅ إنشاء قناة الإشعارات (لأندرويد 8+)
    if (Platform.isAndroid) {
      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        'chat_channel',
        'Chat Notifications',
        description: 'إشعارات الرسائل الجديدة',
        importance: Importance.high,
        // ✅ تم إزالة priority لأنها مش موجودة في الإصدارات الجديدة
      );
      
      await _localNotifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);
    }
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
      // ✅ تم إزالة priority لأنها مش موجودة في الإصدارات الجديدة
      playSound: true,
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
    print('📱 User tapped notification: $payload');
    
    if (onNotificationTap != null && payload != null) {
      onNotificationTap!(payload);
    }
  }
  
  // تسجيل callback للتنقل
  static void setOnNotificationTap(Function(String) callback) {
    onNotificationTap = callback;
  }
}