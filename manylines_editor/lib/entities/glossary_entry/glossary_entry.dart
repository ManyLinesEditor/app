class GlossaryEntry {
  final String id;
  final String term;
  String definition;
  bool isExpanded;
  DateTime createdAt;

  GlossaryEntry({
    required this.id,
    required this.term,
    this.definition = '',
    this.isExpanded = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();
}