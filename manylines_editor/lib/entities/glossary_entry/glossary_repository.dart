import 'package:flutter/foundation.dart';
import '../glossary_entry/glossary_entry.dart';
import '../project/project_repository.dart';

class GlossaryRepository extends ChangeNotifier {
  final ProjectRepository _projectRepo;

  GlossaryRepository(this._projectRepo);

  List<GlossaryEntry> get glossary {
    final project = _projectRepo.selectedProject;
    return project?.glossary ?? [];
  }

  GlossaryEntry? findEntryByTerm(String term) {
    final project = _projectRepo.selectedProject;
    if (project == null) return null;
    
    try {
      return project.glossary.firstWhere(
        (e) => e.term.toLowerCase() == term.toLowerCase(),
      );
    } catch (e) {
      return null;
    }
  }

  void addEntry(String term, String definition) {
    final project = _projectRepo.selectedProject;
    if (project == null) return;
    
    final existingEntry = findEntryByTerm(term);
    
    if (existingEntry != null) {
      final newDefinition = GlossaryDefinition(
        id: 'def${DateTime.now().millisecondsSinceEpoch}',
        text: definition,
        isActive: false,
      );
      existingEntry.definitions.add(newDefinition);
    } else {
      final newEntry = GlossaryEntry(
        id: 'g${DateTime.now().millisecondsSinceEpoch}',
        term: term,
        definitions: [
          GlossaryDefinition(
            id: 'def${DateTime.now().millisecondsSinceEpoch}',
            text: definition,
            isActive: true,
          ),
        ],
      );
      project.glossary.add(newEntry);
    }
    
    notifyListeners();
  }

  void updateDefinition(String definitionId, String newText) {
    final project = _projectRepo.selectedProject;
    if (project == null) return;
    
    for (var entry in project.glossary) {
      try {
        final def = entry.definitions.firstWhere(
          (d) => d.id == definitionId,
        );
        def.text = newText;
        notifyListeners();
        return;
      } catch (e) {
        continue;
      }
    }
  }

  void toggleDefinition(String definitionId) {
    final project = _projectRepo.selectedProject;
    if (project == null) return;
    
    for (var entry in project.glossary) {
      for (var def in entry.definitions) {
        if (def.id == definitionId) {
          for (var otherDef in entry.definitions) {
            otherDef.isActive = false;
          }
          def.isActive = true;
          notifyListeners();
          return;
        }
      }
    }
  }

  void deleteDefinition(String entryId, String definitionId) {
    final project = _projectRepo.selectedProject;
    if (project == null) return;
    
    GlossaryEntry? entry;
    try {
      entry = project.glossary.firstWhere((e) => e.id == entryId);
    } catch (e) {
      return;
    }
    
    if (entry != null) {
      entry.definitions.removeWhere((d) => d.id == definitionId);
      
      if (entry.definitions.isEmpty) {
        project.glossary.remove(entry);
      } else {
        try {
          entry.definitions.firstWhere((d) => d.isActive);
        } catch (e) {
          if (entry.definitions.isNotEmpty) {
            entry.definitions.first.isActive = true;
          }
        }
      }
      
      notifyListeners();
    }
  }

  void toggleEntryExpansion(String entryId) {
    final project = _projectRepo.selectedProject;
    if (project == null) return;
    
    try {
      final entry = project.glossary.firstWhere((e) => e.id == entryId);
      entry.isExpanded = !entry.isExpanded;
      notifyListeners();
    } catch (e) {
      return;
    }
  }

  void deleteEntry(String entryId) {
    final project = _projectRepo.selectedProject;
    if (project == null) return;
    
    project.glossary.removeWhere((e) => e.id == entryId);
    notifyListeners();
  }

  List<GlossaryEntry> searchEntries(String query) {
    if (query.isEmpty) return glossary;
    
    return glossary.where((entry) => 
      entry.term.toLowerCase().contains(query.toLowerCase())
    ).toList();
  }
}