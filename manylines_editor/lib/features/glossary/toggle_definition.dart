import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../entities/project/project_repository.dart';

class ToggleGlossaryDefinitionFeature {
  static void execute(
    BuildContext context, 
    String definitionId,
  ) {
    // ✅ Используем ProjectRepository
    final repo = Provider.of<ProjectRepository>(context, listen: false);
    
    // ✅ Переключаем активное определение (radio button)
    repo.toggleGlossaryDefinition(definitionId);
  }
}