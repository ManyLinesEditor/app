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

  // ✅ Метод для получения максимального количества просмотров в проекте
  int get maxViewCount {
    if (documents.isEmpty) return 0;
    return documents.map((doc) => doc.viewCount).reduce((a, b) => a > b ? a : b);
  }

  // ✅ Метод для проверки, является ли документ самым популярным
  bool isDocumentMostUsed(AppDocument doc) {
    return doc.viewCount >= maxViewCount && maxViewCount > 0;
  }
}

class AppDocument {
  final String id;
  final String name;
  int viewCount;
  Delta content;

  AppDocument({
    required this.id,
    required this.name,
    this.viewCount = 0,
    required this.content,
  });
}

// ==================== STATE ====================
class AppState extends ChangeNotifier {
  final List<Project> _projects = [
    Project(
      id: 'p1',
      name: 'Project 1',
      documents: [
        AppDocument(
          id: 'd1',
          name: 'Main Document',
          viewCount: 15,
          content: Delta()..insert('Welcome to Project 1!\n'),
        ),
        AppDocument(
          id: 'd2',
          name: 'Specifications',
          viewCount: 8,
          content: Delta()..insert('Technical specifications...\n'),
        ),
      ],
    ),
    Project(
      id: 'p2',
      name: 'Project 2',
      documents: [
        AppDocument(
          id: 'd3',
          name: 'Overview',
          viewCount: 23,
          content: Delta()..insert('Project overview...\n'),
        ),
      ],
    ),
  ];

  List<Map<String, dynamic>> _settings = [
    {'id': 'setting1', 'name': 'Setting 1', 'expanded': true, 'enabled': false},
    {'id': 'setting2', 'name': 'Setting 2', 'expanded': false, 'enabled': false},
    {'id': 'setting3', 'name': 'Setting 3', 'expanded': true, 'enabled': false},
  ];

  bool _switchableValue = true;
  Project? _selectedProject;
  AppDocument? _selectedDocument;
  bool _isDarkMode = false;

  // ==================== GETTERS ====================
  List<Project> get projects => _projects;
  List<Map<String, dynamic>> get settings => _settings;
  bool get switchableValue => _switchableValue;
  Project? get selectedProject => _selectedProject;
  AppDocument? get selectedDocument => _selectedDocument;
  bool get isDarkMode => _isDarkMode;

  // ==================== METHODS ====================
  
  void toggleDarkMode(bool value) {
    _isDarkMode = value;
    notifyListeners();
  }
  
  void incrementViewCount(AppDocument doc) {
    doc.viewCount++;
    notifyListeners();
  }

  // ✅ Создаёт НОВЫЙ контроллер для каждого документа
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

  void addProject() {
    final newId = 'p${_projects.length + 1}';
    _projects.add(Project(
      id: newId,
      name: 'Project ${_projects.length + 1}',
      documents: [
        AppDocument(
          id: 'd${DateTime.now().millisecondsSinceEpoch}',
          name: 'New Document',
          viewCount: 1,
          content: Delta()..insert('Start typing...\n'),
        ),
      ],
    ));
    notifyListeners();
  }

  void addDocumentToCurrentProject() {
    if (_selectedProject == null) return;
    
    final newDoc = AppDocument(
      id: 'd${DateTime.now().millisecondsSinceEpoch}',
      name: 'Document ${_selectedProject!.documents.length + 1}',
      viewCount: 0,
      content: Delta()..insert('New document content...\n'),
    );
    
    _selectedProject!.documents.add(newDoc);
    _selectedDocument = newDoc;
    notifyListeners();
  }

  void selectProject(Project project) {
    _selectedProject = project;
    final mostUsed = project.documents.isNotEmpty 
        ? project.documents.reduce((a, b) => a.viewCount > b.viewCount ? a : b)
        : null;
    _selectedDocument = mostUsed ?? project.documents.first;
    if (_selectedDocument != null) {
      incrementViewCount(_selectedDocument!);
    }
    notifyListeners();
  }

  void selectDocument(AppDocument document) {
    _selectedDocument = document;
    incrementViewCount(document);
    notifyListeners();
  }

