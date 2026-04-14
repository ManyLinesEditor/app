import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:dart_quill_delta/dart_quill_delta.dart';
import 'document.dart';
import '../glossary_entry/glossary_entry.dart';
import '../project/project_repository.dart';

class DocumentRepository extends ChangeNotifier {
  final ProjectRepository _projectRepo;
  
  AppDocument? _selectedDocument;
  AppDocument? _secondSelectedDocument;
  bool _isGlossaryPanelOpen = false;
  String? _selectedTextForGlossary;
  
  // ✅ Хранилище контроллеров
  final Map<String, quill.QuillController> _controllers = {};

  DocumentRepository(this._projectRepo);

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
    glossary: [],  // ✅ Явно передаём mutable список
  );
}

  // ✅ Создаём или получаем контроллер
  quill.QuillController getOrCreateController(AppDocument document) {
    if (_controllers.containsKey(document.id)) {
      return _controllers[document.id]!;
    }
    
    final controller = quill.QuillController(
      document: quill.Document.fromJson(document.content.toJson()),
      selection: const TextSelection.collapsed(offset: 0),
    );
    
    // ✅ Сохраняем изменения в документ
    controller.changes.listen((change) {
      document.content = controller.document.toDelta();
    });
    
    _controllers[document.id] = controller;
    return controller;
  }

  // ✅ Вызывать только при удалении документа или закрытии приложения
  void disposeController(String documentId) {
    final controller = _controllers[documentId];
    if (controller != null) {
      controller.dispose();
      _controllers.remove(documentId);
    }
  }

  // ✅ Вызывать при закрытии приложения
  void disposeAll() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    _controllers.clear();
  }

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
  notifyListeners();  // ✅ Обязательно!
}

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

  void addGlossaryEntry(String documentId, String term) {
  print('🔍 addGlossaryEntry вызван');
  print('  - documentId: $documentId');
  print('  - term: $term');
  
  final project = _projectRepo.selectedProject;
  print('  - selectedProject: ${project?.name ?? "null"}');
  
  if (project == null) {
    print('❌ Проект не выбран');
    return;
  }
  
  try {
    final doc = project.documents.firstWhere((d) => d.id == documentId);
    print('  - Найден документ: ${doc.name}');
    print('  - Глоссарий до: ${doc.glossary.length} записей');
    
    final entry = GlossaryEntry(
      id: 'g${DateTime.now().millisecondsSinceEpoch}',
      term: term,
      definition: '',
      isExpanded: true,
    );
    
    doc.glossary.add(entry);
    print('  - Глоссарий после: ${doc.glossary.length} записей');
    print('✅ Термин добавлен успешно');
    
    notifyListeners();
  } catch (e) {
    print('❌ Ошибка: $e');
  }
}

  void updateGlossaryDefinition(String entryId, String definition) {
  final project = _projectRepo.selectedProject;
  if (project == null) return;
  
  // ✅ Ищем во ВСЕХ документах проекта
  for (var doc in project.documents) {
    final index = doc.glossary.indexWhere((e) => e.id == entryId);
    if (index != -1) {
      // ✅ Обновляем только найденную запись
      doc.glossary[index].definition = definition;
      notifyListeners();
      return;  // ✅ Выходим после первого нахождения
    }
  }
}

  // lib/entities/document/document_repository.dart

void toggleGlossaryEntry(String entryId) {
  final project = _projectRepo.selectedProject;
  if (project == null) return;
  
  // ✅ Ищем во ВСЕХ документах
  for (var doc in project.documents) {
    final index = doc.glossary.indexWhere((e) => e.id == entryId);
    if (index != -1) {
      // ✅ Переключаем только найденную запись
      doc.glossary[index].isExpanded = !doc.glossary[index].isExpanded;
      notifyListeners();
      return;  // ✅ Выходим после первого нахождения
    }
  }
}

void openGlossaryPanel() {
  _isGlossaryPanelOpen = true;
  notifyListeners();
}

  void deleteGlossaryEntry(String entryId) {
    final project = _projectRepo.selectedProject;
    if (project == null) return;
    
    for (var doc in project.documents) {
      doc.glossary.removeWhere((e) => e.id == entryId);
    }
    notifyListeners();
  }

  // ✅ Вызывать при удалении документа
  void deleteDocumentControllers(String documentId) {
    disposeController(documentId);
  }
}