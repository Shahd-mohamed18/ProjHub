
import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/project_model.dart';
import '../../services/project_api_service.dart';

part 'project_state.dart';

class ProjectCubit extends Cubit<ProjectState> {
  ProjectCubit() : super(const ProjectState());

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ProjectApiService _apiService = ProjectApiService();

  
  Future<void> loadProjects() async {
    emit(state.copyWith(status: ProjectStatus.loading));

    try {
      final backendProjects = await _apiService.fetchProjects();
      
      List<Project> projects = backendProjects.map((bp) {
        return Project(
          id: bp['id'].toString(),
          title: bp['title'] ?? '',
          description: bp['description'] ?? '',
          authorId: bp['authorId'] ?? '',
          authorName: bp['authorName'] ?? '',
          userImage: bp['UserImage'], 
          images: List<String>.from(bp['images'] ?? []),
          tags: List<String>.from(bp['tags'] ?? []),
          category: bp['category'] ?? '',
          documentUrl: bp['documentUrl'] ?? '',
          githubUrl: bp['githubUrl'],
          createdAt: DateTime.parse(bp['createdAt'] ?? DateTime.now().toIso8601String()),
        );
      }).toList();

      emit(state.copyWith(status: ProjectStatus.success, projects: projects));
      _updateFirebaseCache(projects);
      
    } catch (e) {
      print('--------- Backend failed, trying Firebase fallback: $e');
      try {
        final snapshot = await _firestore
            .collection('projects')
            .orderBy('createdAt', descending: true)
            .get();

        List<Project> projects = snapshot.docs.map((doc) {
          return Project.fromFirestore(doc.id, doc.data() as Map<String, dynamic>);
        }).toList();

        emit(state.copyWith(status: ProjectStatus.success, projects: projects));
      } catch (firebaseError) {
        emit(state.copyWith(
          status: ProjectStatus.error,
          errorMessage: 'Error loading projects: $e',
        ));
      }
    }
  }

  
  Future<void> _updateFirebaseCache(List<Project> projects) async {
    try {
      final snapshot = await _firestore.collection('projects').get();
      final existingIds = snapshot.docs.map((doc) => doc.id).toSet();
      final newIds = projects.map((p) => p.id).toSet();

      for (var doc in snapshot.docs) {
        if (!newIds.contains(doc.id)) {
          await _firestore.collection('projects').doc(doc.id).delete();
          print('---------- Removed old project from cache: ${doc.id}');
        }
      }

      for (var project in projects) {
        final firestoreData = project.toFirestore();
        firestoreData['backendId'] = int.tryParse(project.id);
        await _firestore
            .collection('projects')
            .doc(project.id)
            .set(firestoreData);
      }
      print('---------- Updated Firebase cache with ${projects.length} projects');
    } catch (e) {
      print('---------- Failed to update Firebase cache: $e');
    }
  }

