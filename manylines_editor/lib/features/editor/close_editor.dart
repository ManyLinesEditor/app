import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../entities/document/document_repository.dart';

class CloseEditorFeature {
  static void execute(BuildContext context, {int editorIndex = 1}) {
    final repo = Provider.of<DocumentRepository>(context, listen: false);
    
    if (editorIndex == 1) {
      repo.closeFirstEditor();
    } else {
      repo.closeSecondEditor();
    }
  }
}