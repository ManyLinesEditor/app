import 'package:flutter/foundation.dart';
import 'project.dart';
import '../document/document.dart';

class ProjectRepository extends ChangeNotifier {
  final List<Project> _projects = [
    Project(id: 'p1', name: 'Project 1', documents: []),
    Project(id: 'p2', name: 'Project 2', documents: []),
  ];

  Project? _selectedProject;
  bool _isGraphView = false;

  List<Project> get projects => _projects;
  Project? get selectedProject => _selectedProject;
  bool get isGraphView => _isGraphView;

  void addProject(String name) {
    _projects.add(Project(
      id: 'p${_projects.length + 1}',
      name: name,
      documents: [],
    ));
    notifyListeners();
  }

  void selectProject(Project project) {
    _selectedProject = project;
    notifyListeners();
  }

  void clearSelectedProject() {
    _selectedProject = null;
    notifyListeners();
  }

  void reorderProjects(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) newIndex -= 1;
    final item = _projects.removeAt(oldIndex);
    _projects.insert(newIndex, item);
    notifyListeners();
  }

  void reorderPinnedDocuments(int oldIndex, int newIndex) {
    if (_selectedProject == null) return;
    
    final pinnedDocs = _selectedProject!.pinnedDocuments;
    if (newIndex > oldIndex) newIndex -= 1;
    
    final doc = pinnedDocs.removeAt(oldIndex);
    final targetDoc = pinnedDocs[newIndex];
    
    final docMainIndex = _selectedProject!.documents.indexOf(doc);
    final targetMainIndex = _selectedProject!.documents.indexOf(targetDoc);
    
    _selectedProject!.documents.removeAt(docMainIndex);
    _selectedProject!.documents.insert(targetMainIndex, doc);
    
    notifyListeners();
  }

  void toggleViewMode() {
    _isGraphView = !_isGraphView;
    notifyListeners();
  }

  void addDocumentToProject(AppDocument document) {
  if (_selectedProject == null) return;
  _selectedProject!.documents.add(document);
  notifyListeners();
}

  void deleteDocument(AppDocument doc) {
    if (_selectedProject == null) return;
    _selectedProject!.documents.remove(doc);
    notifyListeners();
  }

  void togglePin(AppDocument doc) {
  doc.isPinned = !doc.isPinned;
  notifyListeners();  // ✅ Уведомляем о изменении
}
}