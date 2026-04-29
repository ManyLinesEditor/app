import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../entities/project/project.dart';
import '../../../entities/project/project_repository.dart';
import '../../../entities/document/document_repository.dart';
import '../../../entities/document/document.dart';
import '../../../entities/setting/setting_repository.dart';
import '../../../features/document/create_document.dart';
import '../../../features/document/delete_document.dart';
import '../../../features/document/toggle_pin.dart';
import '../../../features/document/indent_document.dart';
import '../../../features/document/outdent_document.dart';

// lib/pages/workspace/widgets/side_panel.dart

class SidePanel extends StatelessWidget {
  const SidePanel({super.key});

  @override
  Widget build(BuildContext context) {
    final projectState = context.watch<ProjectRepository>();
    final settingState = context.watch<SettingRepository>();
    final isPanelCollapsed = settingState.isSidePanelCollapsed;
    final isGraphView = projectState.isGraphView;  // ✅ Проверяем режим
    
    final leftPanelBg = settingState.isDarkMode ? Colors.grey[900] : Colors.white;
    final headerBg = settingState.isDarkMode ? Colors.green[900] : Colors.green[50];
    final textColor = settingState.isDarkMode ? Colors.white : Colors.black87;
    final borderColor = settingState.isDarkMode ? Colors.grey[700]! : Colors.grey[300]!;

    return AnimatedContainer(
  duration: const Duration(milliseconds: 300),
  curve: Curves.easeInOut,
  width: isPanelCollapsed 
      ? 0 
      : (isGraphView ? 800 : 300),
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
                        onPressed: () => projectState.clearSelectedProject(),
                        tooltip: 'Back to projects',
                      ),
                      Expanded(
                        child: Text(
                          projectState.selectedProject?.name ?? '',
                          style: TextStyle(color: textColor),
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          projectState.isGraphView ? Icons.list : Icons.account_tree,
                          color: textColor,
                        ),
                        onPressed: () => projectState.toggleViewMode(),
                        tooltip: projectState.isGraphView ? 'Список' : 'Граф',
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
                          child: Selector<ProjectRepository, bool>(
                            selector: (_, state) => state.isGraphView,
                            builder: (context, isGraphView, _) {
                              return isGraphView 
                                  ? const _DocumentsGraph() 
                                  : const _DocumentsList();
                            },
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            border: Border(top: BorderSide(color: borderColor)),
                          ),
                          child: SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: () => CreateDocumentFeature.show(context),
                              icon: const Icon(Icons.add, size: 18),
                              label: const Text('Новый документ'),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                foregroundColor: settingState.isDarkMode ? Colors.white : Colors.green[700],
                                side: BorderSide(
                                  color: settingState.isDarkMode ? Colors.green[400]! : Colors.green[700]!,
                                ),
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
    );
  }
}

// ✅ СПИСОК ДОКУМЕНТОВ
class _DocumentsList extends StatelessWidget {
  const _DocumentsList();
  
