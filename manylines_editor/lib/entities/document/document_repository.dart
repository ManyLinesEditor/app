import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:dart_quill_delta/dart_quill_delta.dart';
import 'document.dart';
import '../glossary_entry/glossary_entry.dart';

class DocumentRepository extends ChangeNotifier {
  AppDocument? _selectedDocument;
  AppDocument? _secondSelectedDocument;
  bool _isGlossaryPanelOpen = false;
  String? _selectedTextForGlossary;

  AppDocument? get selectedDocument => _selectedDocument;
  AppDocument? get secondSelectedDocument => _secondSelectedDocument;
  bool get isGlossaryPanelOpen => _isGlossaryPanelOpen;
  String? get selectedTextForGlossary => _selectedTextForGlossary;

  AppDocument createDocument({
    required String name,
    required Delta content,
    String? parentId,
  }) {
    return AppDocument(
      id: 'd${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      content: content,
      parentId: parentId,
    );
  }

  quill.QuillController getOrCreateController(String documentId) {
    final doc = _findDocument(documentId);
    if (doc == null) {
      return quill.QuillController(
        document: quill.Document(),
        selection: const TextSelection.collapsed(offset: 0),
      );
    }
    
    final controller = quill.QuillController(
      document: quill.Document.fromJson(doc.content.toJson()),
      selection: const TextSelection.collapsed(offset: 0),
    );
    
    controller.changes.listen((change) {
      doc.content = controller.document.toDelta();
      notifyListeners();
    });
    
    return controller;
  }

  void selectDocument(AppDocument document) {
    _selectedDocument = document;
    notifyListeners();
  }

  void selectSecondDocument(AppDocument document) {
    _secondSelectedDocument = document;
    notifyListeners();
  }

  void closeFirstEditor() {
    _selectedDocument = null;
    notifyListeners();
  }

  void closeSecondEditor() {
    _secondSelectedDocument = null;
    notifyListeners();
  }

  void closeEditorIfOpen(String documentId) {
    if (_selectedDocument?.id == documentId) _selectedDocument = null;
    if (_secondSelectedDocument?.id == documentId) _secondSelectedDocument = null;
    notifyListeners();
  }

  void incrementViewCount(AppDocument doc) {
    doc.viewCount++;
    notifyListeners();
  }

  void togglePin(AppDocument doc) {
    doc.isPinned = !doc.isPinned;
    notifyListeners();
  }

  void indentDocument(String documentId, String parentId) {
    final doc = _findDocument(documentId);
    if (doc != null) {
      doc.parentId = parentId;
      notifyListeners();
    }
  }

  void outdentDocument(int index) {
    notifyListeners();
  }

  void addGlossaryEntry(String documentId, GlossaryEntry entry) {
    final doc = _findDocument(documentId);
    if (doc != null) {
      doc.glossary.add(entry);
      notifyListeners();
    }
  }

  void updateGlossaryDefinition(String entryId, String definition) {
    notifyListeners();
  }

  void toggleGlossaryEntry(String entryId) {
    notifyListeners();
  }

  void deleteGlossaryEntry(String entryId) {
    notifyListeners();
  }

  void toggleGlossaryPanel() {
    _isGlossaryPanelOpen = !_isGlossaryPanelOpen;
    notifyListeners();
  }

  void setSelectedTextForGlossary(String text) {
    _selectedTextForGlossary = text;
    notifyListeners();
  }

  void clearSelectedTextForGlossary() {
    _selectedTextForGlossary = null;
    notifyListeners();
  }

  AppDocument? _findDocument(String id) {
    return null;
  }
}