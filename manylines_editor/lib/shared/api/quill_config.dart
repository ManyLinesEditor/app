import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;

class QuillConfig {
  static const defaultToolbarConfig = quill.QuillSimpleToolbarConfig(
    showBoldButton: true,
    showItalicButton: true,
    showUnderLineButton: true,
    showStrikeThrough: true,
    showFontSize: true,
    showFontFamily: true,
    showColorButton: true,
    showBackgroundColorButton: true,
    showAlignmentButtons: true,
    showListNumbers: true,
    showListBullets: true,
    showIndent: true,
  );

  static const defaultEditorConfig = quill.QuillEditorConfig(
    placeholder: 'Начните печатать...',
    padding: EdgeInsets.all(16),
  );

  static quill.QuillController createController({
    required dynamic content,
    TextSelection? selection,
  }) {
    return quill.QuillController(
      document: content is quill.Document 
          ? content 
          : quill.Document.fromJson(content?.toJson() ?? {}),
      selection: selection ?? const TextSelection.collapsed(offset: 0),
    );
  }
}