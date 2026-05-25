import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../entities/project/project_repository.dart';
import '../../entities/project/project.dart';
import '../../entities/document/document_repository.dart';

class SelectProjectFeature {
  static void execute(BuildContext context, Project project) {
    final projectRepo = Provider.of<ProjectRepository>(context, listen: false);
    final documentRepo = Provider.of<DocumentRepository>(context, listen: false);
    
    projectRepo.selectProject(project);
    
    if (project.documents.isNotEmpty) {
      final mostUsed = project.documents.reduce((a, b) => a.viewCount > b.viewCount ? a : b);
      documentRepo.selectDocument(mostUsed);
      documentRepo.incrementViewCount(mostUsed);
    }
  }
}