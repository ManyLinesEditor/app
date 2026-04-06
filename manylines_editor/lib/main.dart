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

  // Вычисляемое свойство
  bool get isMostUsed => viewCount > 0;

  static AppDocument? getMostUsed(List<AppDocument> docs) {
    if (docs.isEmpty) return null;
    final sorted = List<AppDocument>.from(docs)
      ..sort((a, b) => b.viewCount.compareTo(a.viewCount));
    return sorted.first;
  }
}

// ==================== STATE ====================
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

  // ✅ Настройки (список для перетаскивания)
  List<Map<String, dynamic>> _settings = [
    {'id': 'setting1', 'name': 'Setting 1', 'expanded': true, 'enabled': false},
    {'id': 'setting2', 'name': 'Setting 2', 'expanded': false, 'enabled': false},
    {'id': 'setting3', 'name': 'Setting 3', 'expanded': true, 'enabled': false},
  ];

  // ✅ Переключатель Switchable
  bool _switchableValue = true;

  Project? _selectedProject;
  AppDocument? _selectedDocument;

  // Хранилище контроллеров для сохранения изменений
  final Map<String, quill.QuillController> _editors = {};

  // ==================== GETTERS ====================
  List<Project> get projects => _projects;
  List<Map<String, dynamic>> get settings => _settings;  // ✅ Добавлен геттер
  bool get switchableValue => _switchableValue;          // ✅ Добавлен геттер
  Project? get selectedProject => _selectedProject;
  AppDocument? get selectedDocument => _selectedDocument;

  // ==================== METHODS ====================
  
  // Увеличить счётчик просмотров
  void incrementViewCount(AppDocument doc) {
    doc.viewCount++;
    notifyListeners();
  }

  // Сохранить изменения документа
  void saveDocumentContent(AppDocument doc, Delta content) {
    doc.content = content;
    notifyListeners();
  }

  // Получить или создать контроллер для документа
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

  // ✅ Метод для переключения Switchable
  void setSwitchableValue(bool value) {
    _switchableValue = value;
    notifyListeners();
  }

  // ✅ Метод для перетаскивания настроек
  void reorderSettings(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }
    final item = _settings.removeAt(oldIndex);
    _settings.insert(newIndex, item);
    notifyListeners();
  }

  // ✅ Метод для разворачивания/сворачивания настройки
  void toggleSettingExpansion(String id) {
    for (var setting in _settings) {
      if (setting['id'] == id) {
        setting['expanded'] = !setting['expanded'];
        notifyListeners();
        break;
      }
    }
  }

  // ✅ Метод для включения/выключения настройки
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
      child: MaterialApp(
        title: 'Manyllines',
        theme: ThemeData(
          useMaterial3: true,
          colorSchemeSeed: Colors.green,
          fontFamily: 'Roboto',
        ),
        home: AppShell(),
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

// ==================== ЭКРАН ПРОЕКТОВ (как на скрине) ====================
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

          // Список проектов (зелёный фон)
          Container(
            color: Colors.green[50],
            child: Consumer<AppState>(
              builder: (context, state, _) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: state.projects.map((project) {
                    return Container(
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: Colors.green[200]!),
                        ),
                      ),
                      child: CheckboxListTile(
                        value: false,
                        onChanged: (_) => state.selectProject(project),
                        title: Text(project.name),
                        controlAffinity: ListTileControlAffinity.trailing,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ),

          // Настройки (голубой фон)
         // Настройки с возможностью перетаскивания (голубой фон)
Container(
  color: Colors.blue[50],
  height: 200,
  child: Consumer<AppState>(
    builder: (context, state, _) {
      // Если Switchable = true → показываем ReorderableListView
      // Если Switchable = false → показываем обычный Column
      if (state.switchableValue) {
        return ReorderableListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: state.settings.length,
          onReorder: state.reorderSettings,
          itemBuilder: (context, index) {
            final setting = state.settings[index];
            return _buildSettingRow(
              setting['name'],
              setting['expanded'],
              setting['enabled'],
              setting['id'],
              state,
              isDraggable: true,  // ← Разрешаем перетаскивание
            );
          },
        );
      } else {
        // Обычный список без перетаскивания
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: state.settings.length,
          itemBuilder: (context, index) {
            final setting = state.settings[index];
            return _buildSettingRow(
              setting['name'],
              setting['expanded'],
              setting['enabled'],
              setting['id'],
              state,
              isDraggable: false,  // ← Запрещаем перетаскивание
            );
          },
        );
      }
    },
  ),
),

          // Description с кнопками A, B, C
          Container(
            padding: const EdgeInsets.all(16),
            alignment: Alignment.centerLeft,
            child: Text(
              'Description',
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(child: _buildButton('A')),
                const SizedBox(width: 8),
                Expanded(child: _buildButton('B')),
                const SizedBox(width: 8),
                Expanded(child: _buildButton('C')),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Switchable
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Consumer<AppState>(  // ← Оберните в Consumer
              builder: (context, state, _) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Switchable'),
                    Switch(
                      value: state.switchableValue,  // ← Используйте состояние
                      onChanged: (value) {
                        state.setSwitchableValue(value);  // ← Сохраняйте изменение
                      },
                    ),
                  ],
                );
              },
            ),
          ),

          // Listable
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Listable'),
                const Icon(Icons.arrow_drop_down),
              ],
            ),
          ),

          // Additional settings (голубой фон)
          Expanded(
            child: Container(
              color: Colors.blue[50],
              padding: const EdgeInsets.all(16),
              child: const Center(
                child: Text(
                  'Setting ...',
                  style: TextStyle(color: Colors.black54),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.read<AppState>().addProject(),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSettingRow(
  String title,
  bool expanded,
  bool enabled,
  String id,
  AppState state, {
  bool isDraggable = false,  // ← Новый параметр
}) {
  return Container(
    key: ValueKey(id),  // Обязательно для ReorderableListView!
    decoration: BoxDecoration(
      border: Border(bottom: BorderSide(color: Colors.blue[200]!)),
      color: Colors.white,
    ),
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title),
        Row(
          children: [
            IconButton(
              icon: Icon(expanded ? Icons.arrow_drop_down : Icons.arrow_drop_up),
              onPressed: () => state.toggleSettingExpansion(id),
            ),
            const SizedBox(width: 8),
            Checkbox(
              value: enabled,
              onChanged: (value) {
                state.toggleSettingEnabled(id, value ?? false);
              },
            ),
            if (isDraggable)
              IconButton(
                icon: const Icon(Icons.drag_handle, color: Colors.grey),
                onPressed: () {},
                tooltip: 'Перетащить',
              ),
          ],
        ),
      ],
    ),
  );
}

  Widget _buildButton(String label) {
    return OutlinedButton(
      onPressed: () {},
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12),
        side: BorderSide(color: Colors.grey[400]!),
      ),
      child: Text(label),
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

        return Row(
          children: [
            // Левая панель - список документов (30% ширины)
            Container(
              width: 300,
              decoration: BoxDecoration(
                border: Border(right: BorderSide(color: Colors.grey[300]!)),
              ),
              child: Column(
                children: [
                  // Header
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
                  // Список документов
                  const Expanded(child: _DocumentsList()),
                ],
              ),
            ),
            // Правая панель - редактор (70% ширины)
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
            config: const quill.QuillEditorConfig(
              placeholder: 'Начните печатать...',
              padding: EdgeInsets.all(16),
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