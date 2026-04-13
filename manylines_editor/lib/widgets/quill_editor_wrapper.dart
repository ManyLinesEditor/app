import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:provider/provider.dart';
import '../../entities/document/document_repository.dart';
import '../features/editor/handle_text_selection.dart';

class QuillEditorWrapper extends StatefulWidget {
  final String documentId;
  final int editorIndex;

  const QuillEditorWrapper({
    super.key,
    required this.documentId,
    this.editorIndex = 1,
  });

  @override
  State<QuillEditorWrapper> createState() => _QuillEditorWrapperState();
}

class _QuillEditorWrapperState extends State<QuillEditorWrapper> {
  quill.QuillController? _controller;
  late FocusNode _focusNode;
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _scrollController = ScrollController();
    _initializeController();
  }

  void _initializeController() {
    final repo = context.read<DocumentRepository>();
    _controller = repo.getOrCreateController(widget.documentId);
  }

  @override
  void dispose() {
    _controller?.dispose();
    _focusNode.dispose();
    _scrollController.dispose();
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
          quill.QuillSimpleToolbar(
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
          Expanded(
            child: quill.QuillEditor(
              controller: _controller!,
              config: const quill.QuillEditorConfig(
                placeholder: 'Начните печатать...',
                padding: EdgeInsets.all(16),
              ),
              focusNode: _focusNode,
              scrollController: _scrollController,
            ),
          ),
        ],
      ),
    );
  }
}