  Future<void> loadUserProjects(String userId) async {
    emit(state.copyWith(status: ProjectStatus.loading));

    try {
      final backendProjects = await _apiService.fetchUserProjects(userId);
      
      List<Project> projects = backendProjects.map((bp) {
        return Project(
          id: bp['id'].toString(),
          title: bp['title'] ?? '',
          description: bp['description'] ?? '',
          authorId: bp['authorId'] ?? '',
          authorName: bp['authorName'] ?? '',
          userImage: bp['UserImage'], 
          images: List<String>.from(bp['images'] ?? []),
          tags: List<String>.from(bp['tags'] ?? []),
          category: bp['category'] ?? '',
          documentUrl: bp['documentUrl'] ?? '',
          githubUrl: bp['githubUrl'],
          createdAt: DateTime.parse(bp['createdAt'] ?? DateTime.now().toIso8601String()),
        );
      }).toList();

      emit(state.copyWith(status: ProjectStatus.success, projects: projects));
      
    } catch (e) {
      print('---------- Backend failed for user projects: $e');
      try {
        final snapshot = await _firestore
            .collection('projects')
            .where('authorId', isEqualTo: userId)
            .orderBy('createdAt', descending: true)
            .get();

        List<Project> projects = snapshot.docs.map((doc) {
          return Project.fromFirestore(doc.id, doc.data() as Map<String, dynamic>);
        }).toList();

        emit(state.copyWith(status: ProjectStatus.success, projects: projects));
      } catch (firebaseError) {
        emit(state.copyWith(
          status: ProjectStatus.error,
          errorMessage: 'Error loading user projects: $e',
        ));
      }
    }
  }

  
  Future<void> addProject({
    required String title,
    required String description,
    required String tags,
    required String category,
    required String githubUrl,
    required File coverPhoto,
    required File projectDocument,
    required String authorId,
    required String authorName,
    List<File>? additionalImages,
  }) async {
    emit(state.copyWith(status: ProjectStatus.loading));

    try {
      final response = await _apiService.uploadProject(
        title: title,
        description: description,
        tags: tags,
        category: category,
        gitHubUrl: githubUrl,
        coverPhoto: coverPhoto,
        projectDocument: projectDocument,
        authorId: authorId,
        additionalImages: additionalImages,
      );

      List<String> imageUrls = [];
      if (response['images'] != null && response['images'] is List) {
        imageUrls = List<String>.from(response['images']);
      } else if (response['imageUrls'] != null && response['imageUrls'] is List) {
        imageUrls = List<String>.from(response['imageUrls']);
      }

      String documentUrl = response['documentUrl'] ?? '';
      int backendId = response['id'] ?? 0;
      String? userImage = response['UserImage']; 

      List<String> tagsList = tags
          .split(',')
          .map((tag) => tag.trim())
          .where((tag) => tag.isNotEmpty)
          .toList();

      final newProject = Project(
        id: backendId.toString(),
        title: title,
        description: description,
        authorId: authorId,
        authorName: authorName,
        userImage: userImage,
        images: imageUrls,
        tags: tagsList.isEmpty ? ['General'] : tagsList,
        category: category,
        documentUrl: documentUrl,
        githubUrl: githubUrl.isNotEmpty ? githubUrl : null,
        createdAt: DateTime.now(),
      );
      

      final firestoreData = newProject.toFirestore();
      firestoreData['backendId'] = backendId;
      await _firestore.collection('projects').doc(newProject.id).set(firestoreData);

      final updatedProjects = List<Project>.from(state.projects)..insert(0, newProject);

      emit(state.copyWith(
        status: ProjectStatus.success,
        projects: updatedProjects,
        successMessage: '---------- Project uploaded successfully!',
      ));
      await loadProjects();
      
    } catch (e) {
      emit(state.copyWith(
        status: ProjectStatus.error,
        errorMessage: 'Upload failed: ${e.toString()}',
      ));
    }
  }

  
  Future<void> updateProject(Project updatedProject) async {
    emit(state.copyWith(status: ProjectStatus.loading));
    
    try {
      final backendId = int.tryParse(updatedProject.id);
      if (backendId != null) {
        await _apiService.updateProject(
          id: backendId,
          title: updatedProject.title,
          description: updatedProject.description,
          tags: updatedProject.tags.join(','),
          category: updatedProject.category,
          gitHubUrl: updatedProject.githubUrl ?? '',
        );
      }
      
      await _firestore
          .collection('projects')
          .doc(updatedProject.id)
          .update(updatedProject.toFirestore());

      final index = state.projects.indexWhere((p) => p.id == updatedProject.id);
      if (index != -1) {
        final updatedProjects = List<Project>.from(state.projects);
        updatedProjects[index] = updatedProject;
        emit(state.copyWith(
          status: ProjectStatus.success,
          projects: updatedProjects,
          successMessage: '---------- Project updated successfully!',
        ));
      } else {
        emit(state.copyWith(
          status: ProjectStatus.success,
          successMessage: 'Project updated successfully!',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: ProjectStatus.error,
        errorMessage: 'Error updating project: $e',
      ));
    }
  }

  
  
Future<void> deleteProject(String projectId) async {
  emit(state.copyWith(status: ProjectStatus.loading));
  
  try {
    final backendId = int.tryParse(projectId);
    if (backendId != null) {
      
      final project = state.projects.firstWhere((p) => p.id == projectId);
      await _apiService.deleteProject(backendId, project.authorId);
      print('---------- Deleted from backend: $backendId');
    }
    
    await _firestore.collection('projects').doc(projectId).delete();
    print('---------- Deleted from Firebase: $projectId');

    final updatedProjects = state.projects.where((p) => p.id != projectId).toList();
    
    emit(state.copyWith(
      status: ProjectStatus.success,
      projects: updatedProjects,
      successMessage: '---------- Project deleted successfully!',
    ));
    
  } catch (e) {
    print('---------- Delete error: $e');
    emit(state.copyWith(
      status: ProjectStatus.error,
      errorMessage: 'Error deleting project: ${e.toString()}',
    ));
  }
}

  Future<void> openProjectDocument(String documentUrl) async {
    try {
      await _apiService.openPdf(documentUrl);
    } catch (e) {
      emit(state.copyWith(
        status: ProjectStatus.error,
        errorMessage: 'Error opening document: $e',
      ));
    }
  }

  void selectProject(Project project) {
    emit(state.copyWith(selectedProject: project));
  }

  void clearMessages() {
    emit(state.copyWith(errorMessage: null, successMessage: null));
  }
}