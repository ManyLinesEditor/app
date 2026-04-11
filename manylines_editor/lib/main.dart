import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:provider/provider.dart';
import 'package:dart_quill_delta/dart_quill_delta.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

// ==================== МОДЕЛИ ====================
class Project {
  final String id;
  final String name;
  final List<AppDocument> documents;

  Project({
    required this.id,
    required this.name,
    required this.documents,
  });

  int get maxViewCount {
    if (documents.isEmpty) return 0;
    return documents.map((doc) => doc.viewCount).reduce((a, b) => a > b ? a : b);
  }

  bool isDocumentMostUsed(AppDocument doc) {
    return doc.viewCount >= maxViewCount && maxViewCount > 0;
  }

  List<AppDocument> get pinnedDocuments => 
    documents.where((doc) => doc.isPinned).toList();
  
  List<AppDocument> get unpinnedDocuments => 
    documents.where((doc) => !doc.isPinned).toList();
}

class AppDocument {
  final String id;
  final String name;
  int viewCount;
  bool isPinned;
  String? parentId;
  Delta content;

  AppDocument({
    required this.id,
    required this.name,
    this.viewCount = 0,
    this.isPinned = false,
    this.parentId,
    required this.content,
  });

  bool get isChild => parentId != null;
}

// ==================== STATE ====================
class AppState extends ChangeNotifier {
  final List<Project> _projects = [
    Project(id: 'p1', name: 'Project 1', documents: []),
    Project(id: 'p2', name: 'Project 2', documents: []),
  ];

  List<Map<String, dynamic>> _settings = [
    {'id': 'setting1', 'name': 'Setting 1', 'expanded': true, 'enabled': false},
    {'id': 'setting2', 'name': 'Setting 2', 'expanded': false, 'enabled': false},
    {'id': 'setting3', 'name': 'Setting 3', 'expanded': true, 'enabled': false},
  ];

  bool _switchableValue = true;
  Project? _selectedProject;
  AppDocument? _selectedDocument;
  AppDocument? _secondSelectedDocument;
  bool _isDarkMode = false;
  bool _isGraphView = false;
  bool _isSidePanelCollapsed = false;

  List<Project> get projects => _projects;
  List<Map<String, dynamic>> get settings => _settings;
  bool get switchableValue => _switchableValue;
  Project? get selectedProject => _selectedProject;
  AppDocument? get selectedDocument => _selectedDocument;
  AppDocument? get secondSelectedDocument => _secondSelectedDocument;
  bool get isDarkMode => _isDarkMode;
  bool get isGraphView => _isGraphView;
  bool get isSidePanelCollapsed => _isSidePanelCollapsed;

  void toggleDarkMode(bool value) {
    _isDarkMode = value;
    notifyListeners();
  }

  void toggleSidePanel() {
    _isSidePanelCollapsed = !_isSidePanelCollapsed;
    notifyListeners();
  }

  void closeFirstEditor() {
    _selectedDocument = null;
    notifyListeners();
  }

  void toggleViewMode() {
    _isGraphView = !_isGraphView;
    notifyListeners();
  }

  void incrementViewCount(AppDocument doc) {
    doc.viewCount++;
    notifyListeners();
  }

  quill.QuillController getOrCreateController(AppDocument doc) {
    final controller = quill.QuillController(
      document: quill.Document.fromJson(doc.content.toJson()),
      selection: const TextSelection.collapsed(offset: 0),
    );
    controller.changes.listen((change) {
      doc.content = controller.document.toDelta();
    });
    return controller;
  }

  void addProject(String name) {
    _projects.add(Project(
      id: 'p${_projects.length + 1}',
      name: name,
      documents: [],
    ));
    notifyListeners();
  }

  void addDocumentToCurrentProject(String name) {
    if (_selectedProject == null) return;
    final newDoc = AppDocument(
      id: 'd${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      viewCount: 0,
      isPinned: false,
      parentId: null,
      content: Delta()..insert('New document content...\n'),
    );
    _selectedProject!.documents.add(newDoc);
    _selectedDocument = newDoc;
    notifyListeners();
  }

  // ✅ Закрепить/открепить документ
  void toggleDocumentPin(AppDocument doc) {
    doc.isPinned = !doc.isPinned;
    notifyListeners();
  }

  // ✅ В классе AppState добавьте этот метод:
void reorderPinnedDocuments(int oldIndex, int newIndex) {
  if (_selectedProject == null) return;
  
  final pinnedDocs = _selectedProject!.pinnedDocuments;
  if (newIndex > oldIndex) newIndex -= 1;
  
  final doc = pinnedDocs.removeAt(oldIndex);
  final targetDoc = pinnedDocs[newIndex];
  
  // Находим индексы в основном списке
  final docMainIndex = _selectedProject!.documents.indexOf(doc);
  final targetMainIndex = _selectedProject!.documents.indexOf(targetDoc);
  
  // Перемещаем в основном списке
  _selectedProject!.documents.removeAt(docMainIndex);
  _selectedProject!.documents.insert(targetMainIndex, doc);
  
  notifyListeners();
}

  // ✅ Удалить документ
  void deleteDocument(AppDocument doc) {
    if (_selectedProject == null) return;
    
    // ✅ Сначала удаляем документ из проекта
    _selectedProject!.documents.remove(doc);
    
    // ✅ Затем закрываем редакторы, если они используют этот документ
    if (_selectedDocument?.id == doc.id) {
      _selectedDocument = null;
    }
    if (_secondSelectedDocument?.id == doc.id) {
      _secondSelectedDocument = null;
    }
    
    // ✅ И только потом уведомляем слушателей
    notifyListeners();
  }

