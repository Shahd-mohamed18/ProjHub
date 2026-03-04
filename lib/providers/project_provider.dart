import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:onboard/models/project_model.dart';

class ProjectProvider extends ChangeNotifier {
  List<Project> _projects = [];
  bool _isLoading = false;

  List<Project> get projects => _projects;
  bool get isLoading => _isLoading;

  ProjectProvider() {
    loadProjects();
  }

  Future<void> loadProjects() async {
    _isLoading = true;
    notifyListeners();

    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('projects')
          .orderBy('createdAt', descending: true)
          .get();

      _projects = querySnapshot.docs.map((doc) {
        return Project.fromJson(doc.data());
      }).toList();

      print('✅ Loaded ${_projects.length} projects from Firebase');
    } catch (e) {
      print('❌ Error loading projects: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addProject(Project project) async {
    _isLoading = true;
    notifyListeners();

    try {
      await FirebaseFirestore.instance
          .collection('projects')
          .doc(project.id)
          .set(project.toJson());

      _projects.insert(0, project);
      
      print('✅ Project added to Firebase: ${project.title}');
    } catch (e) {
      print('❌ Error adding project: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteProject(String projectId) async {
    try {
      await FirebaseFirestore.instance
          .collection('projects')
          .doc(projectId)
          .delete();

      _projects.removeWhere((p) => p.id == projectId);
      notifyListeners();
    } catch (e) {
      print('❌ Error deleting project: $e');
      rethrow;
    }
  }

  List<Project> getProjectsByCategory(String category) {
    if (category == 'All') {
      return _projects;
    }
    return _projects.where((p) => p.category == category).toList();
  }

  List<Project> getProjectsByUser(String userId) {
    return _projects.where((p) => p.authorId == userId).toList();
  }

  void subscribeToProjects() {
    FirebaseFirestore.instance
        .collection('projects')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen((snapshot) {
      _projects = snapshot.docs.map((doc) {
        return Project.fromJson(doc.data());
      }).toList();
      notifyListeners();
    });
  }
}