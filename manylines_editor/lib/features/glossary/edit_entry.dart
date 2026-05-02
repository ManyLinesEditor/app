import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../entities/project/project_repository.dart';

class EditGlossaryEntryFeature {
  static void execute(
    BuildContext context, 
    String definitionId, 
    String definition,
  ) {
    final repo = Provider.of<ProjectRepository>(context, listen: false);
    
    repo.updateGlossaryDefinition(definitionId, definition);
  }
}