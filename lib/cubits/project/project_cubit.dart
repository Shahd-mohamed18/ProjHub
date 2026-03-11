import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/project_model.dart';

part 'project_state.dart';

class ProjectCubit extends Cubit<ProjectState> {
  ProjectCubit() : super(const ProjectState());

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // تحميل المشاريع من Firestore
  Future<void> loadProjects() async {
    emit(state.copyWith(status: ProjectStatus.loading));
    
    try {
      QuerySnapshot snapshot = await _firestore.collection('projects').get();
      
      List<Project> projects = snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return Project.fromFirestore(doc.id, data);
      }).toList();

      emit(state.copyWith(
        status: ProjectStatus.success,
        projects: projects,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ProjectStatus.error,
        errorMessage: 'Error loading projects: $e',
      ));
    }
  }

  // تحميل مشاريع مستخدم معين
  Future<void> loadUserProjects(String userId) async {
    emit(state.copyWith(status: ProjectStatus.loading));
    
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('projects')
          .where('authorId', isEqualTo: userId)
          .get();
      
      List<Project> projects = snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return Project.fromFirestore(doc.id, data);
      }).toList();

      emit(state.copyWith(
        status: ProjectStatus.success,
        projects: projects,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ProjectStatus.error,
        errorMessage: 'Error loading user projects: $e',
      ));
    }
  }

  // إضافة مشروع جديد
  Future<void> addProject(Project project) async {
    emit(state.copyWith(status: ProjectStatus.loading));

    try {
      await _firestore.collection('projects').doc(project.id).set(project.toJson());

      final updatedProjects = List<Project>.from(state.projects)..add(project);
      
      emit(state.copyWith(
        status: ProjectStatus.success,
        projects: updatedProjects,
        successMessage: 'Project added successfully!',
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ProjectStatus.error,
        errorMessage: 'Error adding project: $e',
      ));
    }
  }

  // حذف مشروع
  Future<void> deleteProject(String projectId) async {
    emit(state.copyWith(status: ProjectStatus.loading));

    try {
      await _firestore.collection('projects').doc(projectId).delete();

      final updatedProjects = state.projects.where((p) => p.id != projectId).toList();
      
      emit(state.copyWith(
        status: ProjectStatus.success,
        projects: updatedProjects,
        successMessage: 'Project deleted successfully!',
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ProjectStatus.error,
        errorMessage: 'Error deleting project: $e',
      ));
    }
  }

  // تحديث مشروع
  Future<void> updateProject(Project updatedProject) async {
    emit(state.copyWith(status: ProjectStatus.loading));

    try {
      await _firestore.collection('projects').doc(updatedProject.id).update(updatedProject.toJson());

      final index = state.projects.indexWhere((p) => p.id == updatedProject.id);
      if (index != -1) {
        final updatedProjects = List<Project>.from(state.projects);
        updatedProjects[index] = updatedProject;
        
        emit(state.copyWith(
          status: ProjectStatus.success,
          projects: updatedProjects,
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

  // تحديث حالة المشروع المحدد
  void selectProject(Project project) {
    emit(state.copyWith(selectedProject: project));
  }

  // مسح الرسائل
  void clearMessages() {
    emit(state.copyWith(
      errorMessage: null,
      successMessage: null,
    ));
  }
}