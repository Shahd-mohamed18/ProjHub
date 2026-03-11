part of 'project_cubit.dart';

enum ProjectStatus { initial, loading, success, error }

class ProjectState {
  final ProjectStatus status;
  final List<Project> projects;
  final String? errorMessage;
  final Project? selectedProject;
  final String? successMessage;

  const ProjectState({
    this.status = ProjectStatus.initial,
    this.projects = const [],
    this.errorMessage,
    this.selectedProject,
    this.successMessage,
  });

  ProjectState copyWith({
    ProjectStatus? status,
    List<Project>? projects,
    String? errorMessage,
    Project? selectedProject,
    String? successMessage,
  }) {
    return ProjectState(
      status: status ?? this.status,
      projects: projects ?? this.projects,
      errorMessage: errorMessage ?? this.errorMessage,
      selectedProject: selectedProject ?? this.selectedProject,
      successMessage: successMessage ?? this.successMessage,
    );
  }

  List<Project> getProjectsByCategory(String category) {
    if (category == 'All') return projects;
    return projects.where((project) => project.category == category).toList();
  }

  List<Project> getProjectsByUser(String userId) {
    return projects.where((project) => project.authorId == userId).toList();
  }

  Project? getProjectById(String id) {
    try {
      return projects.firstWhere((project) => project.id == id);
    } catch (e) {
      return null;
    }
  }
}
