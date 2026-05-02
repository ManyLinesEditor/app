import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../entities/project/project_repository.dart';

class ToggleGlossaryDefinitionFeature {
  static void execute(
    BuildContext context, 
    String definitionId,
  ) {
    final repo = Provider.of<ProjectRepository>(context, listen: false);
    
    repo.toggleGlossaryDefinition(definitionId);
  }
}