  @override
  Widget build(BuildContext context) {
    final projectState = context.watch<ProjectRepository>();
    final project = projectState.selectedProject;
    
    if (project == null) {
      return const Center(child: Text('Нет проекта'));
    }
    
    final pinnedDocs = project.pinnedDocuments;
    final unpinnedDocs = project.unpinnedDocuments;
    final isDarkMode = context.watch<SettingRepository>().isDarkMode;

    return Column(
      children: [
        if (pinnedDocs.isNotEmpty)
          Container(
            color: isDarkMode ? Colors.green[900]!.withOpacity(0.3) : Colors.green[50],
            child: ReorderableListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: pinnedDocs.length,
              onReorder: (oldIndex, newIndex) => projectState.reorderPinnedDocuments(oldIndex, newIndex),
              itemBuilder: (context, index) {
                final doc = pinnedDocs[index];
                final isSelected = context.watch<DocumentRepository>().selectedDocument?.id == doc.id;
                
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
                        GestureDetector(
                          onTap: () {},
                          child: Checkbox(
                            value: doc.isPinned,
                            activeColor: Colors.green[700],
                            onChanged: (value) {
                              TogglePinFeature.execute(context, doc);
                            },
                          ),
                        ),
                        const SizedBox(width: 4),
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
                    onTap: () {
                      final repo = context.read<DocumentRepository>();
                      repo.selectDocument(doc);
                    },
                    onLongPress: () => context.read<DocumentRepository>().selectSecondDocument(doc),
                  ),
                );
              },
            ),
          ),
        Expanded(
          child: Container(
            color: isDarkMode ? Colors.blue[900]!.withOpacity(0.2) : Colors.blue[50],
            child: _buildDismissibleList(project, unpinnedDocs, context),
          ),
        ),
      ],
    );
  }

  Widget _buildDismissibleList(Project project, List<AppDocument> docs, BuildContext context) {
    final isDarkMode = context.watch<SettingRepository>().isDarkMode;

    return ListView.builder(
      itemCount: docs.length,
      itemBuilder: (context, index) {
        final doc = docs[index];
        final isSelected = context.watch<DocumentRepository>().selectedDocument?.id == doc.id;
        final actualIndex = project.documents.indexOf(doc);

        // ✅ Правильная нумерация на основе позиции
        String number;
        int rootCount = 0;
        int childCount = 0;
        
        for (int i = 0; i <= index; i++) {
          if (docs[i].parentId == null) {
            rootCount++;
            childCount = 0;
          } else {
            childCount++;
          }
        }
        
        if (doc.parentId == null) {
          number = '$rootCount.';
        } else {
          number = '$rootCount.$childCount';
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
              IndentDocumentFeature.execute(context, actualIndex);
            } else if (direction == DismissDirection.endToStart) {
              OutdentDocumentFeature.execute(context, actualIndex);
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
                  GestureDetector(
                    onTap: () {},
                    child: Checkbox(
                      value: doc.isPinned,
                      activeColor: Colors.green[700],
                      onChanged: (value) {
                        TogglePinFeature.execute(context, doc);
                      },
                    ),
                  ),
                  const SizedBox(width: 4),
                  if (doc.parentId != null)
                    Icon(Icons.swipe, size: 16, color: Colors.grey[500]),
                  IconButton(
                    icon: const Icon(Icons.more_vert, size: 20),
                    onPressed: () => _showDeleteMenu(context, doc),
                    tooltip: 'Меню',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              onTap: () {
                final repo = context.read<DocumentRepository>();
                repo.selectDocument(doc);
              },
              onLongPress: () => context.read<DocumentRepository>().selectSecondDocument(doc),
            ),
          ),
        );
      },
    );
  }

  void _showDeleteMenu(BuildContext context, AppDocument doc) {
    DeleteDocumentFeature.showConfirmation(context, doc);
  }
}

// ✅ ГРАФОВОЕ ПРЕДСТАВЛЕНИЕ с правильным InteractiveViewer
class _DocumentsGraph extends StatelessWidget {
  const _DocumentsGraph();

  @override
  Widget build(BuildContext context) {
    final projectState = context.watch<ProjectRepository>();
    final project = projectState.selectedProject;
    final docs = project?.documents ?? [];
    final isDarkMode = context.watch<SettingRepository>().isDarkMode;
    final pinnedDocs = project?.pinnedDocuments ?? [];

    return Column(
      children: [
        // ✅ Список pinned документов сверху
        if (pinnedDocs.isNotEmpty)
          Container(
            color: isDarkMode ? Colors.green[900]!.withOpacity(0.3) : Colors.green[50],
            child: ReorderableListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: pinnedDocs.length,
              onReorder: (oldIndex, newIndex) => projectState.reorderPinnedDocuments(oldIndex, newIndex),
              itemBuilder: (context, index) {
                final doc = pinnedDocs[index];
                final isSelected = context.watch<DocumentRepository>().selectedDocument?.id == doc.id;
                
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
                        GestureDetector(
                          onTap: () {},
                          child: Checkbox(
                            value: doc.isPinned,
                            activeColor: Colors.green[700],
                            onChanged: (value) {
                              TogglePinFeature.execute(context, doc);
                            },
                          ),
                        ),
                        const SizedBox(width: 4),
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
                    onTap: () {
                      final repo = context.read<DocumentRepository>();
                      repo.selectDocument(doc);
                    },
                    onLongPress: () => context.read<DocumentRepository>().selectSecondDocument(doc),
                  ),
                );
              },
            ),
          ),
        