  void indentDocument(int index) {
    if (_selectedProject == null || index <= 0) return;
    final docs = _selectedProject!.documents;
    
    AppDocument? parentDoc;
    for (int i = index - 1; i >= 0; i--) {
      if (docs[i].parentId == null && !docs[i].isPinned) {
        parentDoc = docs[i];
        break;
      }
    }
    
    if (parentDoc != null) {
      docs[index].parentId = parentDoc.id;
      notifyListeners();
    }
  }

  void outdentDocument(int index) {
    if (_selectedProject == null) return;
    _selectedProject!.documents[index].parentId = null;
    notifyListeners();
  }

  void selectProject(Project project) {
    _selectedProject = project;
    if (project.documents.isNotEmpty) {
      final mostUsed = project.documents.reduce((a, b) => a.viewCount > b.viewCount ? a : b);
      _selectedDocument = mostUsed;
      incrementViewCount(mostUsed);
    } else {
      _selectedDocument = null;
    }
    notifyListeners();
  }

  void selectDocument(AppDocument document) {
    _selectedDocument = document;
    incrementViewCount(document);
    notifyListeners();
  }

  // ✅ Открыть документ во втором редакторе
  void selectSecondDocument(AppDocument document) {
    _secondSelectedDocument = document;
    incrementViewCount(document);
    notifyListeners();
  }

  // ✅ Закрыть второй редактор
  void closeSecondEditor() {
    _secondSelectedDocument = null;
    notifyListeners();
  }

  void clearSelectedProject() {
    _selectedProject = null;
    _selectedDocument = null;
    _secondSelectedDocument = null;
    notifyListeners();
  }

  void setSwitchableValue(bool value) {
    _switchableValue = value;
    notifyListeners();
  }

  void reorderSettings(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) newIndex -= 1;
    final item = _settings.removeAt(oldIndex);
    _settings.insert(newIndex, item);
    notifyListeners();
  }

  void reorderProjects(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) newIndex -= 1;
    final item = _projects.removeAt(oldIndex);
    _projects.insert(newIndex, item);
    notifyListeners();
  }

  void toggleSettingExpansion(String id) {
    for (var setting in _settings) {
      if (setting['id'] == id) {
        setting['expanded'] = !setting['expanded'];
        notifyListeners();
        break;
      }
    }
  }

  void toggleSettingEnabled(String id, bool value) {
    for (var setting in _settings) {
      if (setting['id'] == id) {
        setting['enabled'] = value;
        notifyListeners();
        break;
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}

// ==================== APP ====================
void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => AppState(),
      child: Consumer<AppState>(
        builder: (context, state, _) {
          return MaterialApp(
            title: 'Manyllines',
            localizationsDelegates: const [
              quill.FlutterQuillLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [Locale('ru', 'RU'), Locale('en', 'US')],
            locale: const Locale('ru', 'RU'),
            theme: state.isDarkMode
                ? ThemeData(
                    useMaterial3: true,
                    colorSchemeSeed: Colors.green,
                    brightness: Brightness.dark,
                    fontFamily: 'Roboto',
                  )
                : ThemeData(
                    useMaterial3: true,
                    colorSchemeSeed: Colors.green,
                    brightness: Brightness.light,
                    fontFamily: 'Roboto',
                  ),
            home: AppShell(),
          );
        },
      ),
    ),
  );
}

class AppShell extends StatelessWidget {
  const AppShell({super.key});
  @override
  Widget build(BuildContext context) {
    return Selector<AppState, Project?>(
      selector: (_, state) => state.selectedProject,
      builder: (context, selectedProject, _) {
        return selectedProject == null ? const ProjectsScreen() : const ProjectWorkspace();
      },
    );
  }
}

