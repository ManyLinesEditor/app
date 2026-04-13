import 'package:dart_quill_delta/dart_quill_delta.dart';
import '../glossary_entry/glossary_entry.dart';

class AppDocument {
  final String id;
  final String name;
  int viewCount;
  bool isPinned;
  String? parentId;
  Delta content;
  List<GlossaryEntry> glossary;

  AppDocument({
    required this.id,
    required this.name,
    this.viewCount = 0,
    this.isPinned = false,
    this.parentId,
    required this.content,
    this.glossary = const [],
  });

  bool get isChild => parentId != null;
}