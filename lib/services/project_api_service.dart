
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:open_file/open_file.dart';
import 'package:url_launcher/url_launcher_string.dart';

class ProjectApiService {
  static const String baseUrl = 'https://projecthubb.runasp.net';

  late final Dio _dio;

  ProjectApiService() {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(minutes: 5),
      receiveTimeout: const Duration(minutes: 5),
      sendTimeout: const Duration(minutes: 5),
      headers: {
        'Accept': 'application/json',
      },
    ));
  }

  Future<Map<String, dynamic>> uploadProject({
    required String title,
    required String description,
    required String tags,
    required String category,
    required String gitHubUrl,
    required File coverPhoto,
    required File projectDocument,
    required String authorId,
    List<File>? additionalImages,
  }) async {
    try {
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print(' Uploading to: $baseUrl/api/Projects/upload');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      final formData = FormData();

      formData.fields.addAll([
        MapEntry('Title', title),
        MapEntry('Description', description),
        MapEntry('Tags', tags),
        MapEntry('Category', category),
        MapEntry('GitHubUrl', gitHubUrl.isEmpty ? '' : gitHubUrl),
        MapEntry('AuthorId', authorId),
      ]);

      formData.files.add(
        MapEntry(
          'ProjectDocument',
          await MultipartFile.fromFile(
            projectDocument.path,
            filename: projectDocument.path.split('/').last,
          ),
        ),
      );

      formData.files.add(
        MapEntry(
          'CoverPhoto',
          await MultipartFile.fromFile(
            coverPhoto.path,
            filename: coverPhoto.path.split('/').last,
          ),
        ),
      );

      if (additionalImages != null && additionalImages.isNotEmpty) {
        for (var img in additionalImages) {
          if (await img.exists()) {
            formData.files.add(
              MapEntry(
                'CoverPhoto',
                await MultipartFile.fromFile(
                  img.path,
                  filename: img.path.split('/').last,
                ),
              ),
            );
          }
        }
      }

      print('-------Total files: ${formData.files.length}');

      final response = await _dio.post(
        '/api/Projects/upload',
        data: formData,
        options: Options(
          headers: {'Content-Type': 'multipart/form-data'},
        ),
      );

      print('----------Response status: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data as Map<String, dynamic>;
      }
      throw Exception('Upload failed');
    } catch (e) {
      print('---------- Upload error: $e');
      rethrow;
    }
  }

  
  Future<List<Map<String, dynamic>>> fetchProjects() async {
    try {
      final response = await _dio.get('/api/Projects');
      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(response.data);
      }
      return [];
    } catch (e) {
      print('----------- Fetch error: $e');
      return [];
    }
  }

  
  Future<List<Map<String, dynamic>>> fetchUserProjects(String userId) async {
    try {
      final response = await _dio.get('/api/Projects/my-projects/$userId');
      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(response.data);
      }
      return [];
    } catch (e) {
      print('----------- Fetch user projects error: $e');
      return [];
    }
  }

  
  Future<Map<String, dynamic>> updateProject({
    required int id,
    required String title,
    required String description,
    required String tags,
    required String category,
    required String gitHubUrl,
    File? coverPhoto,
  }) async {
    try {
      final formData = FormData();

      formData.fields.addAll([
        MapEntry('Title', title),
        MapEntry('Description', description),
        MapEntry('Tags', tags),
        MapEntry('Category', category),
        MapEntry('GitHubUrl', gitHubUrl),
        MapEntry('Id', id.toString()),
      ]);

      if (coverPhoto != null && await coverPhoto.exists()) {
        formData.files.add(
          MapEntry(
            'CoverPhoto',
            await MultipartFile.fromFile(coverPhoto.path),
          ),
        );
      }

      final response = await _dio.put(
        '/api/Projects/$id',
        data: formData,
        options: Options(
          headers: {'Content-Type': 'multipart/form-data'},
        ),
      );

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      }
      throw Exception('Update failed');
    } catch (e) {
      print('---------- Update error: $e');
      rethrow;
    }
  }


  
Future<void> deleteProject(int id, String studentId) async {
  try {
    print('------ Deleting project from backend: $id for student: $studentId');
    
    final response = await _dio.delete(
      '/api/Projects/$id',
      queryParameters: {
        'studentId': studentId,
      },
    );
    
    if (response.statusCode == 200) {
      print('--------- Project deleted from backend successfully');
    } else {
      throw Exception('Delete failed with status: ${response.statusCode}');
    }
  } catch (e) {
    print('-------------- Delete error from backend: $e');
    rethrow;
  }
}

  
  Future<void> openPdf(String url) async {
    try {
      print('-------- Opening PDF: $url');
      if (url.startsWith('http')) {
        await launchUrlString(url, mode: LaunchMode.externalApplication);
      } else if (await File(url).exists()) {
        await OpenFile.open(url);
      } else {
        throw Exception('Cannot open PDF');
      }
    } catch (e) {
      print('-------------- Open PDF error: $e');
      rethrow;
    }
  }


  Future<bool> testConnection() async {
    try {
      final response = await _dio.get('/api/Projects');
      return response.statusCode == 200;
    } catch (e) {
      print('-------------- Connection test error: $e');
      return false;
    }
  }
}