        // ✅ Граф с InteractiveViewer (без SingleChildScrollView)
        Expanded(
          child: docs.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.account_tree_outlined, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text('Нет документов', style: TextStyle(color: Colors.grey[600])),
                    ],
                  ),
                )
              : InteractiveViewer(
                  constrained: false,  // ✅ Разрешаем свободное перемещение
                  minScale: 0.1,  // ✅ Можно отдалить до 10%
                  maxScale: 3.0,  // ✅ Можно приблизить до 300%
                  panEnabled: true,  // ✅ Включена прокрутка
                  scaleEnabled: true,  // ✅ Включен зум
                  boundaryMargin: const EdgeInsets.all(1000),  // ✅ Большая область для прокрутки
                  child: Container(
                    color: isDarkMode ? Colors.grey[900] : Colors.white,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(60),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            _buildProjectNode(project!, isDarkMode, context),
                            const SizedBox(height: 60),
                            _buildRootDocuments(docs, isDarkMode, context),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
        ),
      ],
    );
  }

  // ✅ Узел проекта
  Widget _buildProjectNode(Project project, bool isDarkMode, BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDarkMode 
              ? [Colors.purple[900]!, Colors.purple[700]!]
              : [Colors.purple[400]!, Colors.purple[200]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: isDarkMode ? Colors.purple[400]! : Colors.purple[600]!,
          width: 3,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withOpacity(0.4),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.folder, size: 32, color: Colors.white),
          const SizedBox(width: 16),
          Text(
            project.name,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  // ✅ Корневые документы в ряд
  Widget _buildRootDocuments(List<AppDocument> docs, bool isDarkMode, BuildContext context) {
    final rootDocs = docs.where((d) => d.parentId == null).toList();

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,  // ✅ Ограничиваем размер
      children: rootDocs.map((doc) => 
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: _buildDocumentColumn(doc, docs, isDarkMode, context),
        )
      ).toList(),
    );
  }

  // ✅ Колонка документа с поддокументами
  Widget _buildDocumentColumn(
    AppDocument doc, 
    List<AppDocument> allDocs, 
    bool isDarkMode, 
    BuildContext context
  ) {
    final children = allDocs.where((d) => d.parentId == doc.id).toList();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildDocumentNode(doc, isDarkMode, context),
        
        if (children.isNotEmpty) ...[
          const SizedBox(height: 16),
          ...children.asMap().entries.map((entry) {
            final childDoc = entry.value;
            final isLast = entry.key == children.length - 1;
            return Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 2,
                    height: 20,
                    color: isDarkMode ? Colors.grey[600] : Colors.grey[400],
                  ),
                  Icon(
                    Icons.arrow_downward,
                    size: 16,
                    color: isDarkMode ? Colors.grey[600] : Colors.grey[400],
                  ),
                  const SizedBox(height: 6),
                  _buildDocumentNode(childDoc, isDarkMode, context),
                  if (allDocs.any((d) => d.parentId == childDoc.id)) ...[
                    const SizedBox(height: 12),
                    _buildDocumentColumn(childDoc, allDocs, isDarkMode, context),
                  ],
                ],
              ),
            );
          }).toList(),
        ],
      ],
    );
  }

  // ✅ Узел документа
  Widget _buildDocumentNode(AppDocument doc, bool isDarkMode, BuildContext context) {
    final isSelected = context.watch<DocumentRepository>().selectedDocument?.id == doc.id;

    return GestureDetector(
      onTap: () {
        final repo = context.read<DocumentRepository>();
        repo.selectDocument(doc);
      },
      onLongPress: () => context.read<DocumentRepository>().selectSecondDocument(doc),
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
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              doc.isPinned ? Icons.push_pin : Icons.insert_drive_file,
              color: isSelected ? Colors.green[700] : Colors.grey[600],
              size: 18,
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
          ],
        ),
      ),
    );
  }

  void _showDeleteMenu(BuildContext context, AppDocument doc) {
    DeleteDocumentFeature.showConfirmation(context, doc);
  }
}