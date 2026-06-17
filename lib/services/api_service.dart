

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:onboard/models/user_model.dart';

class ApiService {
  static const String baseUrl = 'https://projecthubb.runasp.net';

  /// بناء رابط افتراضي (قد لا يكون صحيحاً لأن الخادم يستخدم UUID عشوائي)
  static String buildProfileImageUrl(
    String userId, {
    String extension = 'jpg',
  }) {
    return '$baseUrl/uploads/users/$userId.$extension';
  }

  /// البحث عن الصورة بالامتدادات المختلفة
  static Future<String?> findImageUrl(String userId) async {
    final extensions = ['jpg', 'png', 'jpeg', 'heic', 'webp'];

    for (final ext in extensions) {
      final url = buildProfileImageUrl(userId, extension: ext);
      try {
        final response = await http.head(Uri.parse(url));
        if (response.statusCode == 200) {
          print('✅ Found image with extension: $ext');
          return url;
        }
      } catch (e) {
        print('⚠️ Error checking image: $e');
      }
    }
    print('❌ No image found for user: $userId');
    return null;
  }

  /// ✅ الحصول على الرابط الفعلي من الخادم (الأكثر دقة)
  Future<String?> getUserProfileImageUrl(String userId) async {
    try {
      final url = Uri.parse('$baseUrl/api/Auth/profile-image/$userId');
      final response = await http.get(url);

      print('📸 Fetching profile image for user: $userId');
      print('📸 Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        try {
          final responseData = jsonDecode(response.body);
          print('📸 Full response: $responseData');

          if (responseData is Map<String, dynamic>) {
            final imageUrl = responseData['profileImage'] ??
                responseData['imageUrl'] ??
                responseData['url'] ??
                responseData['data'] ??
                responseData['picture'] ??
                responseData['photoUrl'];

            if (imageUrl != null && imageUrl.isNotEmpty) {
              if (imageUrl is String) {
                // إذا كان الرابط نسبياً، أضف الـ base URL
                if (imageUrl.startsWith('/')) {
                  return '$baseUrl$imageUrl';
                }
                print('✅ Got image URL: $imageUrl');
                return imageUrl;
              }
            }
          }
        } catch (e) {
          final body = response.body.trim();
          print('📸 Raw response body: $body');
          if (body.startsWith('http')) {
            print('✅ Got image URL from text response: $body');
            return body;
          }
        }
      } else {
        print('❌ Failed to get profile image: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error fetching profile image: $e');
    }
    return null;
  }

  /// ✅ مزامنة المستخدم مع الصورة (للتسجيل)
  Future<Map<String, dynamic>?> syncUserWithImageToBackend({
    required UserModel user,
    required File? imageFile,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/api/Auth/sync');
      final request = http.MultipartRequest('POST', url);

      request.fields['Id'] = user.uid;
      request.fields['FullName'] = user.fullName;
      request.fields['Email'] = user.email;
      request.fields['Role'] = _getRoleString(user.role);
      request.fields['Instituation'] = user.university ?? user.department ?? 'Not specified';
      request.fields['Faculty'] = user.faculty ?? user.position ?? 'Not specified';
      request.fields['Track'] = user.track ?? 'General';

      String extension = 'jpg';
      if (imageFile != null && await imageFile.exists()) {
        final stream = http.ByteStream(imageFile.openRead());
        final length = await imageFile.length();

        extension = _getFileExtension(imageFile.path);
        final mimeType = _getMimeType(extension);

        final multipartFile = http.MultipartFile(
          'Picture',
          stream,
          length,
          filename: 'profile_${user.uid}.$extension',
          contentType: MediaType.parse(mimeType),
        );
        request.files.add(multipartFile);
        print('📸 Image added: ${imageFile.path} (type: $mimeType)');
      } else {
        print('⚠️ No image provided, skipping backend sync');
        return {
          'success': true,
          'imageUrl': null,
          'message': 'No image to sync',
        };
      }

      print('📤 Sending request to: $url');
      print('📤 Fields: ${request.fields}');
      print('📤 Files count: ${request.files.length}');

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('📥 Response status: ${response.statusCode}');
      print('📥 Response body: ${response.body}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        // ✅ محاولة الحصول على الرابط الفعلي من الخادم (الأهم)
        String? imageUrl = await getUserProfileImageUrl(user.uid);
        if (imageUrl == null || imageUrl.isEmpty) {
          // في حالة عدم العثور، حاول البحث بالامتدادات
          imageUrl = await findImageUrl(user.uid);
        }

        if (imageUrl == null || imageUrl.isEmpty) {
          // في حالة عدم العثور، استخدم الرابط المبني (لكن قد لا يكون صحيحاً)
          imageUrl = buildProfileImageUrl(user.uid, extension: extension);
          print('⚠️ Using fallback URL: $imageUrl');
        }

        print('✅ Final image URL: $imageUrl');
        return {
          'success': true,
          'imageUrl': imageUrl,
          'statusCode': response.statusCode,
        };
      } else {
        print('❌ Backend error: ${response.statusCode}');
        return {
          'success': false,
          'error': response.body,
          'imageUrl': null,
          'statusCode': response.statusCode,
        };
      }
    } catch (e) {
      print('❌ Exception in syncUserWithImageToBackend: $e');
      return {
        'success': false,
        'error': e.toString(),
        'imageUrl': null,
      };
    }
  }

