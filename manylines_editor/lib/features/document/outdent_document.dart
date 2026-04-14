import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../entities/document/document_repository.dart';
import '../../entities/project/project_repository.dart';

class OutdentDocumentFeature {
  static void execute(BuildContext context, int index) {
    final projectRepo = Provider.of<ProjectRepository>(context, listen: false);
    final documentRepo = Provider.of<DocumentRepository>(context, listen: false);
    
    if (projectRepo.selectedProject == null) return;
    
    final docs = projectRepo.selectedProject!.documents;
    if (index >= 0 && index < docs.length) {
      documentRepo.outdentDocument(docs[index].id);
    }
  }
}