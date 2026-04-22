
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:onboard/models/user_model.dart';

class ApiService {
  static const String baseUrl = 'https://projecthubb.runasp.net';
  
  // ده المسؤول عن إرسال بيانات اليوزر للباك اند
  Future<bool> syncUserToBackend(UserModel user) async {
    try {
      final url = Uri.parse('$baseUrl/api/Auth/sync');
      
      final payload = user.toApiJson();
      
      print('📤 Sending user to backend:');
      print('   UID: ${payload['uid']}');
      print('   Name: ${payload['fullName']}');
      print('   Email: ${payload['email']}');
      print('   Role: ${payload['role']}');
      print('   University: ${payload['university']}');
      print('   Faculty: ${payload['faculty']}');
      print('   Track: ${payload['track']}');
      print('   Picture: ${payload['picture']}');  // هتكون empty string
      
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': '*/*',
        },
        body: jsonEncode(payload),
      );
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        print('✅ User synced successfully with backend');
        return true;
      } else {
        print('❌ Backend error: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      // مش هنفشل الـ sign up لو الباك اند وقع
      // بس هنطبع الخطأ عشان نعرف المشكلة
      print('⚠️ Failed to sync with backend (non-critical): $e');
      return false;
    }
  }
}