// ==================== ЭКРАН ПРОЕКТОВ ====================
class ProjectsScreen extends StatelessWidget {
  const ProjectsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Consumer<AppState>(
            builder: (context, state, _) {
              final headerBg = state.isDarkMode ? Colors.grey[850] : Colors.white;
              final logoBg = state.isDarkMode ? Colors.grey[800] : Colors.white;
              final borderColor = state.isDarkMode ? Colors.grey[700]! : Colors.grey[300]!;
              final logoBorderColor = state.isDarkMode ? Colors.grey[600]! : Colors.grey[400]!;
              final textColor = state.isDarkMode ? Colors.white : Colors.black87;
              final logoTextColor = state.isDarkMode ? Colors.white : Colors.black;
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(border: Border(bottom: BorderSide(color: borderColor)), color: headerBg),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        border: Border.all(color: logoBorderColor),
                        color: logoBg,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text('Logo', style: TextStyle(fontWeight: FontWeight.bold, color: logoTextColor)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: Text('Manyllines', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: textColor))),
                  ],
                ),
              );
            },
          ),
          Consumer<AppState>(
            builder: (context, state, _) {
              final bgColor = state.isDarkMode ? Colors.green[900] : Colors.green[50];
              final borderColor = state.isDarkMode ? const Color.fromARGB(255, 0, 47, 22) : Colors.green.shade200;
              final textColor = state.isDarkMode ? Colors.white : Colors.black87;
              if (state.switchableValue) {
                return ReorderableListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: state.projects.length,
                  onReorder: state.reorderProjects,
                  itemBuilder: (context, index) {
                    final project = state.projects[index];
                    return Container(
                      key: ValueKey(project.id),
                      decoration: BoxDecoration(color: bgColor, border: Border(bottom: BorderSide(color: borderColor))),
                      child: ListTile(
                        title: Text(project.name, style: TextStyle(color: textColor)),
                        subtitle: Text('${project.documents.length} документов', style: TextStyle(fontSize: 12, color: textColor.withOpacity(0.7))),
                        trailing: Icon(Icons.drag_handle, color: state.isDarkMode ? Colors.white54 : Colors.grey),
                        onTap: () => state.selectProject(project),
                      ),
                    );
                  },
                );
              } else {
                return Container(
                  decoration: BoxDecoration(color: bgColor, border: Border(bottom: BorderSide(color: borderColor))),
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: state.projects.length,
                    itemBuilder: (context, index) {
                      final project = state.projects[index];
                      return Container(
                        key: ValueKey(project.id),
                        decoration: BoxDecoration(border: Border(bottom: BorderSide(color: borderColor))),
                        child: ListTile(
                          title: Text(project.name, style: TextStyle(color: textColor)),
                          subtitle: Text('${project.documents.length} документов', style: TextStyle(fontSize: 12, color: textColor.withOpacity(0.7))),
                          onTap: () => state.selectProject(project),
                        ),
                      );
                    },
                  ),
                );
              }
            },
          ),
          Consumer<AppState>(
            builder: (context, state, _) {
              final bgColor = state.isDarkMode ? Colors.blue[900] : Colors.blue[50];
              final borderColor = state.isDarkMode ? Colors.blue[700] : Colors.blue[200];
              final textColor = state.isDarkMode ? Colors.white : Colors.black87;
              final settings = state.settings;
              if (state.switchableValue) {
                return ReorderableListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: settings.length,
                  onReorder: state.reorderSettings,
                  itemBuilder: (context, index) {
                    final setting = settings[index];
                    final isExpanded = setting['expanded'] ?? false;
                    return Column(
                      key: ValueKey(setting['id']),
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          decoration: BoxDecoration(border: Border(bottom: BorderSide(color: borderColor!)), color: state.isDarkMode ? Colors.blue[800] : Colors.white),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(setting['name'], style: TextStyle(color: textColor)),
                              Row(
                                children: [
                                  IconButton(icon: Icon(isExpanded ? Icons.arrow_drop_down : Icons.arrow_drop_up, color: textColor), onPressed: () => state.toggleSettingExpansion(setting['id'])),
                                  if (state.switchableValue) Icon(Icons.drag_handle, color: state.isDarkMode ? Colors.white54 : Colors.grey),
                                ],
                              ),
                            ],
                          ),
                        ),
                        if (setting['id'] == 'setting1' && isExpanded) _buildDescriptionSection1(state.isDarkMode),
                        if (setting['id'] == 'setting2' && isExpanded) _buildDescriptionSection2(state.isDarkMode),
                        if (setting['id'] == 'setting3' && isExpanded) _buildDescriptionSection3(state.isDarkMode),
                      ],
                    );
                  },
                );
              } else {
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: settings.length,
                  itemBuilder: (context, index) {
                    final setting = settings[index];
                    final isExpanded = setting['expanded'] ?? false;
                    return Column(
                      key: ValueKey(setting['id']),
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          decoration: BoxDecoration(border: Border(bottom: BorderSide(color: borderColor!)), color: state.isDarkMode ? Colors.blue[800] : Colors.white),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(setting['name'], style: TextStyle(color: textColor)),
                              IconButton(icon: Icon(isExpanded ? Icons.arrow_drop_down : Icons.arrow_drop_up, color: textColor), onPressed: () => state.toggleSettingExpansion(setting['id'])),
                            ],
                          ),
                        ),
                        if (setting['id'] == 'setting1' && isExpanded) _buildDescriptionSection1(state.isDarkMode),
                        if (setting['id'] == 'setting2' && isExpanded) _buildDescriptionSection2(state.isDarkMode),
                        if (setting['id'] == 'setting3' && isExpanded) _buildDescriptionSection3(state.isDarkMode),
                      ],
                    );
                  },
                );
              }
            },
          ),
          Consumer<AppState>(
            builder: (context, state, _) {
              final bgColor = state.isDarkMode ? const Color.fromARGB(255, 6, 58, 137) : Colors.blue[50];
              final textColor = state.isDarkMode ? Colors.white54 : Colors.black54;
              return Expanded(
                child: Container(color: bgColor, padding: const EdgeInsets.all(16), child: Center(child: Text('Other Settings ...', style: TextStyle(color: textColor)))),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(onPressed: () => _showCreateProjectDialog(context), child: const Icon(Icons.add)),
    );
  }

  void _showCreateProjectDialog(BuildContext context) {
    final controller = TextEditingController();
    final formKey = GlobalKey<FormState>();
    showDialog(
      context: context,
      builder: (context) => Consumer<AppState>(
        builder: (context, state, _) {
          final isDarkMode = state.isDarkMode;
          return AlertDialog(
            backgroundColor: isDarkMode ? Colors.grey[850] : Colors.white,
            title: Text('Новый проект', style: TextStyle(color: isDarkMode ? Colors.white : Colors.black87)),
            content: Form(
              key: formKey,
              child: TextFormField(
                controller: controller,
                autofocus: true,
                style: TextStyle(color: isDarkMode ? Colors.white : Colors.black87),
                decoration: InputDecoration(
                  labelText: 'Название проекта',
                  labelStyle: TextStyle(color: isDarkMode ? Colors.grey[400] : Colors.grey[600]),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.green[700]!)),
                  prefixIcon: Icon(Icons.folder, color: Colors.green[700]),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) return 'Введите название проекта';
                  return null;
                },
                onFieldSubmitted: (_) {
                  if (formKey.currentState!.validate()) {
                    state.addProject(controller.text.trim());
                    Navigator.pop(context);
                  }
                },
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: Text('Отмена', style: TextStyle(color: Colors.grey[600]))),
              ElevatedButton(
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    state.addProject(controller.text.trim());
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green[700], foregroundColor: Colors.white),
                child: const Text('Создать'),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDescriptionSection2(bool isDarkMode) {
    return Container(
      color: isDarkMode ? Colors.grey[850] : Colors.grey[50],
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Description', style: TextStyle(fontSize: 14, color: isDarkMode ? Colors.grey[300] : Colors.grey[700])),
          const SizedBox(height: 12),
          Row(children: [_buildOutlinedButton('A', isDarkMode), const SizedBox(width: 8), _buildOutlinedButton('B', isDarkMode), const SizedBox(width: 8), _buildOutlinedButton('C', isDarkMode)]),
          const SizedBox(height: 16),
          Consumer<AppState>(
            builder: (context, state, _) {
              final isDark = state.isDarkMode;
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(children: [Icon(isDark ? Icons.dark_mode : Icons.light_mode, size: 20, color: isDark ? Colors.yellow[200] : Colors.orange), const SizedBox(width: 8), Text(isDark ? 'Тёмная тема' : 'Светлая тема', style: TextStyle(color: isDarkMode ? Colors.white : Colors.black87))]),
                  Switch(value: isDark, onChanged: (value) => state.toggleDarkMode(value)),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionSection3(bool isDarkMode) {
    return Container(
      color: isDarkMode ? Colors.grey[850] : Colors.grey[50],
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Description', style: TextStyle(fontSize: 14, color: isDarkMode ? Colors.grey[300] : Colors.grey[700])),
          const SizedBox(height: 12),
          Row(children: [_buildOutlinedButton('A', isDarkMode), const SizedBox(width: 8), _buildOutlinedButton('B', isDarkMode), const SizedBox(width: 8), _buildOutlinedButton('C', isDarkMode)]),
          const SizedBox(height: 16),
          Consumer<AppState>(
            builder: (context, state, _) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Switchable', style: TextStyle(color: isDarkMode ? Colors.white : Colors.black87)),
                  Switch(value: state.switchableValue, onChanged: (value) => state.setSwitchableValue(value)),
                ],
              );
            },
          ),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Listable', style: TextStyle(color: isDarkMode ? Colors.white : Colors.black87)), IconButton(icon: Icon(Icons.arrow_drop_down, color: isDarkMode ? Colors.white : Colors.black87), onPressed: () {})]),
        ],
      ),
    );
  }

  Widget _buildDescriptionSection1(bool isDarkMode) {
    return Container(
      color: isDarkMode ? Colors.grey[850] : Colors.grey[50],
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Text('Description', style: TextStyle(fontSize: 14, color: isDarkMode ? Colors.grey[300] : Colors.grey[700])),
        const SizedBox(height: 12),
        Row(children: [_buildOutlinedButton('A', isDarkMode), const SizedBox(width: 8), _buildOutlinedButton('B', isDarkMode), const SizedBox(width: 8), _buildOutlinedButton('C', isDarkMode)]),
      ]),
    );
  }

  Widget _buildOutlinedButton(String label, bool isDarkMode) {
    return Expanded(
      child: OutlinedButton(
        onPressed: () {},
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 12),
          side: BorderSide(color: isDarkMode ? const Color.fromARGB(255, 54, 107, 232) : Colors.grey[400]!),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          foregroundColor: isDarkMode ? Colors.white : Colors.black87,
        ),
        child: Text(label),
      ),
    );
  }
}

