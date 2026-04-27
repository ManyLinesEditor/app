import 'package:flutter/foundation.dart';
import 'glossary_entry.dart';

class GlossaryRepository extends ChangeNotifier {
  final Map<String, List<GlossaryEntry>> _entries = {};

  List<GlossaryEntry> getEntries(String documentId) {
    return _entries[documentId] ?? [];
  }

  void addEntry(String documentId, GlossaryEntry entry) {
    _entries.putIfAbsent(documentId, () => []);
    _entries[documentId]!.add(entry);
    notifyListeners();
  }

  void updateEntry(String documentId, String entryId, String definition) {
    final entries = _entries[documentId];
    if (entries != null) {
      final index = entries.indexWhere((e) => e.id == entryId);
      if (index != -1) {
        entries[index].definition = definition;
        notifyListeners();
      }
    }
  }

  void deleteEntry(String documentId, String entryId) {
    _entries[documentId]?.removeWhere((e) => e.id == entryId);
    notifyListeners();
  }

  void toggleEntry(String documentId, String entryId) {
    final entries = _entries[documentId];
    if (entries != null) {
      final index = entries.indexWhere((e) => e.id == entryId);
      if (index != -1) {
        entries[index].isExpanded = !entries[index].isExpanded;
        notifyListeners();
      }
    }
  }
}