  /// ✅ مزامنة المستخدم (بدون صورة)
  Future<Map<String, dynamic>> syncUserToBackend(UserModel user) async {
    if (user.photoUrl == null || user.photoUrl!.isEmpty) {
      print('⚠️ No profile image found, skipping backend sync');
      return {
        'success': true,
        'skipped': true,
        'message': 'No image to sync',
      };
    }

    try {
      final url = Uri.parse('$baseUrl/api/Auth/sync');
      final request = http.MultipartRequest('POST', url);

      request.fields['Id'] = user.uid;
      request.fields['FullName'] = user.fullName;
      request.fields['Email'] = user.email;
      request.fields['Role'] = _getRoleString(user.role);
      request.fields['Instituation'] = user.university ?? user.department ?? 'Not specified';
      request.fields['Faculty'] = user.faculty ?? user.position ?? 'Not specified';
      request.fields['Track'] = user.track ?? 'General';

      print('📤 Syncing user data to backend:');
      print('   ID: ${user.uid}');
      print('📤 Fields: ${request.fields}');
      print('📤 Files count: ${request.files.length}');

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('📥 Response: ${response.statusCode}');
      print('📥 Body: ${response.body}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return {
          'success': true,
          'statusCode': response.statusCode,
          'data': response.body,
        };
      } else {
        if (response.statusCode == 500) {
          print('⚠️ Server error (500), skipping sync');
          return {
            'success': true,
            'skipped': true,
            'message': 'Server error, skipping sync',
          };
        }
        return {
          'success': false,
          'statusCode': response.statusCode,
          'error': response.body.isNotEmpty ? response.body : 'Unknown error',
        };
      }
    } catch (e) {
      print('❌ Failed to sync with backend: $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// ✅ تحديث البروفايل مع الصورة
  Future<Map<String, dynamic>?> updateProfile({
    required String userId,
    required String fullName,
    required String bio,
    String? university,
    String? position,
    String? department,
    File? imageFile,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/api/Auth/edit-profile');
      final request = http.MultipartRequest('PUT', url);

      request.fields['Id'] = userId;
      request.fields['FullName'] = fullName;
      request.fields['Bio'] = bio;

      if (university != null && university.isNotEmpty) {
        request.fields['University'] = university;
      } else if (department != null && department.isNotEmpty) {
        request.fields['University'] = department;
      } else {
        request.fields['University'] = 'Not specified';
      }

      if (imageFile != null && await imageFile.exists()) {
        final stream = http.ByteStream(imageFile.openRead());
        final length = await imageFile.length();
        final extension = _getFileExtension(imageFile.path);
        final mimeType = _getMimeType(extension);

        final multipartFile = http.MultipartFile(
          'Picture',
          stream,
          length,
          filename: 'profile_$userId.$extension',
          contentType: MediaType.parse(mimeType),
        );
        request.files.add(multipartFile);
        print('📸 Updating profile image: ${imageFile.path} (size: $length bytes)');
      } else {
        print('⚠️ No image file provided');
        return {
          'success': false,
          'error': 'No image file provided',
          'imageUrl': null,
        };
      }

      print('📤 Sending update profile request...');
      print('📤 Fields: ${request.fields}');
      print('📤 Files count: ${request.files.length}');

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('📥 Update profile response: ${response.statusCode}');
      print('📥 Body: ${response.body}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        // ✅ محاولة الحصول على الرابط الفعلي من الخادم
        String? imageUrl = await getUserProfileImageUrl(userId);
        if (imageUrl == null || imageUrl.isEmpty) {
          imageUrl = await findImageUrl(userId);
        }

        print('✅ Final image URL: $imageUrl');
        return {
          'success': true,
          'imageUrl': imageUrl,
          'statusCode': response.statusCode,
        };
      } else {
        print('❌ Update profile failed: ${response.statusCode}');
        return {
          'success': false,
          'error': response.body,
          'imageUrl': null,
          'statusCode': response.statusCode,
        };
      }
    } catch (e) {
      print('❌ Error updating profile: $e');
      return {
        'success': false,
        'error': e.toString(),
        'imageUrl': null,
      };
    }
  }

  // ==================== دوال مساعدة ====================

  String _getRoleString(UserRole role) {
    switch (role) {
      case UserRole.user:
        return 'User';
      case UserRole.supervisor:
        return 'Supervisor';
      case UserRole.assistant:
        return 'assistant';
      default:
        return 'User';
    }
  }

  String _getFileExtension(String path) {
    final fileName = path.split('/').last;
    if (fileName.contains('.')) {
      return fileName.split('.').last.toLowerCase();
    }
    return 'jpg';
  }

  String _getMimeType(String extension) {
    switch (extension.toLowerCase()) {
      case 'png':
        return 'image/png';
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'heic':
        return 'image/heic';
      case 'webp':
        return 'image/webp';
      case 'gif':
        return 'image/gif';
      default:
        return 'image/jpeg';
    }
  }

  Future<bool> verifyImageExists(String imageUrl) async {
    try {
      final response = await http.head(Uri.parse(imageUrl));
      return response.statusCode == 200;
    } catch (e) {
      print('⚠️ Error verifying image: $e');
      return false;
    }
  }
}