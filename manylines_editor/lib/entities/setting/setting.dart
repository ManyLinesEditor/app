class Setting {
  final String id;
  final String name;
  bool expanded;
  bool enabled;

  Setting({
    required this.id,
    required this.name,
    this.expanded = false,
    this.enabled = false,
  });
}