// ==================== РАБОЧЕЕ ПРОСТРАНСТВО ====================
class ProjectWorkspace extends StatelessWidget {
  const ProjectWorkspace({super.key});
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 700;
        if (!isWide) {
          return Consumer<AppState>(
            builder: (context, state, _) {
              return state.selectedDocument == null ? const _MobileDocList() : _MobileEditorView(document: state.selectedDocument!);
            },
          );
        }
        return Selector<AppState, AppDocument?>(
          selector: (_, state) => state.selectedDocument,
          builder: (context, selectedDocument, _) {
            return _buildDesktopLayout(context, selectedDocument);
          },
        );
      },
    );
  }

  Widget _buildDesktopLayout(BuildContext context, AppDocument? selectedDocument) {
  final state = context.watch<AppState>();
  final leftPanelBg = state.isDarkMode ? Colors.grey[900] : Colors.white;
  final headerBg = state.isDarkMode ? Colors.green[900] : Colors.green[50];
  final textColor = state.isDarkMode ? Colors.white : Colors.black87;
  final borderColor = state.isDarkMode ? Colors.grey[700]! : Colors.grey[300]!;
  
  final showTwoEditors = state.secondSelectedDocument != null;
  final isPanelCollapsed = state.isSidePanelCollapsed;  // ✅ Получаем состояние
  
  return Scaffold(
    body: Row(
      children: [
        // ✅ Боковая панель с анимацией сворачивания
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          width: isPanelCollapsed ? 0 : 300,
          decoration: BoxDecoration(
            border: Border(right: BorderSide(color: borderColor)),
          ),
          child: isPanelCollapsed
              ? const SizedBox.shrink()
              : Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      color: headerBg,
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back),
                            onPressed: () => state.clearSelectedProject(),
                            tooltip: 'Back to projects',
                          ),
                          Expanded(
                            child: Text(
                              state.selectedProject!.name,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(color: textColor),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Material(
                        color: leftPanelBg,
                        child: Column(
                          children: [
                            Expanded(
                              child: Selector<AppState, bool>(
                                selector: (_, state) => state.isGraphView,
                                builder: (context, isGraphView, _) {
                                  return isGraphView ? _DocumentsGraph() : _DocumentsList();
                                },
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(border: Border(top: BorderSide(color: borderColor))),
                              child: SizedBox(
                                width: double.infinity,
                                child: OutlinedButton.icon(
                                  onPressed: () => _showCreateDocumentDialog(context),
                                  icon: const Icon(Icons.add, size: 18),
                                  label: const Text('Новый документ'),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    foregroundColor: state.isDarkMode ? Colors.white : Colors.green[700],
                                    side: BorderSide(color: state.isDarkMode ? Colors.green[400]! : Colors.green[700]!),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
        ),
        
        // ✅ Кнопка-вкладка для сворачивания/разворачивания
        Container(
            width: 24,
            decoration: BoxDecoration(
              color: isPanelCollapsed ? (state.isDarkMode ? Colors.grey[800] : Colors.grey[200]) : Colors.transparent,
              border: Border(right: BorderSide(color: borderColor)),
            ),
            child: Column(
              children: [
                // ✅ Регулируйте высоту верхнего отступа
                const SizedBox(height: 100),  // Было: Spacer()
                
                // ✅ Кнопка сворачивания/разворачивания
                GestureDetector(
                  onTap: () => state.toggleSidePanel(),
                  child: Container(
                    width: 24,
                    height: 82,
                    decoration: BoxDecoration(
                      color: state.isDarkMode ? Colors.grey[700] : Colors.grey[300],
                      borderRadius: BorderRadius.zero,
                    ),
                    child: Icon(
                      isPanelCollapsed ? Icons.chevron_right : Icons.chevron_left,
                      size: 20,
                      color: textColor,
                    ),
                  ),
                ),
                
                // ✅ Оставшееся пространство
                const Expanded(child: SizedBox()),  // Было: Spacer()
              ],
            ),
          ),
        
        // ✅ Редакторы занимают всё оставшееся пространство
        Expanded(
          child: showTwoEditors
              ? _buildTwoEditorsLayout(context, state, borderColor, textColor)
              : _buildSingleEditorLayout(context, selectedDocument, state, textColor),
        ),
      ],
    ),
    floatingActionButton: Selector<AppState, bool>(
      selector: (_, state) => state.isGraphView,
      builder: (context, isGraphView, _) {
        return FloatingActionButton(
          onPressed: () => state.toggleViewMode(),
          tooltip: isGraphView ? 'Список' : 'Граф',
          child: Icon(isGraphView ? Icons.list : Icons.account_tree),
        );
      },
    ),
    persistentFooterButtons: [
      FloatingActionButton(
        heroTag: 'createDoc',
        onPressed: () => _showCreateDocumentDialog(context),
        tooltip: 'Новый документ',
        child: const Icon(Icons.add),
      ),
    ],
  );
}

  // ✅ Макет с одним редактором (с toolbar)
  Widget _buildSingleEditorLayout(BuildContext context, AppDocument? selectedDocument, AppState state, Color textColor) {
    final project = state.selectedProject;
    final hasDocuments = project != null && project.documents.isNotEmpty;
    
    if (selectedDocument == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              hasDocuments ? Icons.touch_app : Icons.description_outlined,
              size: 64,
              color: state.isDarkMode ? Colors.white30 : Colors.black26,
            ),
            const SizedBox(height: 16),
            Text(
              hasDocuments ? 'Выберите документ' : 'В проекте нет документов',
              style: TextStyle(fontSize: 18, color: state.isDarkMode ? Colors.white70 : Colors.black54),
            ),
            const SizedBox(height: 8),
            Text(
              hasDocuments
                  ? 'Кликните на документ в списке слева'
                  : 'Нажмите кнопку "+ Новый документ" чтобы создать',
              style: TextStyle(color: state.isDarkMode ? Colors.white54 : Colors.black45),
            ),
            const SizedBox(height: 24),
            if (!hasDocuments)
              ElevatedButton.icon(
                onPressed: () => _showCreateDocumentDialog(context),
                icon: const Icon(Icons.add),
                label: const Text('Создать первый документ'),
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12)),
              ),
          ],
        ),
      );
    }

    // ✅ Редактор с toolbar
    return Column(
      children: [
        // Toolbar первого редактора
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          color: state.isDarkMode ? Colors.grey[850] : Colors.grey[100],
          child: Row(
            children: [
              Expanded(
                child: Text(
                  selectedDocument.name,
                  style: TextStyle(fontWeight: FontWeight.w500, color: textColor),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 20),
                onPressed: () => state.closeFirstEditor(),
                tooltip: 'Закрыть',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ),
        // Контент редактора
        Expanded(
          child: QuillEditorView(document: selectedDocument, editorIndex: 1),
        ),
      ],
    );
  }

  // ✅ Макет с двумя редакторами
  Widget _buildTwoEditorsLayout(BuildContext context, AppState state, Color borderColor, Color textColor) {
    return Row(
      children: [
        // ✅ Первый редактор (50% ширины) с toolbar
        Expanded(
          child: Column(
            children: [
              // Toolbar первого редактора
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                color: state.isDarkMode ? Colors.grey[850] : Colors.grey[100],
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        state.selectedDocument?.name ?? 'Первый редактор',
                        style: TextStyle(fontWeight: FontWeight.w500, color: textColor),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      onPressed: () => state.closeFirstEditor(),
                      tooltip: 'Закрыть',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),
              // Контент первого редактора
              Expanded(
                child: Container(
                  decoration: BoxDecoration(border: Border(right: BorderSide(color: borderColor))),
                  child: state.selectedDocument != null
                      ? QuillEditorView(document: state.selectedDocument!, editorIndex: 1)
                      : Center(child: Text('Выберите документ', style: TextStyle(color: textColor))),
                ),
              ),
            ],
          ),
        ),
        // ✅ Второй редактор (50% ширины) с toolbar
        Expanded(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                color: state.isDarkMode ? Colors.grey[850] : Colors.grey[100],
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        state.secondSelectedDocument?.name ?? 'Второй редактор',
                        style: TextStyle(fontWeight: FontWeight.w500, color: textColor),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      onPressed: () => state.closeSecondEditor(),
                      tooltip: 'Закрыть',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: state.secondSelectedDocument != null
                    ? QuillEditorView(document: state.secondSelectedDocument!, editorIndex: 2)
                    : Center(child: Text('Выберите документ', style: TextStyle(color: textColor))),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showCreateDocumentDialog(BuildContext context) {
    final controller = TextEditingController();
    final formKey = GlobalKey<FormState>();
    showDialog(
      context: context,
      builder: (context) => Consumer<AppState>(
        builder: (context, state, _) {
          final isDarkMode = state.isDarkMode;
          return AlertDialog(
            backgroundColor: isDarkMode ? Colors.grey[850] : Colors.white,
            title: Text('Новый документ', style: TextStyle(color: isDarkMode ? Colors.white : Colors.black87)),
            content: Form(
              key: formKey,
              child: TextFormField(
                controller: controller,
                autofocus: true,
                style: TextStyle(color: isDarkMode ? Colors.white : Colors.black87),
                decoration: InputDecoration(
                  labelText: 'Название документа',
                  labelStyle: TextStyle(color: isDarkMode ? Colors.grey[400] : Colors.grey[600]),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.green[700]!)),
                  prefixIcon: Icon(Icons.description, color: Colors.green[700]),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) return 'Введите название документа';
                  return null;
                },
                onFieldSubmitted: (_) {
                  if (formKey.currentState!.validate()) {
                    state.addDocumentToCurrentProject(controller.text.trim());
                    Navigator.pop(context);
                  }
                },
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: Text('Отмена', style: TextStyle(color: Colors.grey[600]))),
              ElevatedButton(
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    state.addDocumentToCurrentProject(controller.text.trim());
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green[700], foregroundColor: Colors.white),
                child: const Text('Создать'),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ==================== СПИСОК ДОКУМЕНТОВ ====================
class _DocumentsList extends StatelessWidget {
  const _DocumentsList();
  
  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final project = state.selectedProject!;
    final pinnedDocs = project.pinnedDocuments;
    final unpinnedDocs = project.unpinnedDocuments;
    final isDarkMode = state.isDarkMode;

    return Column(
      children: [
        if (pinnedDocs.isNotEmpty)
          Container(
            color: isDarkMode ? Colors.green[900]!.withOpacity(0.3) : Colors.green[50],
            child: ReorderableListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: pinnedDocs.length,
              onReorder: state.reorderPinnedDocuments,
              itemBuilder: (context, index) {
                final doc = pinnedDocs[index];
                final isSelected = state.selectedDocument?.id == doc.id || state.secondSelectedDocument?.id == doc.id;
                
                return Container(
                  key: ValueKey(doc.id),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: isDarkMode ? Colors.green[700]! : Colors.green[200]!,
                      ),
                    ),
                  ),
                  child: ListTile(
                    selected: isSelected,
                    selectedTileColor: Theme.of(context).colorScheme.secondaryContainer,
                    leading: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${index + 1}.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.green[700],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.push_pin,
                          size: 16,
                          color: Colors.green[700],
                        ),
                      ],
                    ),
                    title: Text(doc.name),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Checkbox(
                          value: doc.isPinned,
                          activeColor: Colors.green[700],
                          onChanged: (value) => state.toggleDocumentPin(doc),
                        ),
                        const SizedBox(width: 4),
                        // ✅ Кнопка меню для удаления
                        IconButton(
                          icon: const Icon(Icons.more_vert, size: 20),
                          onPressed: () => _showDeleteMenu(context, doc),
                          tooltip: 'Меню',
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                        Icon(
                          Icons.drag_handle,
                          color: isDarkMode ? Colors.white54 : Colors.grey,
                        ),
                      ],
                    ),
                    // ✅ Долгое нажатие → сразу второй редактор
                    onTap: () => state.selectDocument(doc),
                    onLongPress: () => state.selectSecondDocument(doc),
                  ),
                );
              },
            ),
          ),
        Expanded(
          child: Container(
            color: isDarkMode ? Colors.blue[900]!.withOpacity(0.2) : Colors.blue[50],
            child: _buildDismissibleList(project, unpinnedDocs, state, isDarkMode, context),
          ),
        ),
      ],
    );
  }

  Widget _buildDismissibleList(Project project, List<AppDocument> docs, AppState state, bool isDarkMode, BuildContext context) {
    int mainIndex = 0;
    int childIndex = 0;

    return ListView.builder(
      itemCount: docs.length,
      itemBuilder: (context, index) {
        final doc = docs[index];
        final isSelected = state.selectedDocument?.id == doc.id || state.secondSelectedDocument?.id == doc.id;
        final actualIndex = project.documents.indexOf(doc);

        String number;
        if (doc.parentId == null) {
          mainIndex++;
          childIndex = 0;
          number = '$mainIndex.';
        } else {
          childIndex++;
          number = '$mainIndex.$childIndex';
        }

        return Dismissible(
          key: ValueKey(doc.id),
          direction: DismissDirection.horizontal,
          background: Container(
            color: Colors.blue,
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.only(left: 16),
            child: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          secondaryBackground: Container(
            color: Colors.green,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 16),
            child: const Icon(Icons.arrow_forward, color: Colors.white),
          ),
          confirmDismiss: (direction) async {
            if (direction == DismissDirection.startToEnd) {
              state.indentDocument(actualIndex);
            } else if (direction == DismissDirection.endToStart) {
              state.outdentDocument(actualIndex);
            }
            return false;
          },
          child: Container(
            decoration: BoxDecoration(
              color: doc.parentId == null
                  ? (isDarkMode ? Colors.blue[900]!.withOpacity(0.2) : Colors.blue[50])
                  : (isDarkMode ? Colors.green[900]!.withOpacity(0.3) : Colors.green[50]),
              border: Border(
                bottom: BorderSide(
                  color: isDarkMode
                      ? (doc.parentId == null ? Colors.blue[700]! : Colors.green[700]!)
                      : (doc.parentId == null ? Colors.blue[200]! : Colors.green[200]!),
                ),
              ),
            ),
            child: ListTile(
              selected: isSelected,
              selectedTileColor: Theme.of(context).colorScheme.secondaryContainer,
              leading: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    number,
                    style: TextStyle(
                      fontSize: 12,
                      color: doc.parentId == null ? Colors.blue[700] : Colors.green[700],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    doc.parentId == null ? Icons.insert_drive_file : Icons.subdirectory_arrow_right,
                    size: 16,
                    color: doc.parentId == null ? Colors.blue[700] : Colors.green[700],
                  ),
                ],
              ),
              title: Text(doc.name),
              subtitle: doc.parentId != null ? Text('Поддокумент', style: TextStyle(fontSize: 10, color: Colors.grey[600])) : null,
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Checkbox(
                    value: doc.isPinned,
                    activeColor: Colors.green[700],
                    onChanged: (value) => state.toggleDocumentPin(doc),
                  ),
                  const SizedBox(width: 4),
                  if (doc.parentId != null)
                    Icon(Icons.swipe, size: 16, color: Colors.grey[500]),
                  // ✅ Кнопка меню для удаления
                  IconButton(
                    icon: const Icon(Icons.more_vert, size: 20),
                    onPressed: () => _showDeleteMenu(context, doc),
                    tooltip: 'Меню',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              // ✅ Долгое нажатие → сразу второй редактор
              onTap: () => state.selectDocument(doc),
              onLongPress: () => state.selectSecondDocument(doc),
            ),
          ),
        );
      },
    );
  }

  // ✅ Меню с опцией удаления
  void _showDeleteMenu(BuildContext context, AppDocument doc) {
    final state = context.read<AppState>();
    final isDarkMode = state.isDarkMode;
    
    showMenu(
      context: context,
      position: RelativeRect.fill,
      items: [
        PopupMenuItem(
          child: Row(
            children: [
              Icon(Icons.delete_outline, size: 20, color: Colors.red),
              const SizedBox(width: 8),
              Text('Удалить документ', style: TextStyle(color: Colors.red)),
            ],
          ),
          onTap: () {
            // ✅ Подтверждение удаления
            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                backgroundColor: isDarkMode ? Colors.grey[850] : Colors.white,
                title: const Text('Удалить документ?'),
                content: Text('Документ "${doc.name}" будет удалён без возможности восстановления.', 
                  style: TextStyle(color: isDarkMode ? Colors.white70 : Colors.black87)),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: Text('Отмена', style: TextStyle(color: isDarkMode ? Colors.grey[400] : Colors.grey[600])),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      state.deleteDocument(doc);
                      Navigator.pop(ctx);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                    child: const Text('Удалить'),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

// ==================== ГРАФОВОЕ ПРЕДСТАВЛЕНИЕ ====================
class _DocumentsGraph extends StatelessWidget {
  const _DocumentsGraph();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final project = state.selectedProject!;
    final docs = project.documents;
    final isDarkMode = state.isDarkMode;

    if (docs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.account_tree_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text('Нет документов', style: TextStyle(color: Colors.grey[600])),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ..._buildDocumentNodes(docs, state, isDarkMode, context),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildDocumentNodes(List<AppDocument> docs, AppState state, bool isDarkMode, BuildContext context) {
    final widgets = <Widget>[];
    final rootDocs = docs.where((d) => d.parentId == null).toList();

    for (var doc in rootDocs) {
      widgets.add(_buildDocumentNode(doc, docs, state, isDarkMode, context));
      widgets.add(const SizedBox(height: 20));
    }

    return widgets;
  }

  Widget _buildDocumentNode(AppDocument doc, List<AppDocument> allDocs, AppState state, bool isDarkMode, BuildContext context) {
    final isSelected = state.selectedDocument?.id == doc.id || state.secondSelectedDocument?.id == doc.id;
    final children = allDocs.where((d) => d.parentId == doc.id).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => state.selectDocument(doc),
          // ✅ Долгое нажатие → сразу второй редактор
          onLongPress: () => state.selectSecondDocument(doc),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected
                  ? (isDarkMode ? Colors.green[800] : Colors.green[100])
                  : (isDarkMode ? Colors.grey[800] : Colors.white),
              border: Border.all(
                color: isSelected
                    ? Colors.green[700]!
                    : (isDarkMode ? Colors.grey[600]! : Colors.grey[400]!),
                width: 2,
              ),
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  doc.isPinned ? Icons.push_pin : Icons.insert_drive_file,
                  color: isSelected ? Colors.green[700] : Colors.grey[600],
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  doc.name,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
                // ✅ Кнопка меню для удаления в графе
                IconButton(
                  icon: const Icon(Icons.more_vert, size: 18),
                  onPressed: () => _showDeleteMenuInGraph(context, doc),
                  tooltip: 'Меню',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
        ),

        if (children.isNotEmpty) ...[
          const SizedBox(height: 8),
          ...children.asMap().entries.map((entry) {
            final childDoc = entry.value;
            return Padding(
              padding: const EdgeInsets.only(left: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(width: 30, height: 2, color: isDarkMode ? Colors.grey[600] : Colors.grey[400]),
                      Icon(Icons.arrow_forward, size: 16, color: isDarkMode ? Colors.grey[600] : Colors.grey[400]),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _buildDocumentNode(childDoc, allDocs, state, isDarkMode, context),
                ],
              ),
            );
          }).toList(),
        ],
      ],
    );
  }

  // ✅ Меню с опцией удаления для графа
  void _showDeleteMenuInGraph(BuildContext context, AppDocument doc) {
    final state = context.read<AppState>();
    final isDarkMode = state.isDarkMode;
    
    showMenu(
      context: context,
      position: RelativeRect.fill,
      items: [
        PopupMenuItem(
          child: Row(
            children: [
              Icon(Icons.delete_outline, size: 20, color: Colors.red),
              const SizedBox(width: 8),
              Text('Удалить документ', style: TextStyle(color: Colors.red)),
            ],
          ),
          onTap: () {
            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                backgroundColor: isDarkMode ? Colors.grey[850] : Colors.white,
                title: const Text('Удалить документ?'),
                content: Text('Документ "${doc.name}" будет удалён без возможности восстановления.', 
                  style: TextStyle(color: isDarkMode ? Colors.white70 : Colors.black87)),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: Text('Отмена', style: TextStyle(color: isDarkMode ? Colors.grey[400] : Colors.grey[600])),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      state.deleteDocument(doc);
                      Navigator.pop(ctx);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                    child: const Text('Удалить'),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

// ==================== РЕДАКТОР ====================
class QuillEditorView extends StatefulWidget {
  final AppDocument document;
  final int editorIndex;
  
  const QuillEditorView({
    super.key, 
    required this.document,
    this.editorIndex = 1,
  });
  
  @override
  State<QuillEditorView> createState() => _QuillEditorViewState();
}

class _QuillEditorViewState extends State<QuillEditorView> {
  quill.QuillController? _controller;
  
  @override
  void initState() {
    super.initState();
    _initializeController();
  }

  @override
  void didUpdateWidget(QuillEditorView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.document.id != widget.document.id) {
      _controller?.dispose();
      _initializeController();
    }
  }

  void _initializeController() {
    final state = context.read<AppState>();
    _controller = state.getOrCreateController(widget.document);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null) return const Center(child: CircularProgressIndicator());
    
    return Column(
      children: [
        quill.QuillSimpleToolbar(
          key: ValueKey('toolbar_${widget.editorIndex}_${widget.document.id}'),
          controller: _controller!,
          config: const quill.QuillSimpleToolbarConfig(
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
          ),
        ),
        Expanded(
          child: quill.QuillEditor(
            key: ValueKey('editor_${widget.editorIndex}_${widget.document.id}'),
            controller: _controller!,
            config: quill.QuillEditorConfig(
              placeholder: 'Начните печатать...',
              padding: const EdgeInsets.all(16),
            ),
            scrollController: ScrollController(),
            focusNode: FocusNode(),
          ),
        ),
      ],
    );
  }
}

class _MobileDocList extends StatelessWidget {
  const _MobileDocList();
  @override
  Widget build(BuildContext context) {
    final state = context.read<AppState>();
    return Scaffold(
      appBar: AppBar(
        title: Text(state.selectedProject!.name),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => state.clearSelectedProject()),
        actions: [
          IconButton(
            icon: Icon(state.isGraphView ? Icons.list : Icons.account_tree),
            onPressed: () => state.toggleViewMode(),
            tooltip: state.isGraphView ? 'Список' : 'Граф',
          ),
          IconButton(icon: const Icon(Icons.add), onPressed: () => _showCreateDocumentDialog(context), tooltip: 'Новый документ'),
        ],
      ),
      body: Selector<AppState, bool>(
        selector: (_, state) => state.isGraphView,
        builder: (context, isGraphView, _) {
          return isGraphView ? const _DocumentsGraph() : const _DocumentsList();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateDocumentDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showCreateDocumentDialog(BuildContext context) {
    final controller = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final state = context.read<AppState>();
    final isDarkMode = state.isDarkMode;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDarkMode ? Colors.grey[850] : Colors.white,
        title: Text('Новый документ', style: TextStyle(color: isDarkMode ? Colors.white : Colors.black87)),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: controller,
            autofocus: true,
            style: TextStyle(color: isDarkMode ? Colors.white : Colors.black87),
            decoration: InputDecoration(
              labelText: 'Название документа',
              labelStyle: TextStyle(color: isDarkMode ? Colors.grey[400] : Colors.grey[600]),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.green[700]!)),
              prefixIcon: Icon(Icons.description, color: Colors.green[700]),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) return 'Введите название документа';
              return null;
            },
            onFieldSubmitted: (_) {
              if (formKey.currentState!.validate()) {
                state.addDocumentToCurrentProject(controller.text.trim());
                Navigator.pop(context);
              }
            },
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Отмена', style: TextStyle(color: Colors.grey[600]))),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                state.addDocumentToCurrentProject(controller.text.trim());
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green[700], foregroundColor: Colors.white),
            child: const Text('Создать'),
          ),
        ],
      ),
    );
  }
}

class _MobileEditorView extends StatelessWidget {
  final AppDocument document;
  const _MobileEditorView({required this.document});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(document.name), leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () {})),
      body: QuillEditorView(document: document),
    );
  }
}

class TestApp extends StatelessWidget {
  const TestApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppState(),
      child: MaterialApp(
        title: 'Manyllines Test',
        // ✅ Не используем локализации в тестах - они не инициализируются в test environment
        home: const AppShell(),
      ),
    );
  }
}