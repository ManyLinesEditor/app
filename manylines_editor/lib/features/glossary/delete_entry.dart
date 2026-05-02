import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../entities/project/project_repository.dart';

class DeleteGlossaryEntryFeature {
  static void execute(
    BuildContext context, 
    String entryId, 
    String definitionId,
  ) {
    final repo = Provider.of<ProjectRepository>(context, listen: false);
    
    repo.deleteGlossaryDefinition(entryId, definitionId);
  }
}