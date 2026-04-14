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

class SidePanel extends StatelessWidget {
  const SidePanel({super.key});

  @override
  Widget build(BuildContext context) {
    final projectState = context.watch<ProjectRepository>();
    final settingState = context.watch<SettingRepository>();
    final isPanelCollapsed = settingState.isSidePanelCollapsed;
    
    final leftPanelBg = settingState.isDarkMode ? Colors.grey[900] : Colors.white;
    final headerBg = settingState.isDarkMode ? Colors.green[900] : Colors.green[50];
    final textColor = settingState.isDarkMode ? Colors.white : Colors.black87;
    final borderColor = settingState.isDarkMode ? Colors.grey[700]! : Colors.grey[300]!;

    return AnimatedContainer(
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
                          settingState.isGraphView ? Icons.list : Icons.account_tree,
                          color: textColor,
                        ),
                        onPressed: () => settingState.toggleViewMode(),
                        tooltip: settingState.isGraphView ? 'Список' : 'Граф',
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
                          child: Selector<SettingRepository, bool>(
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

class _DocumentsList extends StatelessWidget {
  const _DocumentsList();
  
  @override
  Widget build(BuildContext context) {
    final projectState = context.watch<ProjectRepository>();
    final project = projectState.selectedProject;
    
    context.watch<DocumentRepository>();
    
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

class _DocumentsGraph extends StatelessWidget {
  const _DocumentsGraph();

  @override
  Widget build(BuildContext context) {
    final projectState = context.watch<ProjectRepository>();
    final project = projectState.selectedProject;
    final docs = project?.documents ?? [];
    final isDarkMode = context.watch<SettingRepository>().isDarkMode;

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
            ..._buildDocumentNodes(docs, context),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildDocumentNodes(List<AppDocument> docs, BuildContext context) {
    final widgets = <Widget>[];
    final rootDocs = docs.where((d) => d.parentId == null).toList();

    for (var doc in rootDocs) {
      widgets.add(_buildDocumentNode(doc, docs, context));
      widgets.add(const SizedBox(height: 20));
    }

    return widgets;
  }

  Widget _buildDocumentNode(AppDocument doc, List<AppDocument> allDocs, BuildContext context) {
    final isSelected = context.watch<DocumentRepository>().selectedDocument?.id == doc.id;
    final children = allDocs.where((d) => d.parentId == doc.id).toList();
    final isDarkMode = context.watch<SettingRepository>().isDarkMode;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
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
                  _buildDocumentNode(childDoc, allDocs, context),
                ],
              ),
            );
          }).toList(),
        ],
      ],
    );
  }

  void _showDeleteMenuInGraph(BuildContext context, AppDocument doc) {
    DeleteDocumentFeature.showConfirmation(context, doc);
  }
}