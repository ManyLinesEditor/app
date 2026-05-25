class GlossaryEntry {
  final String id;
  final String term;
  List<GlossaryDefinition> definitions;
  bool isExpanded;
  DateTime createdAt;

  GlossaryEntry({
    required this.id,
    required this.term,
    List<GlossaryDefinition>? definitions,
    this.isExpanded = false,
    DateTime? createdAt,
  }) : definitions = definitions ?? [],
       createdAt = createdAt ?? DateTime.now();
}

class GlossaryDefinition {
  final String id;
  String text;
  bool isActive;
  bool isCollapsed;

  GlossaryDefinition({
    required this.id,
    required this.text,
    this.isActive = false,
    this.isCollapsed = true,
  });
}