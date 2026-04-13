import '../document/document.dart';

class Project {
  final String id;
  final String name;
  final List<AppDocument> documents;

  Project({
    required this.id,
    required this.name,
    required this.documents,
  });

  int get maxViewCount {
    if (documents.isEmpty) return 0;
    return documents.map((doc) => doc.viewCount).reduce((a, b) => a > b ? a : b);
  }

  bool isDocumentMostUsed(AppDocument doc) {
    return doc.viewCount >= maxViewCount && maxViewCount > 0;
  }

  List<AppDocument> get pinnedDocuments => 
    documents.where((doc) => doc.isPinned).toList();
  
  List<AppDocument> get unpinnedDocuments => 
    documents.where((doc) => !doc.isPinned).toList();
}