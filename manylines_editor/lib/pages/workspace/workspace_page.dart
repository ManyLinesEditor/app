// lib/pages/workspace/workspace_page.dart

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
import 'widgets/project_top_bar.dart';

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
    
    return Column(
      children: [
        const ProjectTopBar(),
        Expanded(
          child: QuillEditorWrapper(
            document: document,
            editorIndex: 1,
          ),
        ),
      ],
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

// ✅ Основная функция построения десктоп-лейаута
Widget _buildDesktopLayout(BuildContext context, AppDocument? selectedDocument) {
  final settingState = context.watch<SettingRepository>();
  final documentState = context.watch<DocumentRepository>();
  final projectState = context.watch<ProjectRepository>();
  
  final isDarkMode = settingState.isDarkMode;
  final leftPanelBg = isDarkMode ? const Color(0xFF603D2E) : Colors.white;
  final headerBg = isDarkMode ? const Color(0xFF662C90) : const Color(0xFFAB73D3);
  final textColor = isDarkMode ? Colors.white : const Color(0xFFB07156);
  final borderColor = isDarkMode ? const Color(0xFFB07156) : const Color(0xFFAB73D3);
  
  final showTwoEditors = documentState.secondSelectedDocument != null;
  final isPanelCollapsed = settingState.isSidePanelCollapsed;
  final isGlossaryOpen = projectState.isGlossaryPanelOpen;
  
  return Scaffold(
    // ✅ Верхняя панель
    appBar: PreferredSize(
      preferredSize: const Size.fromHeight(60),
      child: const ProjectTopBar(),
    ),
    body: Row(
      children: [
        // ✅ Левая панель (Side Panel)
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          width: isPanelCollapsed ? 0 : (projectState.isGraphView ? 800 : 300),
          decoration: BoxDecoration(
            border: Border(right: BorderSide(color: borderColor)),
          ),
          child: isPanelCollapsed
              ? const SizedBox.shrink()
              : const SidePanel(),
        ),
        
        // ✅ Вкладка для сворачивания/разворачивания левой панели
        Container(
          width: 24,
          decoration: BoxDecoration(
            color: (isDarkMode ? const Color(0xFF603D2E) : const Color(0xFFFFEDEB)),
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
                    color: isDarkMode ? const Color(0xFFB07156) : const Color(0xFFAB73D3),
                  ),
                  child: Icon(
                    isPanelCollapsed ? Icons.chevron_right : Icons.chevron_left,
                    size: 20,
                    color: Colors.white,
                  ),
                ),
              ),
              const Expanded(child: SizedBox()),
            ],
          ),
        ),
        
        // ✅ Редакторы
        Expanded(
          child: showTwoEditors
              ? _buildTwoEditorsLayout(context, borderColor, textColor)
              : _buildSingleEditorLayout(context, selectedDocument, textColor, isDarkMode),
        ),
        
        // ✅ Вкладки глоссария
        if (isGlossaryOpen) ...[
          // ✅ Вкладка для ЗАКРЫТИЯ глоссария
          Container(
            width: 24,
            decoration: BoxDecoration(
              color: isDarkMode ? const Color(0xFF603D2E) : const Color(0xFFFFEDEB),
              border: Border(right: BorderSide(color: borderColor)),
            ),
            child: Column(
              children: [
                const SizedBox(height: 100),
                GestureDetector(
                  onTap: () => projectState.toggleGlossaryPanel(),
                  child: Container(
                    width: 24,
                    height: 82,
                    decoration: BoxDecoration(
                      color: isDarkMode ? const Color(0xFFB07156) : const Color(0xFFAB73D3),
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
          // ✅ Вкладка для ОТКРЫТИЯ глоссария
          Container(
            width: 24,
            decoration: BoxDecoration(
              color: isDarkMode ? const Color(0xFF603D2E) : const Color(0xFFFFEDEB),
              border: Border(right: BorderSide(color: borderColor)),
            ),
            child: Column(
              children: [
                const SizedBox(height: 100),
                GestureDetector(
                  onTap: () => projectState.openGlossaryPanel(),
                  child: Container(
                    width: 24,
                    height: 82,
                    decoration: BoxDecoration(
                      color: isDarkMode ? const Color(0xFFB07156) : const Color(0xFFAB73D3),
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
    // ✅ FAB для создания документа
    persistentFooterButtons: [
      FloatingActionButton(
        heroTag: 'createDoc',
        onPressed: () => CreateDocumentFeature.show(context),
        tooltip: 'Новый документ',
        child: const Icon(Icons.add),
      ),
    ],
    // ✅ FAB для переключения список/граф
    floatingActionButton: Selector<ProjectRepository, bool>(
      selector: (_, state) => state.isGraphView,
      builder: (context, isGraphView, _) {
        return FloatingActionButton(
          onPressed: () => projectState.toggleViewMode(),
          tooltip: isGraphView ? 'Список' : 'Граф',
          child: Icon(isGraphView ? Icons.list : Icons.account_tree),
        );
      },
    ),
  );
}

// ✅ _buildSingleEditorLayout
Widget _buildSingleEditorLayout(BuildContext context, AppDocument? selectedDocument, Color textColor, bool isDarkMode) {
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
        color: isDarkMode ? const Color(0xFF603D2E) : const Color(0xFFFFEDEB),
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

// ✅ _buildTwoEditorsLayout
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

// ✅ _buildEditorHeader
Widget _buildEditorHeader(BuildContext context, int index, Color textColor, AppDocument? doc) {
  final isDarkMode = context.watch<SettingRepository>().isDarkMode;
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    color: isDarkMode ? const Color(0xFF603D2E) : const Color(0xFFFFEDEB),
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