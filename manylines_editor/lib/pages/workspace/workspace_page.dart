import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../entities/document/document_repository.dart';
import '../../entities/document/document.dart';
import '../../entities/setting/setting_repository.dart';
import '../../entities/project/project_repository.dart';
import '../../widgets/quill_editor_wrapper.dart';
import '../../features/document/create_document.dart';
import 'widgets/side_panel.dart';
import 'widgets/glossary_panel.dart';

class WorkspacePage extends StatelessWidget {
  const WorkspacePage({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 700;
        if (!isWide) {
          return const _MobileWorkspace();
        }
        return Selector<DocumentRepository, AppDocument?>(
          selector: (_, repo) => repo.selectedDocument,
          builder: (context, selectedDocument, _) {
            return _buildDesktopLayout(context, selectedDocument);
          },
        );
      },
    );
  }
}

class _MobileWorkspace extends StatelessWidget {
  const _MobileWorkspace();

  @override
  Widget build(BuildContext context) {
    final documentState = context.watch<DocumentRepository>();
    final document = documentState.selectedDocument;
    
    if (document == null) {
      return const _MobileEmptyState();
    }
    
    return QuillEditorWrapper(
      document: document,
      editorIndex: 1,
    );
  }
}

class _MobileEmptyState extends StatelessWidget {
  const _MobileEmptyState();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Выберите документ'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.read<ProjectRepository>().clearSelectedProject(),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.description_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Выберите документ из списка',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _buildDesktopLayout(BuildContext context, AppDocument? selectedDocument) {
  final settingState = context.watch<SettingRepository>();
  final documentState = context.watch<DocumentRepository>();
  
  final leftPanelBg = settingState.isDarkMode ? Colors.grey[900] : Colors.white;
  final headerBg = settingState.isDarkMode ? Colors.green[900] : Colors.green[50];
  final textColor = settingState.isDarkMode ? Colors.white : Colors.black87;
  final borderColor = settingState.isDarkMode ? Colors.grey[700]! : Colors.grey[300]!;
  
  final showTwoEditors = documentState.secondSelectedDocument != null;
  final isPanelCollapsed = settingState.isSidePanelCollapsed;
  final isGlossaryOpen = documentState.isGlossaryPanelOpen;
  
  return Scaffold(
    body: Row(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          width: isPanelCollapsed ? 0 : 300,
          decoration: BoxDecoration(
            border: Border(right: BorderSide(color: borderColor)),
          ),
          child: isPanelCollapsed
              ? const SizedBox.shrink()
              : const SidePanel(),
        ),
        
        Container(
          width: 24,
          decoration: BoxDecoration(
            color: isPanelCollapsed ? (settingState.isDarkMode ? Colors.grey[800] : Colors.grey[200]) : Colors.transparent,
            border: Border(right: BorderSide(color: borderColor)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 100),
              GestureDetector(
                onTap: () => settingState.toggleSidePanel(),
                child: Container(
                  width: 24,
                  height: 82,
                  decoration: BoxDecoration(
                    color: settingState.isDarkMode ? Colors.grey[700] : Colors.grey[300],
                  ),
                  child: Icon(
                    isPanelCollapsed ? Icons.chevron_right : Icons.chevron_left,
                    size: 20,
                    color: textColor,
                  ),
                ),
              ),
              const Expanded(child: SizedBox()),
            ],
          ),
        ),
        
        Expanded(
          child: showTwoEditors
              ? _buildTwoEditorsLayout(context, borderColor, textColor)
              : _buildSingleEditorLayout(context, selectedDocument, textColor),
        ),
        
        if (isGlossaryOpen) ...[
          Container(
            width: 24,
            decoration: BoxDecoration(
              color: settingState.isDarkMode ? Colors.grey[800] : Colors.grey[200],
              border: Border(right: BorderSide(color: borderColor)),
            ),
            child: Column(
              children: [
                const SizedBox(height: 100),
                GestureDetector(
                  onTap: () => documentState.toggleGlossaryPanel(),
                  child: Container(
                    width: 24,
                    height: 82,
                    decoration: BoxDecoration(
                      color: settingState.isDarkMode ? Colors.grey[700] : Colors.grey[300],
                    ),
                    child: const Icon(Icons.chevron_right, size: 20, color: Colors.white),
                  ),
                ),
                const Expanded(child: SizedBox()),
              ],
            ),
          ),
          const GlossaryPanel(),
        ] else
          Container(
            width: 24,
            decoration: BoxDecoration(
              color: settingState.isDarkMode ? Colors.grey[800] : Colors.grey[200],
              border: Border(right: BorderSide(color: borderColor)),
            ),
            child: Column(
              children: [
                const SizedBox(height: 100),
                GestureDetector(
                  onTap: () => documentState.openGlossaryPanel(),
                  child: Container(
                    width: 24,
                    height: 82,
                    decoration: BoxDecoration(
                      color: settingState.isDarkMode ? Colors.blue[700] : Colors.blue[300],
                    ),
                    child: const Icon(Icons.chevron_left, size: 20, color: Colors.white),
                  ),
                ),
                const Expanded(child: SizedBox()),
              ],
            ),
          ),
      ],
    ),

    persistentFooterButtons: [
      FloatingActionButton(
        heroTag: 'createDoc',
        onPressed: () => CreateDocumentFeature.show(context),
        tooltip: 'Новый документ',
        child: const Icon(Icons.add),
      ),
    ],

    floatingActionButton: Selector<SettingRepository, bool>(
      selector: (_, state) => state.isGraphView,
      builder: (context, isGraphView, _) {
        return FloatingActionButton(
          onPressed: () => settingState.toggleViewMode(),
          tooltip: isGraphView ? 'Список' : 'Граф',
          child: Icon(isGraphView ? Icons.list : Icons.account_tree),
        );
      },
    ),
  );
}

