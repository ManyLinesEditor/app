import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:provider/provider.dart';
import '../entities/document/document.dart';
import '../entities/document/document_repository.dart';
import '../entities/glossary_entry/glossary_entry.dart';
import '../features/editor/handle_text_selection.dart';

class QuillEditorWrapper extends StatefulWidget {
  final AppDocument document;
  final int editorIndex;

  const QuillEditorWrapper({
    super.key,
    required this.document,
    this.editorIndex = 1,
  });

  @override
  State<QuillEditorWrapper> createState() => _QuillEditorWrapperState();
}

class _QuillEditorWrapperState extends State<QuillEditorWrapper> {
  quill.QuillController? _controller;

  @override
  void initState() {
    super.initState();
    _initializeController();
  }

  @override
  void didUpdateWidget(QuillEditorWrapper oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.document.id != widget.document.id) {
      _initializeController();
    }
  }

  void _initializeController() {
    final repo = context.read<DocumentRepository>();
    _controller = repo.getOrCreateController(widget.document);
  }

  void _addSelectedToGlossary() {
  print('🔍 _addSelectedToGlossary вызван');
  
  final selectedText = _getSelectedText();
  print('🔍 Выделенный текст: $selectedText');
  
  if (selectedText != null) {
    print('🔍 Добавляем термин: $selectedText');
    print('🔍 Document ID: ${widget.document.id}');
    
    final repo = context.read<DocumentRepository>();
    repo.addGlossaryEntry(widget.document.id, selectedText);
    
    print('✅ Термин добавлен');
    print('Открываем Глоссарий');
    repo.openGlossaryPanel();
  } else {
    print('❌ Текст не выделен');
  }
}

  String? _getSelectedText() {
    if (_controller == null) return null;
    
    final selection = _controller!.selection;
    if (selection.isCollapsed) return null;
    
    final text = _controller!.document.toPlainText();
    if (selection.baseOffset >= text.length || selection.extentOffset >= text.length) return null;
    
    final start = selection.baseOffset < selection.extentOffset 
        ? selection.baseOffset : selection.extentOffset;
    final end = selection.baseOffset < selection.extentOffset 
        ? selection.extentOffset : selection.baseOffset;
    
    final selectedText = text.substring(start, end);
    return selectedText.trim().isNotEmpty ? selectedText.trim() : null;
  }

  @override
  void dispose() {
    _controller = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return GestureDetector(
      onPanEnd: (details) {
        if (details.velocity.pixelsPerSecond.dx < -500) {
          HandleTextSelectionFeature.execute(context, _controller);
        }
      },
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: quill.QuillSimpleToolbar(
                  controller: _controller!,
                  config: const quill.QuillSimpleToolbarConfig(
                    showBoldButton: true,
                    showItalicButton: true,
                    showUnderLineButton: true,
                    showFontSize: true,
                    showAlignmentButtons: true,
                    showListNumbers: true,
                    showListBullets: true,
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  border: Border(left: BorderSide(color: Colors.grey[300]!)),
                ),
                child: IconButton(
                  icon: const Icon(Icons.book, size: 22),
                  onPressed: _addSelectedToGlossary,
                  tooltip: 'Добавить в глоссарий',
                  color: Colors.blue[700],
                ),
              ),
            ],
          ),
          Expanded(
            child: quill.QuillEditor(
              key: ValueKey('editor_${widget.document.id}_${widget.editorIndex}'),
              controller: _controller!,
              config: const quill.QuillEditorConfig(
                placeholder: 'Начните печатать...',
                padding: EdgeInsets.all(16),
              ),
              focusNode: FocusNode(),
              scrollController: ScrollController(),
            ),
          ),
        ],
      ),
    );
  }
}