import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../entities/document/document_repository.dart';
import '../../entities/document/document.dart';

class OpenEditorFeature {
  static void execute(BuildContext context, AppDocument document, {int editorIndex = 1}) {
    final repo = Provider.of<DocumentRepository>(context, listen: false);
    
    if (editorIndex == 1) {
      repo.selectDocument(document);
    } else {
      repo.selectSecondDocument(document);
    }
    
    repo.incrementViewCount(document);
  }
}