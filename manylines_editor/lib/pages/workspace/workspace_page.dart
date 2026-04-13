import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../entities/document/document_repository.dart';
import '../../entities/project/project_repository.dart';
import '../../widgets/quill_editor_wrapper.dart';
import 'widgets/side_panel.dart';
import 'widgets/editor_area.dart';
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
        return const _DesktopWorkspace();
      },
    );
  }
}

class _DesktopWorkspace extends StatelessWidget {
  const _DesktopWorkspace();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        SidePanel(),
        EditorArea(),
        GlossaryPanel(),
      ],
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
      documentId: document.id,
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