import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:provider/provider.dart';
import 'package:dart_quill_delta/dart_quill_delta.dart';

// ==================== МОДЕЛИ ====================
class Project {
  final String id;
  final String name;
  final List<AppDocument> documents;

  Project({required this.id, required this.name, required this.documents});
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

  bool get isMostUsed => viewCount > 0;

  static AppDocument? getMostUsed(List<AppDocument> docs) {
    if (docs.isEmpty) return null;
    final sorted = List<AppDocument>.from(docs)
      ..sort((a, b) => b.viewCount.compareTo(a.viewCount));
    return sorted.first;
  }
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
  final Map<String, quill.QuillController> _editors = {};

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

  void saveDocumentContent(AppDocument doc, Delta content) {
    doc.content = content;
    notifyListeners();
  }

  quill.QuillController getOrCreateController(AppDocument doc) {
    if (!_editors.containsKey(doc.id)) {
      _editors[doc.id] = quill.QuillController(
        document: quill.Document.fromJson(doc.content.toJson()),
        selection: const TextSelection.collapsed(offset: 0),
      );
      _editors[doc.id]!.changes.listen((_) {
        saveDocumentContent(doc, _editors[doc.id]!.document.toDelta());
      });
    }
    return _editors[doc.id]!;
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

  void selectProject(Project project) {
    _selectedProject = project;
    final mostUsed = AppDocument.getMostUsed(project.documents);
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
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }
    final item = _settings.removeAt(oldIndex);
    _settings.insert(newIndex, item);
    notifyListeners();
  }

  // ✅ Добавлен метод для перетаскивания проектов
  void reorderProjects(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }
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
    for (var controller in _editors.values) {
      controller.dispose();
    }
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[400]!),
                    color: Colors.white,
                  ),
                  child: const Text(
                    'Logo',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Manyllines',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ✅ Список проектов с перетаскиванием (управляется Switchable)
          // Список проектов с перетаскиванием (управляется Switchable)
          // ✅ Список проектов с перетаскиванием (управляется Switchable)
Consumer<AppState>(
  builder: (context, state, _) {
    final bgColor = state.isDarkMode ? Colors.green[900] : Colors.green[50];
    final borderColor = state.isDarkMode 
        ? const Color.fromARGB(255, 0, 47, 22) 
        : Colors.green.shade200;
    final textColor = state.isDarkMode ? Colors.white : Colors.black87;
    
    if (state.switchableValue) {
      // ✅ Режим с перетаскиванием (ReorderableListView)
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
              border: Border(
                bottom: BorderSide(color: borderColor),
              ),
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
      // ✅ Режим БЕЗ перетаскивания (обычный список) — ПРОЕКТЫ ОТОБРАЖАЮТСЯ!
      return Container(
        decoration: BoxDecoration(
          color: bgColor,
          border: Border(
            bottom: BorderSide(color: borderColor),
          ),
        ),
        child: ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: state.projects.length,
          itemBuilder: (context, index) {
            final project = state.projects[index];  // ← Получаем проект
            return Container(  // ← Возвращаем виджет!
              key: ValueKey(project.id),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: borderColor),
                ),
              ),
              child: ListTile(
                title: Text(project.name, style: TextStyle(color: textColor)),
                // ❌ Без иконки drag_handle
                onTap: () => state.selectProject(project),
              ),
            );
          },
        ),
      );
    }
  },
),

          // ✅ Настройки с перетаскиванием (управляется Switchable)
          // Настройки с перетаскиванием (управляется Switchable)
          Consumer<AppState>(
            builder: (context, state, _) {
              // ✅ Выбираем цвет в зависимости от темы
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
                              Text(
                                setting['name'],
                                style: TextStyle(color: textColor),
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      isExpanded ? Icons.arrow_drop_down : Icons.arrow_drop_up,
                                      color: textColor,
                                    ),
                                    onPressed: () => state.toggleSettingExpansion(setting['id']),
                                  ),
                                  if (state.switchableValue)
                                    Icon(Icons.drag_handle, 
                                        color: state.isDarkMode ? Colors.white54 : Colors.grey),
                                ],
                              ),
                            ],
                          ),
                        ),
                        if (setting['id'] == 'setting2' && isExpanded)
                          _buildDescriptionSection2(state.isDarkMode),
                        if (setting['id'] == 'setting3' && isExpanded)
                          _buildDescriptionSection3(state.isDarkMode),
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
                              Text(
                                setting['name'],
                                style: TextStyle(color: textColor),
                              ),
                              IconButton(
                                icon: Icon(
                                  isExpanded ? Icons.arrow_drop_down : Icons.arrow_drop_up,
                                  color: textColor,
                                ),
                                onPressed: () => state.toggleSettingExpansion(setting['id']),
                              ),
                            ],
                          ),
                        ),
                        if (setting['id'] == 'setting2' && isExpanded)
                          _buildDescriptionSection2(state.isDarkMode),
                        if (setting['id'] == 'setting3' && isExpanded)
                          _buildDescriptionSection3(state.isDarkMode),
                      ],
                    );
                  },
                );
              }
            },
          ),

          // Additional settings (голубой фон)
          // Additional settings (голубой фон) — с поддержкой тёмной темы
          Consumer<AppState>(
            builder: (context, state, _) {
              final bgColor = state.isDarkMode ? const Color.fromARGB(255, 6, 58, 137) : Colors.blue[50];
              final textColor = state.isDarkMode ? Colors.white54 : Colors.black54;
              
              return Expanded(
                child: Container(
                  color: bgColor,
                  padding: const EdgeInsets.all(16),
                  child: Center(
                    child: Text(
                      'Other Settings ...',
                      style: TextStyle(color: textColor),
                    ),
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

  // ✅ Метод для построения секции Description (выпадает из Setting 3)
  // ✅ Метод для построения секции Description для Setting 2 (с переключением темы)
Widget _buildDescriptionSection2(bool isDarkMode) {
  return Container(
    color: isDarkMode ? Colors.grey[850] : Colors.grey[50],
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Description',
          style: TextStyle(
            fontSize: 14, 
            color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
          ),
        ),
        const SizedBox(height: 12),
        
        // Кнопки A, B, C
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  side: BorderSide(
                    color: isDarkMode ? Color.fromARGB(255, 54, 107, 232)! : Colors.grey[400]!,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  foregroundColor: isDarkMode ? Colors.white : Colors.black87,
                ),
                child: Text('A'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  side: BorderSide(
                    color: isDarkMode ? Color.fromARGB(255, 54, 107, 232)! : Colors.grey[400]!,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  foregroundColor: isDarkMode ? Colors.white : Colors.black87,
                ),
                child: Text('B'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  side: BorderSide(
                    color: isDarkMode ? const Color.fromARGB(255, 54, 107, 232)! : Colors.grey[400]!,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  foregroundColor: isDarkMode ? Colors.white : Colors.black87,
                ),
                child: Text('C'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        // Switchable для переключения темы
        Consumer<AppState>(
          builder: (context, state, _) {
            final isDark = state.isDarkMode;
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      isDark ? Icons.dark_mode : Icons.light_mode,
                      size: 20,
                      color: isDark ? Colors.yellow[200] : Colors.orange,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isDark ? 'Тёмная тема' : 'Светлая тема',
                      style: TextStyle(color: isDarkMode ? Colors.white : Colors.black87),
                    ),
                  ],
                ),
                Switch(
                  value: isDark,
                  onChanged: (value) {
                    state.toggleDarkMode(value);
                  },
                ),
              ],
            );
          },
        ),
      ],
    ),
  );
}

