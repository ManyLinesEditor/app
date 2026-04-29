import 'package:flutter/foundation.dart';
import '../glossary_entry/glossary_entry.dart';
import '../project/project_repository.dart';

class GlossaryRepository extends ChangeNotifier {
  final ProjectRepository _projectRepo;

  GlossaryRepository(this._projectRepo);

  // ✅ Геттер глоссария текущего проекта
  List<GlossaryEntry> get glossary {
    final project = _projectRepo.selectedProject;
    return project?.glossary ?? [];
  }

  // ✅ Поиск термина (исправлено - возвращаем nullable)
  GlossaryEntry? findEntryByTerm(String term) {
    final project = _projectRepo.selectedProject;
    if (project == null) return null;
    
    // ✅ Используем cast + firstWhere с правильным orElse
    try {
      return project.glossary.firstWhere(
        (e) => e.term.toLowerCase() == term.toLowerCase(),
      );
    } catch (e) {
      return null;  // ✅ Если не найдено - возвращаем null
    }
  }

  // ✅ Добавление термина или нового определения
  void addEntry(String term, String definition) {
    final project = _projectRepo.selectedProject;
    if (project == null) return;
    
    // ✅ Проверяем существует ли термин
    final existingEntry = findEntryByTerm(term);
    
    if (existingEntry != null) {
      // ✅ Добавляем новое определение к существующему термину
      final newDefinition = GlossaryDefinition(
        id: 'def${DateTime.now().millisecondsSinceEpoch}',
        text: definition,
        isActive: false,
      );
      existingEntry.definitions.add(newDefinition);
    } else {
      // ✅ Создаём новый термин с первым определением
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

  // ✅ Обновление текста определения
  void updateDefinition(String definitionId, String newText) {
    final project = _projectRepo.selectedProject;
    if (project == null) return;
    
    for (var entry in project.glossary) {
      // ✅ Исправлено - используем try-catch вместо orElse: () => null
      try {
        final def = entry.definitions.firstWhere(
          (d) => d.id == definitionId,
        );
        def.text = newText;
        notifyListeners();
        return;
      } catch (e) {
        // Продолжаем поиск в следующем entry
        continue;
      }
    }
  }

  // ✅ Переключение активного определения (radio button)
  void toggleDefinition(String definitionId) {
    final project = _projectRepo.selectedProject;
    if (project == null) return;
    
    for (var entry in project.glossary) {
      for (var def in entry.definitions) {
        if (def.id == definitionId) {
          // Снимаем активность со всех определений этого термина
          for (var otherDef in entry.definitions) {
            otherDef.isActive = false;
          }
          // Активируем выбранное
          def.isActive = true;
          notifyListeners();
          return;
        }
      }
    }
  }

  // ✅ Удаление определения
  void deleteDefinition(String entryId, String definitionId) {
    final project = _projectRepo.selectedProject;
    if (project == null) return;
    
    // ✅ Исправлено - используем try-catch
    GlossaryEntry? entry;
    try {
      entry = project.glossary.firstWhere((e) => e.id == entryId);
    } catch (e) {
      return;  // Не найдено
    }
    
    if (entry != null) {
      entry.definitions.removeWhere((d) => d.id == definitionId);
      
      // ✅ Если удалили последнее определение — удаляем весь термин
      if (entry.definitions.isEmpty) {
        project.glossary.remove(entry);
      } else {
        // ✅ Если удалили активное — активируем первое оставшееся
        try {
          entry.definitions.firstWhere((d) => d.isActive);
        } catch (e) {
          // Активного нет, активируем первое
          if (entry.definitions.isNotEmpty) {
            entry.definitions.first.isActive = true;
          }
        }
      }
      
      notifyListeners();
    }
  }

  // ✅ Переключение раскрытия термина (accordion)
  void toggleEntryExpansion(String entryId) {
    final project = _projectRepo.selectedProject;
    if (project == null) return;
    
    // ✅ Исправлено - используем try-catch
    try {
      final entry = project.glossary.firstWhere((e) => e.id == entryId);
      entry.isExpanded = !entry.isExpanded;
      notifyListeners();
    } catch (e) {
      return;  // Не найдено
    }
  }

  // ✅ Удаление всего термина
  void deleteEntry(String entryId) {
    final project = _projectRepo.selectedProject;
    if (project == null) return;
    
    project.glossary.removeWhere((e) => e.id == entryId);
    notifyListeners();
  }

  // ✅ Поиск по термину (для автодополнения)
  List<GlossaryEntry> searchEntries(String query) {
    if (query.isEmpty) return glossary;
    
    return glossary.where((entry) => 
      entry.term.toLowerCase().contains(query.toLowerCase())
    ).toList();
  }
}