import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../entities/document/document.dart';
import '../../entities/document/document_repository.dart';
import '../../entities/project/project_repository.dart';

class IndentDocumentFeature {
  static void execute(BuildContext context, int index) {
    final projectRepo = Provider.of<ProjectRepository>(context, listen: false);
    final documentRepo = Provider.of<DocumentRepository>(context, listen: false);
    
    if (projectRepo.selectedProject == null || index <= 0) return;
    
    final docs = projectRepo.selectedProject!.documents;
    AppDocument? parentDoc;
    
    for (int i = index - 1; i >= 0; i--) {
      if (docs[i].parentId == null && !docs[i].isPinned) {
        parentDoc = docs[i];
        break;
      }
    }
    
    if (parentDoc != null) {
      documentRepo.indentDocument(docs[index].id, parentDoc.id);
    }
  }
}