  void clearSelectedProject() {
    _selectedProject = null;
    _selectedDocument = null;
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
        return selectedProject == null
            ? const ProjectsScreen()
            : const ProjectWorkspace();
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
          // Header с Logo и Manyllines
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
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: borderColor)),
                  color: headerBg,
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        border: Border.all(color: logoBorderColor),
                        color: logoBg,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'Logo',
                        style: TextStyle(fontWeight: FontWeight.bold, color: logoTextColor),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Manyllines',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: textColor),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          // Список проектов с перетаскиванием
          Consumer<AppState>(
            builder: (context, state, _) {
              final bgColor = state.isDarkMode ? Colors.green[900] : Colors.green[50];
              final borderColor = state.isDarkMode 
                  ? const Color.fromARGB(255, 0, 47, 22) 
                  : Colors.green.shade200;
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
                      decoration: BoxDecoration(
                        color: bgColor,
                        border: Border(bottom: BorderSide(color: borderColor)),
                      ),
                      child: ListTile(
                        title: Text(project.name, style: TextStyle(color: textColor)),
                        trailing: Icon(Icons.drag_handle, 
                            color: state.isDarkMode ? Colors.white54 : Colors.grey),
                        onTap: () => state.selectProject(project),
                      ),
                    );
                  },
                );
              } else {
                return Container(
                  decoration: BoxDecoration(
                    color: bgColor,
                    border: Border(bottom: BorderSide(color: borderColor)),
                  ),
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: state.projects.length,
                    itemBuilder: (context, index) {
                      final project = state.projects[index];
                      return Container(
                        key: ValueKey(project.id),
                        decoration: BoxDecoration(
                          border: Border(bottom: BorderSide(color: borderColor)),
                        ),
                        child: ListTile(
                          title: Text(project.name, style: TextStyle(color: textColor)),
                          onTap: () => state.selectProject(project),
                        ),
                      );
                    },
                  ),
                );
              }
            },
          ),

          // Настройки с перетаскиванием
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
                          decoration: BoxDecoration(
                            border: Border(bottom: BorderSide(color: borderColor!)),
                            color: state.isDarkMode ? Colors.blue[800] : Colors.white,
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(setting['name'], style: TextStyle(color: textColor)),
                              Row(
                                children: [
                                  IconButton(
                                    icon: Icon(isExpanded ? Icons.arrow_drop_down : Icons.arrow_drop_up, color: textColor),
                                    onPressed: () => state.toggleSettingExpansion(setting['id']),
                                  ),
                                  if (state.switchableValue)
                                    Icon(Icons.drag_handle, color: state.isDarkMode ? Colors.white54 : Colors.grey),
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
                          decoration: BoxDecoration(
                            border: Border(bottom: BorderSide(color: borderColor!)),
                            color: state.isDarkMode ? Colors.blue[800] : Colors.white,
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(setting['name'], style: TextStyle(color: textColor)),
                              IconButton(
                                icon: Icon(isExpanded ? Icons.arrow_drop_down : Icons.arrow_drop_up, color: textColor),
                                onPressed: () => state.toggleSettingExpansion(setting['id']),
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
              }
            },
          ),

          // Additional settings
          Consumer<AppState>(
            builder: (context, state, _) {
              final bgColor = state.isDarkMode ? const Color.fromARGB(255, 6, 58, 137) : Colors.blue[50];
              final textColor = state.isDarkMode ? Colors.white54 : Colors.black54;
              return Expanded(
                child: Container(
                  color: bgColor,
                  padding: const EdgeInsets.all(16),
                  child: Center(
                    child: Text('Other Settings ...', style: TextStyle(color: textColor)),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.read<AppState>().addProject(),
        child: const Icon(Icons.add),
      ),
    );
  }

  // ==================== ОПИСАНИЯ ДЛЯ НАСТРОЕК ====================
  Widget _buildDescriptionSection2(bool isDarkMode) {
    return Container(
      color: isDarkMode ? Colors.grey[850] : Colors.grey[50],
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Description', style: TextStyle(fontSize: 14, color: isDarkMode ? Colors.grey[300] : Colors.grey[700])),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildOutlinedButton('A', isDarkMode),
              const SizedBox(width: 8),
              _buildOutlinedButton('B', isDarkMode),
              const SizedBox(width: 8),
              _buildOutlinedButton('C', isDarkMode),
            ],
          ),
          const SizedBox(height: 16),
          Consumer<AppState>(
            builder: (context, state, _) {
              final isDark = state.isDarkMode;
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(isDark ? Icons.dark_mode : Icons.light_mode, size: 20, color: isDark ? Colors.yellow[200] : Colors.orange),
                      const SizedBox(width: 8),
                      Text(isDark ? 'Тёмная тема' : 'Светлая тема', style: TextStyle(color: isDarkMode ? Colors.white : Colors.black87)),
                    ],
                  ),
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
          Row(
            children: [
              _buildOutlinedButton('A', isDarkMode),
              const SizedBox(width: 8),
              _buildOutlinedButton('B', isDarkMode),
              const SizedBox(width: 8),
              _buildOutlinedButton('C', isDarkMode),
            ],
          ),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Listable', style: TextStyle(color: isDarkMode ? Colors.white : Colors.black87)),
              IconButton(icon: Icon(Icons.arrow_drop_down, color: isDarkMode ? Colors.white : Colors.black87), onPressed: () {}),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionSection1(bool isDarkMode) {
    return Container(
      color: isDarkMode ? Colors.grey[850] : Colors.grey[50],
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Description', style: TextStyle(fontSize: 14, color: isDarkMode ? Colors.grey[300] : Colors.grey[700])),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildOutlinedButton('A', isDarkMode),
              const SizedBox(width: 8),
              _buildOutlinedButton('B', isDarkMode),
              const SizedBox(width: 8),
              _buildOutlinedButton('C', isDarkMode),
            ],
          ),
        ],
      ),
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
        final state = context.read<AppState>();

        if (!isWide) {
          return state.selectedDocument == null
              ? const _MobileDocList()
              : _MobileEditorView(document: state.selectedDocument!);
        }

        final leftPanelBg = state.isDarkMode ? Colors.grey[900] : Colors.white;
        final headerBg = state.isDarkMode ? Colors.green[900] : Colors.green[50];
        final textColor = state.isDarkMode ? Colors.white : Colors.black87;
        final borderColor = state.isDarkMode ? Colors.grey[700]! : Colors.grey[300]!;

        return Scaffold(
          body: Row(
            children: [
              Container(
                width: 300,
                decoration: BoxDecoration(
                  border: Border(right: BorderSide(color: borderColor)),
                ),
                child: Column(
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
                            Expanded(child: _DocumentsList()),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                border: Border(top: BorderSide(color: borderColor)),
                              ),
                              child: SizedBox(
                                width: double.infinity,
                                child: OutlinedButton.icon(
                                  onPressed: () => state.addDocumentToCurrentProject(),
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
              Expanded(
                child: state.selectedDocument != null
                    ? QuillEditorView(document: state.selectedDocument!)
                    : Center(
                        child: Text(
                          'Выберите документ или создайте новый',
                          style: TextStyle(color: state.isDarkMode ? Colors.white70 : Colors.black54),
                        ),
                      ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => state.addDocumentToCurrentProject(),
            tooltip: 'Создать документ',
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }
}

// ==================== КОМПОНЕНТЫ ====================
class _DocumentsList extends StatelessWidget {
  const _DocumentsList();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final project = state.selectedProject!;
    final docs = List<AppDocument>.from(project.documents)
      ..sort((a, b) => b.viewCount.compareTo(a.viewCount));

    return ListView.builder(
      itemCount: docs.length,
      itemBuilder: (context, index) {
        final doc = docs[index];
        final isSelected = state.selectedDocument?.id == doc.id;
        
        // ✅ Вычисляем isMostUsed через проект
        final isMostUsed = project.isDocumentMostUsed(doc);

        return ListTile(
          selected: isSelected,
          selectedTileColor: Theme.of(context).colorScheme.secondaryContainer,
          leading: Icon(
            isMostUsed ? Icons.star : Icons.insert_drive_file,
            color: isSelected
                ? Theme.of(context).colorScheme.onSecondaryContainer
                : Colors.grey[600],
          ),
          title: Text(doc.name),
          subtitle: isSelected ? null : Text('Views: ${doc.viewCount}', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
          onTap: () => state.selectDocument(doc),
        );
      },
    );
  }
}

class QuillEditorView extends StatefulWidget {
  final AppDocument document;
  const QuillEditorView({super.key, required this.document});

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
    // ✅ Если документ изменился - создаём НОВЫЙ контроллер
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
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null) {
      return const Center(child: CircularProgressIndicator());
    }
    
    return Column(
      children: [
        quill.QuillSimpleToolbar(
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
      ),
      body: const _DocumentsList(),
    );
  }
}

class _MobileEditorView extends StatelessWidget {
  final AppDocument document;
  const _MobileEditorView({required this.document});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(document.name),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () {}),
      ),
      body: QuillEditorView(document: document),
    );
  }
}