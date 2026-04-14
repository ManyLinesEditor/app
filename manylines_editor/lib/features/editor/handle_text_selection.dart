import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:provider/provider.dart';
import '../../entities/document/document_repository.dart';

class HandleTextSelectionFeature {
  static void execute(BuildContext context, quill.QuillController? controller) {
    if (controller == null) return;
    
    final selection = controller.selection;
    if (selection.isCollapsed) return;
    
    final text = controller.document.toPlainText();
    if (selection.baseOffset >= text.length || selection.extentOffset >= text.length) return;
    
    final start = selection.baseOffset < selection.extentOffset 
        ? selection.baseOffset : selection.extentOffset;
    final end = selection.baseOffset < selection.extentOffset 
        ? selection.extentOffset : selection.baseOffset;
    
    final selectedText = text.substring(start, end);
    
    if (selectedText.trim().isNotEmpty) {
      final repo = Provider.of<DocumentRepository>(context, listen: false);
      repo.setSelectedTextForGlossary(selectedText.trim());
      repo.openGlossaryPanel();
    }
  }
}