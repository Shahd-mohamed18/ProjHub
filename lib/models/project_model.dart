// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';

import 'package:image_picker/image_picker.dart';

class ProjectModel {
  List<XFile> projectImages;
  String projectTitle;
  String descreption;
  String tags;
  String catecory;
  String githubLink;
  File document; 
  ProjectModel({
    required this.projectImages,
    required this.projectTitle,
    required this.descreption,
    required this.tags,
    required this.catecory,
    required this.githubLink,
    required this.document,
  });

  
}