// ✅ Метод для построения секции Description для Setting 3
Widget _buildDescriptionSection3(bool isDarkMode) {
  return Container(
    color: isDarkMode ? Colors.grey[850] : Colors.grey[50],
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Description',
          style: TextStyle(
            fontSize: 14, 
            color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
          ),
        ),
        const SizedBox(height: 12),
        
        // Кнопки A, B, C
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  side: BorderSide(
                    color: isDarkMode ? Color.fromARGB(255, 54, 107, 232)! : Colors.grey[400]!,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  foregroundColor: isDarkMode ? Colors.white : Colors.black87,
                ),
                child: Text('A'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  side: BorderSide(
                    color: isDarkMode ? Color.fromARGB(255, 54, 107, 232)! : Colors.grey[400]!,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  foregroundColor: isDarkMode ? Colors.white : Colors.black87,
                ),
                child: Text('B'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  side: BorderSide(
                    color: isDarkMode ? Color.fromARGB(255, 54, 107, 232)! : Colors.grey[400]!,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  foregroundColor: isDarkMode ? Colors.white : Colors.black87,
                ),
                child: Text('C'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        // Switchable
        Consumer<AppState>(
          builder: (context, state, _) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Switchable',
                  style: TextStyle(color: isDarkMode ? Colors.white : Colors.black87),
                ),
                Switch(
                  value: state.switchableValue,
                  onChanged: (value) {
                    state.setSwitchableValue(value);
                  },
                ),
              ],
            );
          },
        ),

        
        
        // Listable
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Listable',
              style: TextStyle(color: isDarkMode ? Colors.white : Colors.black87),
            ),
            IconButton(
              icon: Icon(Icons.arrow_drop_down, 
                  color: isDarkMode ? Colors.white : Colors.black87),
              onPressed: () {},
            ),
          ],
        ),
      ],
    ),
  );
}

  // Widget _buildButton(String label) {
  //   return OutlinedButton(
  //     onPressed: () {},
  //     style: OutlinedButton.styleFrom(
  //       padding: const EdgeInsets.symmetric(vertical: 12),
  //       side: BorderSide(color: Colors.grey[400]!),
  //     ),
  //     child: Text(label),
  //   );
  // }

  
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

        return Row(
          children: [
            Container(
              width: 300,
              decoration: BoxDecoration(
                border: Border(right: BorderSide(color: Colors.grey[300]!)),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    color: Colors.green[50],
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
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Expanded(child: _DocumentsList()),
                ],
              ),
            ),
            Expanded(
              child: state.selectedDocument != null
                  ? QuillEditorView(document: state.selectedDocument!)
                  : const Center(child: Text('Select a document')),
            ),
          ],
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
    final docs = state.selectedProject!.documents;

    return ListView.builder(
      itemCount: docs.length,
      itemBuilder: (context, index) {
        final doc = docs[index];
        final isSelected = state.selectedDocument?.id == doc.id;
        return ListTile(
          selected: isSelected,
          selectedTileColor: Theme.of(context).colorScheme.secondaryContainer,
          leading: Icon(
            doc.isMostUsed ? Icons.star : Icons.insert_drive_file,
            color: isSelected
                ? Theme.of(context).colorScheme.onSecondaryContainer
                : Colors.grey[600],
          ),
          title: Text(doc.name),
          subtitle: isSelected
              ? null
              : Text('Views: ${doc.viewCount}', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
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
  late quill.QuillController _controller;

  @override
  void initState() {
    super.initState();
    final state = context.read<AppState>();
    _controller = state.getOrCreateController(widget.document);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        quill.QuillSimpleToolbar(
          controller: _controller,
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
            controller: _controller,
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => state.clearSelectedProject(),
        ),
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {},
        ),
      ),
      body: QuillEditorView(document: document),
    );
  }
}