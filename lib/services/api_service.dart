
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:onboard/models/user_model.dart';

class ApiService {
  static const String baseUrl = 'https://projecthubb.runasp.net';

  static String buildProfileImageUrl(
    String userId, {
    String extension = 'jpg',
  }) {
    return 'https://projecthubb.runasp.net/uploads/users/$userId.$extension';
  }

  
  static Future<String?> findImageUrl(String userId) async {
    final extensions = ['jpg', 'png', 'jpeg', 'heic'];

    for (final ext in extensions) {
      final url = buildProfileImageUrl(userId, extension: ext);
      try {
        final response = await http.head(Uri.parse(url));
        if (response.statusCode == 200) {
          print('--------------Found image with extension: $ext');
          return url;
        }
      } catch (e) {
        print('--------------Error occurred while checking image: $e');
      }
    }
    print('-------------- No image found for user: $userId');
    return null;
  }


  Future<String?> getUserProfileImageUrl(String userId) async {
    try {
      final url = Uri.parse('$baseUrl/api/Auth/profile-image/$userId');
      final response = await http.get(url);

      print('-------------- Fetching profile image for user: $userId');
      print('-------------- Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        try {
          final responseData = jsonDecode(response.body);
          print('-------------- Full response: $responseData');

          
          if (responseData is Map<String, dynamic>) {
            final imageUrl =
                responseData['profileImage'] ??
                responseData['imageUrl'] ??
                responseData['url'];
            if (imageUrl != null && imageUrl.isNotEmpty) {
              print('-------------- Got image URL: $imageUrl');
              return imageUrl;
            }
          }
        } catch (e) {
          final body = response.body.trim();
          print('------------ Raw response body: $body');
          if (body.startsWith('http')) {
            print('------------ Got image URL from text response: $body');
            return body;
          }
        }
      } else {
        print('------------ Failed to get profile image: ${response.statusCode}');
      }
    } catch (e) {
      print('-------------- Error fetching profile image: $e');
    }
    return null;
  }


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
      request.fields['Role'] = user.role.value;
      request.fields['Instituation'] =
          user.university ?? user.department ?? 'Not specified';
      request.fields['Faculty'] =
          user.faculty ?? user.position ?? 'Not specified';
      request.fields['Track'] = user.track ?? 'General';

      String extension = 'jpg';
      if (imageFile != null && await imageFile.exists()) {
        final stream = http.ByteStream(imageFile.openRead());
        final length = await imageFile.length();

        if (imageFile.path.endsWith('.png')) {
          extension = 'png';
        } else if (imageFile.path.endsWith('.jpg') ||
            imageFile.path.endsWith('.jpeg')) {
          extension = 'jpg';
        } else if (imageFile.path.endsWith('.heic')) {
          extension = 'heic';
        }

        String mimeType = 'image/jpeg';
        if (extension == 'png') {
          mimeType = 'image/png';
        } else if (extension == 'heic') {
          mimeType = 'image/heic';
        }

        final multipartFile = http.MultipartFile(
          'Picture',
          stream,
          length,
          filename: imageFile.path.split('/').last,
          contentType: MediaType.parse(mimeType),
        );
        request.files.add(multipartFile);
        print('📸 Image added: ${imageFile.path}');
      }

      print('-------------- Request fields: ${request.fields}');
      print('-------------- Request files count: ${request.files.length}');

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('-------------- Response status: ${response.statusCode}');
      print('-------------- Response body: ${response.body}');

      if (response.statusCode >= 200 && response.statusCode < 300) {

        String? imageUrl = buildProfileImageUrl(user.uid, extension: extension);

        
        final endpointUrl = await getUserProfileImageUrl(user.uid);
        if (endpointUrl != null && endpointUrl.isNotEmpty) {
          imageUrl = endpointUrl;
        }

      
        try {
          final checkResponse = await http.head(Uri.parse(imageUrl));
          if (checkResponse.statusCode != 200) {
            final foundUrl = await findImageUrl(user.uid);
            if (foundUrl != null) {
              imageUrl = foundUrl;
            }
          }
        } catch (e) {
          print('-------------- Could not verify image: $e');
        }

        print('-------------- Final image URL: $imageUrl');
        return {'success': true, 'imageUrl': imageUrl};
      } else {
        print('-------------- Backend error: ${response.statusCode}');
        return {'success': false, 'error': response.body, 'imageUrl': null};
      }
    } catch (e) {
      print('-------------- Exception: $e');
      return {'success': false, 'error': e.toString(), 'imageUrl': null};
    }
  }

  
  Future<bool> syncUserToBackend(UserModel user) async {
    try {
      final url = Uri.parse('$baseUrl/api/Auth/sync');
      final request = http.MultipartRequest('POST', url);

      request.fields['Id'] = user.uid;
      request.fields['FullName'] = user.fullName;
      request.fields['Email'] = user.email;
      request.fields['Role'] = user.role.value;
      request.fields['Instituation'] =
          user.university ?? user.department ?? 'Not specified';
      request.fields['Faculty'] =
          user.faculty ?? user.position ?? 'Not specified';
      request.fields['Track'] = user.track ?? 'General';

      final response = await request.send();

      print('-------------- Syncing user data to backend:');
      print('   ID: ${user.uid}');
      print('-------------- Response: ${response.statusCode}');

      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (e) {
      print('-------------- Failed to sync with backend: $e');
      return false;
    }
  }
}
