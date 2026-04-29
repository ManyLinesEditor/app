import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:dart_quill_delta/dart_quill_delta.dart';
import 'document.dart';
import '../project/project_repository.dart';

class DocumentRepository extends ChangeNotifier {
  final ProjectRepository _projectRepo;
  
  AppDocument? _selectedDocument;
  AppDocument? _secondSelectedDocument;
  String? _selectedTextForGlossary;
  
  // ✅ Хранилище контроллеров редакторов
  final Map<String, quill.QuillController> _controllers = {};

  DocumentRepository(this._projectRepo);

  // ✅ Геттеры
  AppDocument? get selectedDocument => _selectedDocument;
  AppDocument? get secondSelectedDocument => _secondSelectedDocument;
  String? get selectedTextForGlossary => _selectedTextForGlossary;

  // ✅ Создание нового документа
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

  // ✅ Получение или создание контроллера для документа
  quill.QuillController getOrCreateController(AppDocument document) {
    if (_controllers.containsKey(document.id)) {
      return _controllers[document.id]!;
    }
    
    final controller = quill.QuillController(
      document: quill.Document.fromJson(document.content.toJson()),
      selection: const TextSelection.collapsed(offset: 0),
    );
    
    // Сохраняем изменения в документ
    controller.changes.listen((change) {
      document.content = controller.document.toDelta();
    });
    
    _controllers[document.id] = controller;
    return controller;
  }

  // ✅ Очистка контроллера (при удалении документа)
  void disposeController(String documentId) {
    final controller = _controllers[documentId];
    if (controller != null) {
      controller.dispose();
      _controllers.remove(documentId);
    }
  }

  // ✅ Очистка всех контроллеров (при закрытии приложения)
  void disposeAll() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    _controllers.clear();
  }

  void deleteDocumentControllers(String documentId) {
    disposeController(documentId);
  }
  
  // ✅ Выбор документа
  void selectDocument(AppDocument document) {
    _selectedDocument = document;
    incrementViewCount(document);
    notifyListeners();
  }

  void selectSecondDocument(AppDocument document) {
    _secondSelectedDocument = document;
    incrementViewCount(document);
    notifyListeners();
  }

  // ✅ Закрытие редакторов
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

  // ✅ Счётчик просмотров
  void incrementViewCount(AppDocument doc) {
    doc.viewCount++;
    notifyListeners();
  }

  // ✅ Pin документа
  void togglePin(AppDocument doc) {
    doc.isPinned = !doc.isPinned;
    notifyListeners();
  }

  // ✅ Изменение иерархии (indent/outdent)
  void indentDocument(String documentId, String parentId) {
    final project = _projectRepo.selectedProject;
    if (project == null) return;
    
    final doc = project.documents.firstWhere((d) => d.id == documentId);
    doc.parentId = parentId;
    notifyListeners();
  }

  void outdentDocument(String documentId) {
    final project = _projectRepo.selectedProject;
    if (project == null) return;
    
    final doc = project.documents.firstWhere((d) => d.id == documentId);
    doc.parentId = null;
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
  
}