Widget _buildSingleEditorLayout(BuildContext context, AppDocument? selectedDocument, Color textColor) {
  if (selectedDocument == null) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.description_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text('Выберите документ', style: TextStyle(color: textColor)),
        ],
      ),
    );
  }

  return Column(
    children: [
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        color: context.watch<SettingRepository>().isDarkMode ? Colors.grey[850] : Colors.grey[100],
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
              onPressed: () => context.read<DocumentRepository>().closeFirstEditor(),
              tooltip: 'Закрыть',
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),
      ),
      Expanded(
        child: QuillEditorWrapper(
          document: selectedDocument,
          editorIndex: 1,
        ),
      ),
    ],
  );
}

Widget _buildTwoEditorsLayout(BuildContext context, Color borderColor, Color textColor) {
  final documentState = context.watch<DocumentRepository>();
  
  return Row(
    children: [
      Expanded(
        child: Column(
          children: [
            _buildEditorHeader(context, 1, textColor, documentState.selectedDocument),
            Expanded(
              child: Container(
                decoration: BoxDecoration(border: Border(right: BorderSide(color: borderColor))),
                child: documentState.selectedDocument != null
                    ? QuillEditorWrapper(
                        document: documentState.selectedDocument!,
                        editorIndex: 1,
                      )
                    : Center(child: Text('Выберите документ', style: TextStyle(color: textColor))),
              ),
            ),
          ],
        ),
      ),
      Expanded(
        child: Column(
          children: [
            _buildEditorHeader(context, 2, textColor, documentState.secondSelectedDocument),
            Expanded(
              child: documentState.secondSelectedDocument != null
                  ? QuillEditorWrapper(
                      document: documentState.secondSelectedDocument!,
                      editorIndex: 2,
                    )
                  : Center(child: Text('Выберите документ', style: TextStyle(color: textColor))),
            ),
          ],
        ),
      ),
    ],
  );
}

Widget _buildEditorHeader(BuildContext context, int index, Color textColor, AppDocument? doc) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    color: context.watch<SettingRepository>().isDarkMode ? Colors.grey[850] : Colors.grey[100],
    child: Row(
      children: [
        Expanded(
          child: Text(
            doc?.name ?? (index == 1 ? 'Первый редактор' : 'Второй редактор'),
            style: TextStyle(fontWeight: FontWeight.w500, color: textColor),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.close, size: 20),
          onPressed: () {
            if (doc != null) {
              context.read<DocumentRepository>().closeEditorIfOpen(doc.id);
            }
          },
          tooltip: 'Закрыть',
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
      ],
    ),
  );
}