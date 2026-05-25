import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../entities/document/document_repository.dart';
import '../../../entities/setting/setting_repository.dart';
import '../../../widgets/quill_editor_wrapper.dart';
import '../../../features/editor/close_editor.dart';

class EditorArea extends StatelessWidget {
  const EditorArea({super.key});

  @override
  Widget build(BuildContext context) {
    final documentState = context.watch<DocumentRepository>();
    final settingState = context.watch<SettingRepository>();
    
    final showTwoEditors = documentState.secondSelectedDocument != null;
    final borderColor = settingState.isDarkMode 
        ? Colors.grey[700]! : Colors.grey[300]!;
    final textColor = settingState.isDarkMode 
        ? Colors.white : Colors.black87;

    if (showTwoEditors) {
      return _buildTwoEditorsLayout(context, borderColor, textColor);
    } else {
      return _buildSingleEditorLayout(context, textColor);
    }
  }

  Widget _buildSingleEditorLayout(BuildContext context, Color textColor) {
    final documentState = context.watch<DocumentRepository>();
    final selectedDocument = documentState.selectedDocument;
    
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
                onPressed: () => CloseEditorFeature.execute(context, editorIndex: 1),
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
              _buildEditorHeader(context, 1, textColor),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border(right: BorderSide(color: borderColor)),
                  ),
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
              _buildEditorHeader(context, 2, textColor),
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

  Widget _buildEditorHeader(BuildContext context, int index, Color textColor) {
    final documentState = context.watch<DocumentRepository>();
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      color: context.watch<SettingRepository>().isDarkMode ? Colors.grey[850] : Colors.grey[100],
      child: Row(
        children: [
          Expanded(
            child: Text(
              index == 1 
                  ? documentState.selectedDocument?.name ?? 'Первый редактор'
                  : documentState.secondSelectedDocument?.name ?? 'Второй редактор',
              style: TextStyle(fontWeight: FontWeight.w500, color: textColor),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 20),
            onPressed: () => CloseEditorFeature.execute(context, editorIndex: index),
            tooltip: 'Закрыть',
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}